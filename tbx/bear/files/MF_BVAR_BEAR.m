function Output = MF_BVAR_BEAR(mf_setup)

YYY      = mf_setup.data;
Nm       = mf_setup.Nm;
Nq       = mf_setup.Nq;
% YM0_orig = Input.YM0_orig;
% YMC_orig = Input.YMC_orig;
% YQ0_orig = Input.YQ0_orig;
% select_m = Input.select_m;
% select_q = Input.select_q;
H        = mf_setup.H;
nsim     = mf_setup.It;% number of draws from Posterior Density
nburn    = mf_setup.Bu;
stattool = 0;
hyp      = mf_setup.hyp;
YMC_orig      = mf_setup.YMC_orig;

% select    = [select_m select_q];
select    = mf_setup.select;
select_m  = select(1,1:Nm);
select_q  = select(1,Nm+1:end);
% select_c  = (-1)*(select-ones(1,size(select,2)));

% This is where the transformation is happening.
% YM0(:,select_m==1) = YM0_orig(:,select_m==1)./100;
% YM0(:,select_m==0) = log(YM0_orig(:,select_m==0));
% YQ0(:,select_q==1) = YQ0_orig(:,select_q==1)./100;
% YQ0(:,select_q==0) = log(YQ0_orig(:,select_q==0));

% YMC(:,select==1) = YMC_orig(:,select==1)./100;
% YMC(:,select==0) = log(YMC_orig(:,select==0));
%YMC(:,select==0 & exc(h,:)) = log(YMC(:,select==0));
YYcond      = YMC_orig;

YDATA = YYY;
% YDATA(:,select == 1) = YDATA(:,select == 1)./100;
% YDATA(:,select == 0) = log(YDATA(:,select == 0));

YM            = YDATA(:,1:Nm);
YQ            = YDATA(:,Nm+1:end);

% exc = YMC_orig < exp(99);
exc = isnan(YMC_orig);


% YM          = YM0;
% YQ          = kron(YQ0,ones(3,1));          % YQ is the quarterly vector with each entry times 3

% Nm          = size(YM,2);
% Nq          = size(YQ,2);
nv          = Nm+Nq;

Tstar       = mf_setup.T_m;                   % T star is the length of the M dataset from the beginning (like T but without accounting for the n_lags that have to be discarded)
T           = mf_setup.T_b;                   % T is the lenght of Q from the beginning (like T_b but without accounting for the n_lags that have to be discarded)
% YDATA       = nan(Tstar,nv);
% YDATA(:,1:Nm) = YM;
% YDATA(1:T,Nm+1:end) = YQ;

nlags_  = mf_setup.lags;                  % number of lags
T0      = nlags_;             % size of pre-sample
nex     = mf_setup.nex;                  % number of exogenous vars;1(=intercept only)
p       = nlags_;
nlags   = p;

kq      = Nq*p;
nobs    = T-T0;             % dropping the lags for the pre-sample (=nlags)
Tnew    = Tstar-T;          % the
Tnobs   = Tstar-T0;         % This is T in the paper. The full dataset of monthly observations wihtout the lagged values

% for writing to a forecast w/ history file

YMh      = YYY(T0+1:end-3,1:Nm);
% varstxt  = [YMX(1,2:Nm+1) YQX(1,2:Nq+1)];
% smpltxt  = YMX(T0+2:end,1);

% create index: 1 indicates NaN
index_NY  = isnan(YDATA(nobs+T0+1:Tnobs+T0,:))';        % this is a transposed version of the missing obs

%%
% if ~(H==size(YMC,1))
%     disp('The forecast horizon H and the conditional forecast matrix are incompatible')
%     return
% end

disp('                                                                ');
disp('                    MIXED FREQUENCY VAR: ESTIMATION             ');
disp('                                                                ');
disp('                          - BLOCK ALGORITHM (1)-                ');
disp('                                                                ');
disp('                PARAMETER ESTIMATION WITH BALANCED PANEL        ');
disp('                                                                ');
%======================================================================
%                     BLOCK 1: PARAMETER ESTIMATION
%======================================================================

% Matrices for collecting draws from Posterior Density

Sigmap    = zeros(nsim-nburn,nv,nv);       % SIGMA in eq (1)
Phip      = zeros(nsim-nburn,nv*p+nex,nv);   % PHI in eq (2)
Cons      = zeros(nsim-nburn,nv);          % ???
lstate    = zeros(nsim-nburn,Nq,Tnobs);    % Tnobs = usable monthly observations
YYactsim  = zeros(nsim-nburn,4,nv);
XXactsim  = zeros(nsim-nburn,4,nv*p+nex);
YY_past_forfcast  = zeros(p,nv,nsim-nburn);

At_mat    = zeros(Tnobs,Nq*(p+1));
%orig
% Pt_mat    = zeros(Tnobs,(Nq*(p+1))^2);
% mine
Pt_mat_alt    = zeros((Nq*(p+1)),(Nq*(p+1)),Tnobs);
Atildemat = zeros(nsim,Nq*(p+1));
Ptildemat = zeros(nsim,Nq*(p+1),Nq*(p+1));
loglh   = 0;
counter = 0;


%% Define phi, phi(mm), phi(mq), phi(mc) used in alt ss rep -- eq (9)
phi_mm = zeros(Nm*p,Nm);            % He transposes it later
phi_mm(1:Nm,1:Nm)=eye(Nm);
phi_mq = zeros(Nq*p,Nm);
phi_mc = zeros(1,Nm);               % He transposes it later
phi_qc = zeros(1,Nq);
Phi    = [0.95*eye(Nm+Nq);zeros((Nm+Nq)*(p-1)+1,(Nm+Nq))];

% Define Transition Equation Matrices in eq (10) / A-9
GAMMAs        = zeros(Nq*(p+1),Nq*(p+1));               % GAMMAs has the dimension Nq*(p+1) as in the paper eq. A-9
IQ            = eye(Nq);
for i=1:p
    GAMMAs(i*Nq+1:(i+1)*Nq,(i-1)*Nq+1:i*Nq) = IQ;
end
GAMMAs(1:Nq,1:Nq)  = 0.95*eye(Nq);

GAMMAz        = zeros(Nq*(p+1),Nm*p);
GAMMAc        = zeros(Nq*(p+1),1);
GAMMAu        = [eye(Nq); zeros(p*Nq,Nq)];

% Define Measurement Equation Matrices in eq (15) / A-10
LAMBDAs = [[zeros(Nm,Nq) phi_mq'];(1/3)*[eye(Nq) eye(Nq) eye(Nq) zeros(Nq,Nq*(p-2))]];
LAMBDAz = [phi_mm'; zeros(Nq,p*Nm)];
LAMBDAc = [phi_mc'; zeros(Nq,1)];
LAMBDAu = [eye(Nm); zeros(Nq,Nm)];

% Define Covariance Terms sig_mm, sig_mq_sig_qm, siq_qq
sigma   = (1e-4)*eye(Nm+Nq);
sig_mm  = sigma(1:Nm,1:Nm);
sig_mq  = sigma(1:Nm,Nm+1:end);
sig_qm  = sigma(Nm+1:end,1:Nm);
sig_qq  = sigma(Nm+1:end,Nm+1:end);

% Define W matrix in eq (15) -- _t for tilde
Wmatrix   = [eye(Nm) zeros(Nm,Nq)];
LAMBDAs_t = Wmatrix * LAMBDAs;
LAMBDAz_t = Wmatrix * LAMBDAz;
LAMBDAc_t = Wmatrix * LAMBDAc;
LAMBDAu_t = Wmatrix * LAMBDAu;
%% Initialization
At   = zeros(Nq*(p+1),1);                   %At will contain the latent states, s_t
Pt   = zeros(Nq*(p+1),Nq*(p+1));

% Here we do an initialization on the pre-sample. We use the posterior
% means of the Gamma matrices. This is discussed in section A.2 in the online appendix.
% This is simply Kalman filter equation for the Variance
for kk=1:5
    Pt = GAMMAs * Pt * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
end

% Lagged Monthly Observations
Zm   = zeros(nobs,Nm*p);
i=1;
while i<=p
    Zm(:,(i-1)*Nm+1:i*Nm) = YM(T0-(i-1):T0+nobs-i,:);
    i=i+1;
end

% Observations in Monthly Freq
Yq   = YQ(T0+1:nobs+T0,:);
Ym   = YM(T0+1:nobs+T0,:);

%% Estimation

%======================================================================
%                     BLOCK 2: Kalman filtering
%======================================================================

% Block Algorithm
for j=1:nsim
    
    counter         = counter +1;
    
    if counter==5000
        disp('                                                               ');
        disp('                                                               ');
        disp(['                          DRAW NUMBER:   ', num2str(j)]        );
        disp('                                                               ');
        disp(['                          REMAINING DRAWS:   ',num2str(nsim-j)]);
        disp('                                                               ');
        
        counter = 0;
    end
    
    % Initialization
    if j>1
        At   = At_draw(1,:)';
        Pt   = Pmean;
    end
    
    % Kalman Filter loop
    for t = 1:nobs            % note that t=T0+t originally
        
        if ((t+T0)/3)-floor((t+T0)/3)==0
            
            At1 = At;
            Pt1 = Pt;
            
            % Forecasting
            alphahat = GAMMAs * At1 + GAMMAz * Zm(t,:)' + GAMMAc;
            Phat     = GAMMAs * Pt1 * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
            Phat     = 0.5*(Phat+Phat');
            
            yhat     = LAMBDAs * alphahat + LAMBDAz * Zm(t,:)' + LAMBDAc;
            nut      = [Ym(t,:)'; Yq(t,:)'] - yhat;
            
            Ft       = LAMBDAs * Phat * LAMBDAs' + LAMBDAu * sig_mm * LAMBDAu'...
                + LAMBDAs*GAMMAu*sig_qm*LAMBDAu'...
                + LAMBDAu*sig_mq*GAMMAu'*LAMBDAs';
            Ft       = 0.5*(Ft+Ft');
            Xit      = LAMBDAs * Phat + LAMBDAu * sig_mq * GAMMAu';
            
            %At       = alphahat + Xit' * inv(Ft) * nut;
            At       = alphahat + Xit'/Ft * nut;
            %Pt       = Phat     - Xit' * inv(Ft) * Xit;
            Pt       = Phat     - Xit'/Ft * Xit;
            
            At_mat(t,:)  = At';
            % orig
            %             Pt_mat(t,:)  = reshape(Pt,1,(Nq*(p+1))^2);
            % boris
            Pt_mat_alt(:,:,t)  = Pt;
            
        else
            
            At1 = At;
            Pt1 = Pt;
            
            % Forecasting
            alphahat = GAMMAs * At1 + GAMMAz * Zm(t,:)' + GAMMAc;
            Phat     = GAMMAs * Pt1 * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
            Phat     = 0.5*(Phat+Phat');
            
            yhat     = LAMBDAs_t * alphahat + LAMBDAz_t * Zm(t,:)' + LAMBDAc_t;
            nut      = Ym(t,:)' - yhat;
            
            Ft       = LAMBDAs_t * Phat * LAMBDAs_t' + LAMBDAu_t * sig_mm * LAMBDAu_t'...
                + LAMBDAs_t*GAMMAu*sig_qm*LAMBDAu_t'...
                + LAMBDAu_t*sig_mq*GAMMAu'*LAMBDAs_t';
            Ft       = 0.5*(Ft+Ft');
            Xit      = LAMBDAs_t * Phat + LAMBDAu_t * sig_mq * GAMMAu';
            
            At       = alphahat + Xit'/Ft * nut;
            Pt       = Phat     - Xit'/Ft * Xit;
            
            At_mat(t,:)  = At';
            % orig
            %             Pt_mat(t,:)  = reshape(Pt,1,(Nq*(p+1))^2);
            % mine
            Pt_mat_alt(:,:,t)  = Pt;
        end
        
    end
    
    Atildemat(j,:) = At_mat(nobs,:);
    % orig
    %     Pt_last  = reshape(Pt_mat(nobs,:),Nq*(p+1),Nq*(p+1));
    % mine
    Pt_last_alt  = Pt_mat_alt(:,:,nobs);
    Ptildemat(j,:,:) = Pt_last_alt;
    
    
    %% unbalanced dataset
    
    kn        = nv*(p+1);
    
    % Measurement Equation
    Z1         = zeros(Nm,kn);
    Z1(:,1:Nm) = eye(Nm);
    
    Z2         = zeros(Nq,kn);
    for bb=1:Nq
        for ll=1:3
            Z2(bb,ll*Nm+(ll-1)*Nq+bb)=1/3;
        end
    end
    ZZ         = [Z1;Z2];
    
    BAt = [];
    for rr=1:p+1
        BAt=[BAt;[Ym(end-rr+1,:) squeeze(Atildemat(j,(rr-1)*Nq+1:rr*Nq))]'];
    end
    
    BPt = zeros(kn,kn);
    for rr=1:p+1
        for vv=1:p+1
            BPt(rr*Nm+(rr-1)*Nq+1:rr*(Nm+Nq),vv*Nm+(vv-1)*Nq+1:vv*(Nm+Nq))=...
                squeeze(Ptildemat(j,(rr-1)*Nq+1:rr*Nq,(vv-1)*Nq+1:vv*Nq));
        end
    end
    
    BAt_mat=zeros(Tnobs,kn);
    %   orig
    %     BPt_mat=zeros(Tnobs,kn^2);
    %   mine
    BPt_mat_alt = zeros(kn,kn,Tnobs);
    
    
    BAt_mat(nobs,:) = BAt;
    % orig
    %     BPt_mat(nobs,:) = reshape(BPt,1,kn^2);
    % mine
    BPt_mat_alt(:,:,nobs) = BPt;
    
    % Define Companion Form Matrix PHIF
    PHIF         = zeros(kn,kn);
    IF           = eye(nv);
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
        ND  = [delif(YDATA(nobs+T0+kkk,:)',index_NY(:,kkk))];       % deletes the missing obs, the NaN values
        NZ  = delif(ZZ,index_NY(:,kkk));
        
        BAt1 = BAt;
        BPt1 = BPt;
        
        % Forecasting
        Balphahat = PHIF * BAt1 + CONF;
        BPhat     = PHIF * BPt1 * PHIF' + SIGF;
        BPhat     = 0.5*(BPhat+BPhat');
        
        Byhat = NZ*Balphahat;
        Bnut  = ND - Byhat;
        
        BFt = NZ*BPhat*NZ';
        BFt = 0.5*(BFt+BFt');
        
        % Updating
        BAt = Balphahat + (BPhat*NZ')/BFt*Bnut;
        BPt = BPhat - (BPhat*NZ')/BFt*(BPhat*NZ')';
        BAt_mat(t,:)  = BAt';
        % orig
        %         BPt_mat(t,:)  = reshape(BPt,1,kn^2);
        % mine
        BPt_mat_alt(:,:,t)  = BPt;
        
    end
    
    AT_draw = zeros(Tnew+1,kn);
    
    % singular value decomposition
    %orig
    %     [u s v] = svd(reshape(BPt_mat(Tnobs,:),kn,kn));
    % boris
    [u, s, v] = svd(BPt_mat_alt(:,:,Tnobs));
    Pchol = u*sqrt(s);
    AT_draw(end,:) = BAt_mat(Tnobs,:)+(Pchol*randn(kn,1))';
    
    
    % Kalman Smoother
    for i = 1:Tnew
        
        BAtt  = BAt_mat(Tnobs-i,:)';
        % orig
        %         BPtt  = reshape(BPt_mat(Tnobs-i,:),kn,kn);
        % mine
        BPtt  = BPt_mat_alt(:,:,Tnobs-i);
        
        BPhat = PHIF * BPtt * PHIF' + SIGF;
        BPhat = 0.5*(BPhat+BPhat');
        
        [up, sp, vp] = svd(BPhat);
        inv_sp = zeros(size(sp,1),size(sp,1));
        % orig
        %         for rr=1:size(sp,1)
        %             if sp(rr,rr)>1e-12;
        %                 inv_sp(rr,rr)=1./sp(rr,rr);
        %             end
        %         end
        % boris
        inv_sp(sp>1e-12) = 1./sp(sp>1e-12);
        
        inv_BPhat = up*inv_sp*vp';
        
        Bnut  = AT_draw(end-i+1,:)'-PHIF*BAtt -CONF;
        
        Amean = BAtt + (BPtt*PHIF')*inv_BPhat*Bnut;
        Pmean = BPtt - (BPtt*PHIF')*inv_BPhat*(BPtt*PHIF')';
        
        % singular value decomposition
        [um, sm, vm] = svd(Pmean);
        Pmchol = um*sqrt(sm);
        AT_draw(end-i,:) = (Amean+Pmchol*randn(kn,1))';
        
    end
    
    
    %% balanced dataset
    
    At_draw = zeros(nobs,Nq*(p+1));
    
    for kk=1:p+1
        At_draw(nobs,(kk-1)*Nq+1:kk*Nq) = ...
            AT_draw(1,kk*Nm+(kk-1)*Nq+1:kk*(Nm+Nq));
    end
    
    % Kalman Smoother
    for i = 1:nobs-1
        
        Att  = At_mat(nobs-i,:)';
        %orig
        %         Ptt  = reshape(Pt_mat(nobs-i,:),Nq*(p+1),Nq*(p+1));
        % boris
        Ptt  = Pt_mat_alt(:,:,nobs-i);
        
        Phat = GAMMAs * Ptt * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
        Phat = 0.5*(Phat+Phat');
        
        [up, sp, vp] = svd(Phat);
        inv_sp = zeros(size(sp,1),size(sp,1));
        % orig
        %         for rr=1:size(sp,1)
        %             if sp(rr,rr)>1e-12;
        %                 inv_sp(rr,rr)=1./sp(rr,rr);
        %             end
        %         end
        % boris
        inv_sp(sp>1e-12) = 1./sp(sp>1e-12);
        inv_Phat = up*inv_sp*vp';
        
        nut  = At_draw(nobs-i+1,:)'-GAMMAs * Att - GAMMAz * Zm(nobs-i,:)'- GAMMAc;
        
        Amean = Att + (Ptt*GAMMAs')*inv_Phat*nut;
        Pmean = Ptt - (Ptt*GAMMAs')*inv_Phat*(Ptt*GAMMAs')';
        
        % singular value decomposition
        [um, sm, vm] = svd(Pmean);
        Pmchol = um*sqrt(sm);
        At_draw(nobs-i,:) = (Amean+Pmchol*randn(Nq*(p+1),1))';
    end
    
    %======================================================================
    %                     BLOCK 2: MINNESOTA PRIOR
    %======================================================================
    
    % update Dataset YY
    YY = [[Ym At_draw(:,1:Nq)];...
        AT_draw(2:end,1:(Nm+Nq))];
    % YY = YY(40:end,:);
    % save latent states
    if j>nburn
        for hh=1:Nq
            lstate(j-nburn,hh,1:nobs)=At_draw(:,hh);
            lstate(j-nburn,hh,nobs+1:end)=AT_draw(2:end,Nm+hh);
        end
    end
    
    nobs_   = size(YY,1)-T0;
    spec    = [nlags_ T0 nex nv nobs_];
    
    % dummy observations and actual observations
    [mdd,YYact,YYdum,XXact,XXdum]=vm_mdd_mine(hyp,YY,spec,0);
    
    if j>nburn
        YYactsim(j-nburn,:,:) = YYact(end-3:end,:);
        XXactsim(j-nburn,:,:) = XXact(end-3:end,:);
        YY_past_forfcast(:,:,j-nburn) = YYact(end-p+1:end,:);
    end
    % draws from posterior distribution
    [Tdummy,~] = size(YYdum);
    [Tobs,n]   = size(YYact);
    X          = [XXact; XXdum];
    Y          = [YYact; YYdum];
    p          = spec(1);                 % Number of lags in the VAR
    T          = Tobs+Tdummy;             % Number of observations
    I          = eye(n);
    
    
    [vl,d,vr] = svd(X,0);
    di        = 1../diag(d);
    B         = vl'*Y;
    xxi       = vr.*repmat(di',n*p+1,1);
    inv_x     = xxi*xxi';
    Phi_tilde = (vr.*repmat(di',n*p+1,1))*B;
    Sigma     = (Y-X*Phi_tilde)'*(Y-X*Phi_tilde);
    
    % Draws from the density Sigma | Y
    if stattool
        sigma      = iwishrnd(Sigma,T-n*p-1);
    else
        invSigma    = Sigma\eye(n);
        inv_draw    = wish(invSigma,T-n*p-1);
        sigma       = inv_draw\eye(n);
    end
    
    % Draws from the density vec(Phi) |Sigma(j), Y
    phi_new = mvnrnd(reshape(Phi_tilde,n*(n*p+1),1),kron(sigma,inv_x));
    
    % Rearrange vec(Phi) into Phi
    Phi     = reshape(phi_new,n*p+1,n);
    if j>nburn
        Sigmap(j-nburn,:,:) = sigma;
        Phip(j-nburn,:,:)   = Phi;
        Cons(j-nburn,:)     = Phi(end,:);
    end
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
    sig_mm  = sigma(1:Nm,1:Nm);
    sig_mq  = 0.5*(sigma(1:Nm,Nm+1:end)+sigma(Nm+1:end,1:Nm)');
    sig_qm  = 0.5*(sigma(Nm+1:end,1:Nm)+sigma(1:Nm,Nm+1:end)');
    sig_qq  = sigma(Nm+1:end,Nm+1:end);
    
    % Define Transition Equation Matrices
    GAMMAs  = [[phi_qq' zeros(Nq,Nq)];[eye(p*Nq,p*Nq) zeros(p*Nq,Nq)]];
    GAMMAz  = [phi_qm'; zeros(p*Nq,p*Nm)];
    GAMMAc  = [phi_qc'; zeros(p*Nq,1)];
    GAMMAu  = [eye(Nq); zeros(p*Nq,Nq)];
    
    % Define Measurement Equation Matrices
    LAMBDAs = [[zeros(Nm,Nq) phi_mq'];(1/3)*[eye(Nq) eye(Nq) eye(Nq) zeros(Nq,Nq*(p-2))]];
    LAMBDAz = [phi_mm'; zeros(Nq,p*Nm)];
    LAMBDAc = [phi_mc'; zeros(Nq,1)];
    LAMBDAu = [eye(Nm); zeros(Nq,Nm)];
    
    LAMBDAs_t = Wmatrix * LAMBDAs;
    LAMBDAz_t = Wmatrix * LAMBDAz;
    LAMBDAc_t = Wmatrix * LAMBDAc;
    LAMBDAu_t = Wmatrix * LAMBDAu;
    
end



% Save the Posterior Distributions
%======================================================================
%                     BLOCK 3: FORECASTING
%======================================================================
disp('                                                                ');
disp('                                                                ');
disp('                                                                ');
disp('                    MIXED FREQUENCY VAR: FORECASTING            ');
disp('                                                                ');
disp('                          - BLOCK ALGORITHM (2)-                ');
disp('                                                                ');
disp('                                                                ');
disp('                                                                ');

% store forecasts in monthly frequency
YYvector_ml  = zeros(nsim-nburn,H,Nm+Nq);     % collects now/forecast
YYvector_mg  = zeros(nsim-nburn,H,Nm+Nq);
YYvector_m0  = zeros(nsim-nburn,H,nv);
% store forecasts in quarterly frequency
YYvector_ql  = zeros(nsim-nburn,floor(H/3),Nm+Nq);
YYvector_qg  = zeros(nsim-nburn,floor(H/3),Nm+Nq);

counter   = 0;

for jj=1:nsim-nburn
    
    YYact_s    = squeeze(YYactsim(jj,end,:));
    XXact_s    = squeeze(XXactsim(jj,end,:));
    post_phi = squeeze(Phip(jj,:,:));
    post_sig = squeeze(Sigmap(jj,:,:));
    
    %==========================================================================
    %              BAYESIAN ESTIMATION: FORECASTING
    %==========================================================================
    
    YYpred              = zeros(H+1,nv);     % forecasts from VAR
    YYpred(1,:)         = YYact_s;
    XXpred              = zeros(H+1,(nv)*nlags+1);
    XXpred(:,end)       = ones(H+1,1);
    XXpred(1,:)         = XXact_s;
    
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
        XXpred(h,1:nv)       = YYpred(h-1,:);
        YYpred(h,:)          = (1-exc(h-1,:)).*(XXpred(h,:)*post_phi+error_pred(h,:)) + ...
            exc(h-1,:).*YYcond(h-1,:);
        
    end
    
    YYpred1     = YYpred;                       % This is the balanced forecast
    YYpred      = YYpred(2:end,:);              % we throw out the first because earlier we have YYpred(1,:)         = YYact;
    
    
    
    counter         = counter + 1;
    
    if  counter==1000
        disp('                                                              ');
        disp(['                FORECAST HORIZON:   ', num2str(H)]            );
        disp('                                                              ');
        disp(['                DRAW NUMBER:   ', num2str(jj)]                );
        disp('                                                              ');
        disp(['                REMAINING DRAWS:   ', num2str(nsim-nburn-jj)]       );
        disp('                                                              ');
        
        counter = 0;
    end
    
    %% Now-/Forecasts
    % store in monthly frequency
    YYvector_ml(jj,:,:)  = YYpred;
    YYvector_mg(jj,:,:)  = 100*(YYpred1(2:end,:)-YYpred1(1:end-1,:));
%     YYvector_m0(jj,:,select==1)  = 100*YYpred(:,select==1);
%     YYvector_m0(jj,:,select==0)  = exp(YYpred(:,select==0));
    % store forecasts in quarterly frequency
    for ll=1:(H/3)-1
        YYvector_ql(jj,ll+1,:) = ...
            mean(YYvector_ml(jj,3*ll+1-Tnew:3*(ll+1)-Tnew,:));
    end
    
    % store nowcasts in quarterly frequency
    YYnow=squeeze(YYactsim(jj,end-Tnew+1:end,:));
    
    if size(YYnow,2) ~= Nm+Nq
        YYnow = YYnow';
    end
    %     if size(YYnow,1) > size(YYnow,2)
    %         YYnow = YYnow';
    %     end
    
    %     if size(squeeze(YYvector_ml(jj,1:3-Tnew,:)),1)>...
    %        size(squeeze(YYvector_ml(jj,1:3-Tnew,:)),2)
    %         YYfuture=squeeze(YYvector_ml(jj,1:3-Tnew,:))';
    %     else
    %         YYfuture=squeeze(YYvector_ml(jj,1:3-Tnew,:));
    %     end
    YYfuture = YYpred(1:3-Tnew,:);
    
    if Tnew==3
        YYvector_ql(jj,1,:) = mean(YYnow);
    else
        YYvector_ql(jj,1,:) = mean([YYnow;YYfuture]);
    end
    
    YYvector_qg(jj,1,:) = ...
        100*(squeeze(YYvector_ql(jj,1,:))- mean([Ym(end-2:end,:) Yq(end-2:end,:)])');
    for bb=2:H/3
        YYvector_qg(jj,bb,:) = ...
            100*(squeeze(YYvector_ql(jj,bb,:))-squeeze(YYvector_ql(jj,bb-1,:)));
    end
end

% throw out nburn iterations

% YYvector_ml  = YYvector_ml(nburn+1:end,:,:);
% YYvector_m0  = YYvector_m0(nburn+1:end,:,:);
% YYactsim     = YYactsim(nburn+1:end,:,:);

% YYvector_ql  = YYvector_ql(nburn+1:end,:,:);
% YYvector_qg  = YYvector_qg(nburn+1:end,:,:);

% convert to original units
% store monthly history and point (median) forecast

YYftr_m   = squeeze(median(YYvector_ml)); % point forecast all vars
% YYftr_m(:,select==1)  = 100*YYftr_m(:,select==1);
% YYftr_m(:,select==0)  = exp(YYftr_m(:,select==0));

% YYnow_m                 = squeeze(median(YYactsim(:,2:4,1:Nm))); % actual/nowcast monthlies
YYnow_m                 = reshape(median(YYactsim(:,2:4,1:Nm)),3,Nm); % actual/nowcast monthlies
% YYnow_m(:,select_m==1)  = 100*YYnow_m(:,select_m==1);
% YYnow_m(:,select_m==0)  = exp(YYnow_m(:,select_m==0));

lstate_ml = squeeze(median(lstate(1:end,:,:)))';  % monthly obs for quarterly vars   !!! ACHTUNG !!!
lstate_m = reshape(lstate_ml,t,Nq);
% lstate_m(:,select_q==1)  = 100*lstate_m(:,select_q==1);
% lstate_m(:,select_q==0)  = exp(lstate_m(:,select_q==0));
% YMh(:,select == 1)       = 100*YMh(:,select == 1);
% YMh(:,select_q==0)       = exp(YMh(:,select_q==0));
% YMh(:,select == 1)       = 100*YMh(:,select == 1);
% YMh(:,select_q==0)       = exp(YMh(:,select_q==0));

YY_m  = [YMh lstate_m(1:end-3,:); YYnow_m lstate_m(end-2:end,:); YYftr_m];

mean_phi = squeeze(mean(Phip));
mean_YYvector_qg = squeeze(mean(YYvector_qg));
mean_YYvector_ql = squeeze(mean(YYvector_ql));

% Density forecast
% Convert YYactsim level
% YYactsim(:,:,select==1) = 100*YYactsim(:,:,select==1);
% YYactsim(:,:,select==0) = exp(YYactsim(:,:,select==0));

% Join nowcast with forecast
vars = size(YYvector_m0,3);
YYvecl = NaN(nsim-nburn, Tnew + H, vars);
for i = 1:vars
    YYvecl(:,:,i) = [YYactsim(:,end-Tnew+1:end,i), YYvector_m0(:,:,i)];
end
Output.YY_past_forfcast = YY_past_forfcast;
Output.YY_m = YY_m;
Output.mean_phi = mean_phi;
Output.mean_YYvector_qg = mean_YYvector_qg;
Output.mean_YYvector_ql = mean_YYvector_ql;

Output.beta_gibbs = permute(reshape(Phip,nsim-nburn,(nv*p+nex)*nv,1),[2,1]);
Output.sigma_gibbs = permute(reshape(Sigmap,nsim-nburn,nv^2),[2,1]);
Output.YYvecl = YYvecl;
Output.Tnew = Tnew;
% here we create the X and Y in BEAR to use for the structural shock decomposition
Y_dat       = YY_m(1:Tnobs,:);
% Y_dat(:,select == 0)       = log(Y_dat(:,select == 0));
% Y_dat(:,select == 1)       = Y_dat(:,select == 1)./100;
X_datf       = [YDATA(1:T0,:); Y_dat];
X_dat       = zeros(Tnobs,nv*p+nex);
for ii = 1:p
    X_dat(:,1+nv*(ii-1) : nv + nv*(ii-1)) = X_datf(1+6-ii:end-ii,:);
end
X_dat(:,end) = ones(Tnobs,1);
Output.X    = X_dat;
Output.Y    = Y_dat;

% mean_phi = Output.mean_phi;
% nv = size(mean_phi,2);
% nlags = 6;


%% ORIGINAL IRFS 
% for testing if the same with BEAR, note that you have to set IRFt = 1, because here we don't
% use Cholesky or anything.
%
By = mean_phi(1:nv*nlags,:);
By = reshape(By,nv,nlags,nv);  % variables, lags, equations
By = permute(By,[3,1,2]); %equations, variables, lags to match impulsdt.m

irfperiods = 24;
phi_irf = impulsdtrf(By,eye(nv),irfperiods);

% Drawing graphs
% Response of equation n to shocks to each variable in turn

i = 0;
x = (1:irfperiods)';
plotct = 0;

[Nrows,Ncols] = ConstructOptimalSubplot(nv);

for i = 1:nv
    plotct = plotct + 1;
      eval(['figure(''Name'',''Response of all variables to shock in equation: ',num2str(i),''',''NumberTitle'',''off'')']);
    for j = 1:nv;
        subplot(Nrows,Ncols,j);
        plot(x,reshape(phi_irf(plotct,j,:),irfperiods,1));
    end


end
%}