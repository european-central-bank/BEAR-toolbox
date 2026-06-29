
classdef MixedFrequency ...
    < base.Estimator

    properties
        Settings = mixed.estimator.settings.MixedFrequency()
    end


    properties (Constant)
        Description = "Mixed-frequency VAR"
        Category = "Specialized estimators"
        HasCrossUnits = false
        CanBeIdentified = true
        CanHaveDummies = false
    end


    methods

        function initializeSampler(this, meta, longYX)
            %[
            arguments
                this
                meta
                longYX (1, 2) cell
            end

            [longY, ~] = longYX{:};

            const = meta.HasIntercept;
            numLags = meta.Order;

            % Find the last row where not all elements are NaN
            lastDataRow = find(any(~isnan(longY), 2), 1, "last");
            H = size(longY, 1) - lastDataRow;

            hyp = [ ...
                this.Settings.MixedLambda1, ...
                this.Settings.MixedLambda2, ...
                this.Settings.MixedLambda3, ...
                this.Settings.MixedLambda4, ...
                this.Settings.MixedLambda5, ...
            ];

            Nm = meta.NumHighFrequencyNames;
            Nq = meta.NumLowFrequencyNames;

            YYY = longY(1:lastDataRow, :);

            % nsim = mf_setup.It;% number of draws from Posterior Density
            % nburn = mf_setup.Bu;
            YMC_orig = ones(H,Nm+Nq)*exp(99); %mf_setup.YMC_orig;

            YYcond = YMC_orig;

            YDATA = YYY;
            YM = YDATA(:,1:Nm);
            YQ = YDATA(:,Nm+1:end);

            exc = isnan(YMC_orig);

            nv = Nm+Nq;

            Tstar = size(YM,1);                   % T star is the length of the M dataset from the beginning (like T but without accounting for the n_lags that have to be discarded)
            T = size(YQ(~isnan(YQ)),1);                   % T is the lenght of Q from the beginning (like T_b but without accounting for the n_lags that have to be discarded)

            nlags_ = numLags;                  % number of lags
            T0 = nlags_;             % size of pre-sample
            nex = const; % meta.NumExogenousNames;% + const;                  % number of exogenous vars;1(=intercept only)

            p = nlags_;
            nlags = p;

            nobs = T-T0;             % dropping the lags for the pre-sample (=nlags)
            Tnew = Tstar-T;          % the
            Tnobs = Tstar-T0;         % This is T in the paper. The full dataset of monthly observations wihtout the lagged values

            % for writing to a forecast w/ history file

            % YMh = YYY(T0+1:end-3,1:Nm);

            % create index: 1 indicates NaN
            index_NY = isnan(YDATA(nobs+T0+1:Tnobs+T0,:))';        % this is a transposed version of the missing obs

            %%
            %======================================================================
            %                     BLOCK 1: PARAMETER ESTIMATION
            %======================================================================

            % Matrices for collecting draws from Posterior Density

            Sigmap = zeros(nv,nv);       % SIGMA in eq (1)
            Phip = zeros(nv*p+nex,nv);   % PHI in eq (2)
            % Cons = zeros(1,nv);          % ???
            % lstate = zeros(Nq,Tnobs);    % Tnobs = usable monthly observations
            YYactsim = zeros(4,nv);
            XXactsim = zeros(4,nv*p+nex);
            YY_past_forfcast = zeros(Tstar,nv);

            At_mat = zeros(Tnobs,Nq*(p+1));
            % mine
            Pt_mat_alt = zeros((Nq*(p+1)),(Nq*(p+1)),Tnobs);
            Atildemat = zeros(1,Nq*(p+1));
            Ptildemat = zeros(Nq*(p+1),Nq*(p+1));


            %% Define phi, phi(mm), phi(mq), phi(mc) used in alt ss rep -- eq (9)
            phi_mm = zeros(Nm*p,Nm);            % He transposes it later
            phi_mm(1:Nm,1:Nm)=eye(Nm);
            phi_mq = zeros(Nq*p,Nm);
            phi_mc = zeros(1,Nm);               % He transposes it later
            phi_qc = zeros(1,Nq);
            Phi = [0.95*eye(Nm+Nq);zeros((Nm+Nq)*(p-1)+1,(Nm+Nq))];

            % Define Transition Equation Matrices in eq (10) / A-9
            GAMMAs = zeros(Nq*(p+1),Nq*(p+1));               % GAMMAs has the dimension Nq*(p+1) as in the paper eq. A-9
            IQ = eye(Nq);
            for i=1:p
                GAMMAs(i*Nq+1:(i+1)*Nq,(i-1)*Nq+1:i*Nq) = IQ;
            end
            GAMMAs(1:Nq,1:Nq) = 0.95*eye(Nq);

            GAMMAz = zeros(Nq*(p+1),Nm*p);
            GAMMAc = zeros(Nq*(p+1),1);
            GAMMAu = [eye(Nq); zeros(p*Nq,Nq)];

            % Define Measurement Equation Matrices in eq (15) / A-10
            LAMBDAs = [[zeros(Nm,Nq) phi_mq'];(1/3)*[eye(Nq) eye(Nq) eye(Nq) zeros(Nq,Nq*(p-2))]];
            LAMBDAz = [phi_mm'; zeros(Nq,p*Nm)];
            LAMBDAc = [phi_mc'; zeros(Nq,1)];
            LAMBDAu = [eye(Nm); zeros(Nq,Nm)];

            % Define Covariance Terms sig_mm, sig_mq_sig_qm, siq_qq
            sigma = (1e-4)*eye(Nm+Nq);
            sig_mm = sigma(1:Nm,1:Nm);
            sig_mq = sigma(1:Nm,Nm+1:end);
            sig_qm = sigma(Nm+1:end,1:Nm);
            sig_qq = sigma(Nm+1:end,Nm+1:end);

            % Define W matrix in eq (15) -- _t for tilde
            Wmatrix = [eye(Nm) zeros(Nm,Nq)];
            LAMBDAs_t = Wmatrix * LAMBDAs;
            LAMBDAz_t = Wmatrix * LAMBDAz;
            LAMBDAc_t = Wmatrix * LAMBDAc;
            LAMBDAu_t = Wmatrix * LAMBDAu;
            %% Initialization
            At = zeros(Nq*(p+1),1);                   %At will contain the latent states, s_t
            Pt = zeros(Nq*(p+1),Nq*(p+1));

            % Here we do an initialization on the pre-sample. We use the posterior
            % means of the Gamma matrices. This is discussed in section A.2 in the online appendix.
            % This is simply Kalman filter equation for the Variance
            for kk=1:5
                Pt = GAMMAs * Pt * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
            end

            % Lagged Monthly Observations
            Zm = zeros(nobs,Nm*p);
            i=1;
            while i<=p
                Zm(:,(i-1)*Nm+1:i*Nm) = YM(T0-(i-1):T0+nobs-i,:);
                i=i+1;
            end

            % Observations in Monthly Freq
            Yq = YQ(T0+1:nobs+T0,:);
            Ym = YM(T0+1:nobs+T0,:);

            At_draw = zeros(nobs, Nq*(p+1));
            Pmean = [];

            justInitialized = true;


            function sample = sampler()

                j = 1; %fix to one

                if ~justInitialized
                    At = transpose(At_draw(1, :));
                    Pt = Pmean;
                end
                justInitialized = false;

                % Kalman Filter loop
                for t = 1:nobs            % note that t=T0+t originally

                    if ((t+T0)/3)-floor((t+T0)/3)==0

                        At1 = At;
                        Pt1 = Pt;

                        % Forecasting
                        alphahat = GAMMAs * At1 + GAMMAz * Zm(t,:)' + GAMMAc;
                        Phat = GAMMAs * Pt1 * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
                        Phat = 0.5*(Phat+Phat');

                        yhat = LAMBDAs * alphahat + LAMBDAz * Zm(t,:)' + LAMBDAc;
                        nut = [Ym(t,:)'; Yq(t,:)'] - yhat;

                        Ft = LAMBDAs * Phat * LAMBDAs' + LAMBDAu * sig_mm * LAMBDAu'...
                            + LAMBDAs*GAMMAu*sig_qm*LAMBDAu'...
                            + LAMBDAu*sig_mq*GAMMAu'*LAMBDAs';
                        Ft = 0.5*(Ft+Ft');
                        Xit = LAMBDAs * Phat + LAMBDAu * sig_mq * GAMMAu';

                        At = alphahat + Xit'/Ft * nut;
                        Pt = Phat     - Xit'/Ft * Xit;

                        At_mat(t,:) = At';
                        % boris
                        Pt_mat_alt(:,:,t) = Pt;

                    else

                        At1 = At;
                        Pt1 = Pt;

                        % Forecasting
                        alphahat = GAMMAs * At1 + GAMMAz * Zm(t,:)' + GAMMAc;
                        Phat = GAMMAs * Pt1 * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
                        Phat = 0.5*(Phat+Phat');

                        yhat = LAMBDAs_t * alphahat + LAMBDAz_t * Zm(t,:)' + LAMBDAc_t;
                        nut = Ym(t,:)' - yhat;

                        Ft = LAMBDAs_t * Phat * LAMBDAs_t' + LAMBDAu_t * sig_mm * LAMBDAu_t'...
                            + LAMBDAs_t*GAMMAu*sig_qm*LAMBDAu_t'...
                            + LAMBDAu_t*sig_mq*GAMMAu'*LAMBDAs_t';
                        Ft = 0.5*(Ft+Ft');
                        Xit = LAMBDAs_t * Phat + LAMBDAu_t * sig_mq * GAMMAu';

                        At = alphahat + Xit'/Ft * nut;
                        Pt = Phat     - Xit'/Ft * Xit;

                        At_mat(t,:) = At';
                        % mine
                        Pt_mat_alt(:,:,t) = Pt;
                    end

                end

                Atildemat(:) = At_mat(nobs,:);
                % mine
                Pt_last_alt = Pt_mat_alt(:,:,nobs);
                Ptildemat(:,:) = Pt_last_alt;

                %% unbalanced dataset

                kn = nv*(p+1);

                % Measurement Equation
                Z1 = zeros(Nm,kn);
                Z1(:,1:Nm) = eye(Nm);

                Z2 = zeros(Nq,kn);
                for bb=1:Nq
                    for ll=1:3
                        Z2(bb,ll*Nm+(ll-1)*Nq+bb)=1/3;
                    end
                end
                ZZ = [Z1;Z2];

                BAt = [];
                for rr=1:p+1
                    BAt=[BAt;[Ym(end-rr+1,:) squeeze(Atildemat(j,(rr-1)*Nq+1:rr*Nq))]'];
                end

                BPt = zeros(kn,kn);
                for rr=1:p+1
                    for vv=1:p+1
                        BPt(rr*Nm+(rr-1)*Nq+1:rr*(Nm+Nq),vv*Nm+(vv-1)*Nq+1:vv*(Nm+Nq))=...
                            squeeze(Ptildemat((rr-1)*Nq+1:rr*Nq,(vv-1)*Nq+1:vv*Nq));
                    end
                end

                BAt_mat=zeros(Tnobs,kn);
                %   mine
                BPt_mat_alt = zeros(kn,kn,Tnobs);


                BAt_mat(nobs,:) = BAt;
                % mine
                BPt_mat_alt(:,:,nobs) = BPt;

                % Define Companion Form Matrix PHIF
                PHIF = zeros(kn,kn);
                IF = eye(nv);
                for i=1:p
                    PHIF(i*nv+1:(i+1)*nv,(i-1)*nv+1:i*nv) = IF;
                end
                PHIF(1:nv,1:nv*p) = Phi(1:end-1,:)';

                % Define Constant Term CONF
                CONF = [Phi(end,:)';zeros(nv*p,1)];

                % Define Covariance Term SIGF
                SIGF = zeros(kn,kn);
                SIGF(1:nv,1:nv) = sigma;

                % Filter loop
                for t = nobs+1:Tnobs

                    % New indicator
                    kkk = t-nobs;

                    % Define New Data (ND) and New Z matrix (NZ)
                    ND = [bear.delif(YDATA(nobs+T0+kkk,:)',index_NY(:,kkk))];       % deletes the missing obs, the NaN values
                    NZ = bear.delif(ZZ,index_NY(:,kkk));

                    BAt1 = BAt;
                    BPt1 = BPt;

                    % Forecasting
                    Balphahat = PHIF * BAt1 + CONF;
                    BPhat = PHIF * BPt1 * PHIF' + SIGF;
                    BPhat = 0.5*(BPhat+BPhat');

                    Byhat = NZ*Balphahat;
                    Bnut = ND - Byhat;

                    BFt = NZ*BPhat*NZ';
                    BFt = 0.5*(BFt+BFt');

                    % Updating
                    BAt = Balphahat + (BPhat*NZ')/BFt*Bnut;
                    BPt = BPhat - (BPhat*NZ')/BFt*(BPhat*NZ')';
                    BAt_mat(t,:) = BAt';
                    % mine
                    BPt_mat_alt(:,:,t) = BPt;

                end

                AT_draw = zeros(Tnew+1,kn);

                % singular value decomposition
                % boris
                [u, s, ~] = svd(BPt_mat_alt(:,:,Tnobs));
                Pchol = u*sqrt(s);
                AT_draw(end,:) = BAt_mat(Tnobs,:)+(Pchol*randn(kn,1))';


                % Kalman Smoother
                for i = 1:Tnew

                    BAtt = BAt_mat(Tnobs-i,:)';
                    % mine
                    BPtt = BPt_mat_alt(:,:,Tnobs-i);

                    BPhat = PHIF * BPtt * PHIF' + SIGF;
                    BPhat = 0.5*(BPhat+BPhat');

                    [up, sp, vp] = svd(BPhat);
                    inv_sp = zeros(size(sp,1),size(sp,1));
                    % boris
                    inv_sp(sp>1e-12) = 1./sp(sp>1e-12);

                    inv_BPhat = up*inv_sp*vp';

                    Bnut = AT_draw(end-i+1,:)'-PHIF*BAtt -CONF;

                    Amean = BAtt + (BPtt*PHIF')*inv_BPhat*Bnut;
                    Pmean = BPtt - (BPtt*PHIF')*inv_BPhat*(BPtt*PHIF')';

                    % singular value decomposition
                    [um, sm, ~] = svd(Pmean);
                    Pmchol = um*sqrt(sm);
                    AT_draw(end-i,:) = (Amean+Pmchol*randn(kn,1))';

                end


                %% balanced dataset

                for kk=1:p+1
                    At_draw(nobs,(kk-1)*Nq+1:kk*Nq) = ...
                        AT_draw(1,kk*Nm+(kk-1)*Nq+1:kk*(Nm+Nq));
                end

                % Kalman Smoother
                for i = 1:nobs-1

                    Att = At_mat(nobs-i,:)';
                    % boris
                    Ptt = Pt_mat_alt(:,:,nobs-i);

                    Phat = GAMMAs * Ptt * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
                    Phat = 0.5*(Phat+Phat');

                    [up, sp, vp] = svd(Phat);
                    inv_sp = zeros(size(sp,1),size(sp,1));
                    % boris
                    inv_sp(sp>1e-12) = 1./sp(sp>1e-12);
                    inv_Phat = up*inv_sp*vp';

                    nut = At_draw(nobs-i+1,:)'-GAMMAs * Att - GAMMAz * Zm(nobs-i,:)'- GAMMAc;

                    Amean = Att + (Ptt*GAMMAs')*inv_Phat*nut;
                    Pmean = Ptt - (Ptt*GAMMAs')*inv_Phat*(Ptt*GAMMAs')';

                    % singular value decomposition
                    [um, sm, ~] = svd(Pmean);
                    Pmchol = um*sqrt(sm);
                    At_draw(nobs-i,:) = (Amean+Pmchol*randn(Nq*(p+1),1))';
                end

                %======================================================================
                %                     BLOCK 2: MINNESOTA PRIOR
                %======================================================================

                % update Dataset YY
                YY = [[Ym At_draw(:,1:Nq)];...
                    AT_draw(2:end,1:(Nm+Nq))];
                % save latent states
                %for hh=1:Nq
                %    lstate(hh,1:nobs)=At_draw(:,hh);
                %    lstate(hh,nobs+1:end)=AT_draw(2:end,Nm+hh);
                %end

                nobs_ = size(YY,1)-T0;
                spec = [nlags_ T0 nex nv nobs_];

                % dummy observations and actual observations
                [~,YYact,YYdum,XXact,XXdum]=bear.vm_mdd_mine(hyp,YY,spec,0);

                YYactsim(:,:) = YYact(end-3:end,:);
                XXactsim(:,:) = XXact(end-3:end,:);
                YY_past_forfcast(:,:) = [YYY(1:p,:); YY(1:p,:); YYact];
                % YYact(end-p+1:end,:);

                % draws from posterior distribution
                [Tdummy,~] = size(YYdum);
                [Tobs,n] = size(YYact);
                X = [XXact; XXdum];
                Y = [YYact; YYdum];
                p = spec(1);                 % Number of lags in the VAR
                T = Tobs+Tdummy;             % Number of observations

                [vl,d,vr] = svd(X,0);
                di = 1../diag(d);
                B = vl'*Y;
                xxi = vr.*repmat(di',n*p+1,1);
                inv_x = xxi*xxi';
                Phi_tilde = (vr.*repmat(di',n*p+1,1))*B;
                Sigma = (Y-X*Phi_tilde)'*(Y-X*Phi_tilde);

                invSigma = Sigma\eye(n);
                inv_draw = bear.wish(invSigma,T-n*p-1);
                sigma = inv_draw\eye(n);

                % Draws from the density vec(Phi) |Sigma(j), Y
                phi_new = mvnrnd(reshape(Phi_tilde,n*(n*p+1),1),kron(sigma,inv_x));

                % Rearrange vec(Phi) into Phi
                Phi = reshape(phi_new,n*p+1,n);

                Sigmap(:,:) = sigma;
                Phip(:,:) = Phi;
                % Cons(:) = Phi(end,:);

                % Define phi(qm), phi(qq), phi(qc)
                phi_qm = zeros(Nm*p,Nq);
                for i=1:p
                    phi_qm(Nm*(i-1)+1:Nm*i,:)=Phi((i-1)*(Nm+Nq)+1:(i-1)*(Nm+Nq)+Nm,Nm+1:end);
                end
                phi_qq = zeros(Nq*p,Nq);
                for i=1:p
                    phi_qq(Nq*(i-1)+1:Nq*i,:)=Phi((i-1)*(Nm+Nq)+Nm+1:i*(Nm+Nq),Nm+1:end);
                end
                phi_qc = Phi(end,Nm+1:end);

                % Define phi(mm), phi(mq), phi(mc)
                phi_mm = zeros(Nm*p,Nm);
                for i=1:p
                    phi_mm(Nm*(i-1)+1:Nm*i,:)=Phi((i-1)*(Nm+Nq)+1:(i-1)*(Nm+Nq)+Nm,1:Nm);
                end
                phi_mq = zeros(Nq*p,Nm);
                for i=1:p
                    phi_mq(Nq*(i-1)+1:Nq*i,:)=Phi((i-1)*(Nm+Nq)+Nm+1:i*(Nm+Nq),1:Nm);
                end
                phi_mc = Phi(end,1:Nm);

                % Define Covariance Term sig_mm, sig_mq, sig_qm, sig_qq
                sig_mm = sigma(1:Nm,1:Nm);
                sig_mq = 0.5*(sigma(1:Nm,Nm+1:end)+sigma(Nm+1:end,1:Nm)');
                sig_qm = 0.5*(sigma(Nm+1:end,1:Nm)+sigma(1:Nm,Nm+1:end)');
                sig_qq = sigma(Nm+1:end,Nm+1:end);

                % Define Transition Equation Matrices
                GAMMAs = [[phi_qq' zeros(Nq,Nq)];[eye(p*Nq,p*Nq) zeros(p*Nq,Nq)]];
                GAMMAz = [phi_qm'; zeros(p*Nq,p*Nm)];
                GAMMAc = [phi_qc'; zeros(p*Nq,1)];
                GAMMAu = [eye(Nq); zeros(p*Nq,Nq)];

                % Define Measurement Equation Matrices
                LAMBDAs = [[zeros(Nm,Nq) phi_mq'];(1/3)*[eye(Nq) eye(Nq) eye(Nq) zeros(Nq,Nq*(p-2))]];
                LAMBDAz = [phi_mm'; zeros(Nq,p*Nm)];
                LAMBDAc = [phi_mc'; zeros(Nq,1)];
                LAMBDAu = [eye(Nm); zeros(Nq,Nm)];

                LAMBDAs_t = Wmatrix * LAMBDAs;
                LAMBDAz_t = Wmatrix * LAMBDAz;
                LAMBDAc_t = Wmatrix * LAMBDAc;
                LAMBDAu_t = Wmatrix * LAMBDAu;

                % Save the Posterior Distributions
                %======================================================================
                %                     BLOCK 3: FORECASTING
                %======================================================================

                % store forecasts in monthly frequency
                % YYvector_ml = zeros(H,Nm+Nq);     % collects now/forecast
                % YYvector_mg = zeros(H,Nm+Nq);
                % YYvector_m0 = zeros(H,nv);
                % store forecasts in quarterly frequency
%                 YYvector_ql = zeros(floor(H/3),Nm+Nq);
%                 YYvector_qg = zeros(floor(H/3),Nm+Nq);

                YYact_s = squeeze(YYactsim(end,:))';
                XXact_s = squeeze(XXactsim(end,:))';
                post_phi = squeeze(Phip(:,:));
                post_sig = squeeze(Sigmap(:,:));

                %==========================================================================
                %              BAYESIAN ESTIMATION: FORECASTING
                %==========================================================================

                YYpred = zeros(H+1,nv);     % forecasts from VAR
                YYpred(1,:) = YYact_s;
                XXpred = zeros(H+1,(nv)*nlags+1);
                XXpred(:,end) = ones(H+1,1);
                XXpred(1,:) = XXact_s;

                %==========================================================================
                %          given posterior draw, draw #{H+1} random sequence
                %==========================================================================

                error_pred = zeros(H+1,nv);

                for h=1:H+1
                    error_pred(h,:) = mvnrnd(zeros(nv,1), post_sig);

                end

                %==========================================================================
                %       given posterior draw, iterate forward to construct forecasts
                %==========================================================================

                for h=2:H+1

                    XXpred(h,nv+1:end-1) = XXpred(h-1,1:end-nv-1);
                    XXpred(h,1:nv) = YYpred(h-1,:);
                    YYpred(h,:) = (1-exc(h-1,:)).*(XXpred(h,:)*post_phi+error_pred(h,:)) + ...
                        exc(h-1,:).*YYcond(h-1,:);

                end

                % YYpred1 = YYpred;                       % This is the balanced forecast
                % YYpred = YYpred(2:end,:);              % we throw out the first because earlier we have YYpred(1,:) = YYact;

                %% Now-/Forecasts
                % store in monthly frequency
                % YYvector_ml(:,:) = YYpred;
                % YYvector_mg(:,:) = 100*(YYpred1(2:end,:)-YYpred1(1:end-1,:));
                % store forecasts in quarterly frequency
                % for ll=1:(H/3)-1
                %     YYvector_ql(ll+1,:) = ...
                %         mean(YYvector_ml(3*ll+1-Tnew:3*(ll+1)-Tnew,:));
                % end

                % store nowcasts in quarterly frequency
                % YYnow=squeeze(YYactsim(end-Tnew+1:end,:));

                % if size(YYnow,2) ~= Nm+Nq
                %     YYnow = YYnow';
                % end
                % YYfuture = YYpred(1:3-Tnew,:);

%                 if Tnew==3
%                     YYvector_ql(1,:) = mean(YYnow);
%                 else
%                     YYvector_ql(1,:) = mean([YYnow;YYfuture]);
%                 end

%                 YYvector_qg(1,:) = ...
%                     100*(squeeze(YYvector_ql(1,:))- mean([Ym(end-2:end,:) Yq(end-2:end,:)])');
%                 for bb=2:H/3
%                     YYvector_qg(bb,:) = ...
%                         100*(squeeze(YYvector_ql(bb,:))-squeeze(YYvector_ql(bb-1,:)));
%                 end

                sample = struct();
                sample.beta = reshape(Phip,(nv*p+nex)*nv,1);
                sample.sigma = reshape(Sigmap,nv^2,1);
                sample.initForForfcast = YY_past_forfcast;
                this.SampleCounter = this.SampleCounter + 1;
            end%


            this.Sampler = @sampler;
            %]
        end

        function createDrawers(this, meta)
            %[
            numEndog = meta.NumEndogenousConcepts;
            numRowsA = numEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numRowsB = numRowsA + numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);

            function [A, C] = betaDrawer(sample, horizon)
                beta = reshape(sample.beta, numRowsB, numEndog);
                A = beta(1:numRowsA,:);
                C = beta(numRowsA+1:end,:);
                if horizon > 0
                    A = wrap(A, horizon);
                    C = wrap(C, horizon);
                end
            end%

            function sigma = sigmaDrawer(sample, horizon)
                sigma = reshape(sample.sigma, numEndog, numEndog);
                if horizon > 0
                    sigma = wrap(sigma, horizon);
                end
            end%

            function draw = identificationDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, identificationHorizon);
                draw.Sigma = sigmaDrawer(sample, 0);
            end%

            function draw = unconditionalDrawer(sample, startIndex, forecastHorizon)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, forecastHorizon);
                draw.Sigma = sigmaDrawer(sample, forecastHorizon);
            end%

            function draw = historyDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, estimationHorizon);
                draw.Sigma = sigmaDrawer(sample, estimationHorizon);
            end%

            function draw = conditionalDrawer(sample, startIndex, forecastHorizon)
                draw = struct();
                draw.beta = wrap(sample.beta, forecastHorizon);
            end%

            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%

    end

end

