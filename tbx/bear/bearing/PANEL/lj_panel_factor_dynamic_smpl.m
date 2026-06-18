function outSampler = lj_panel_factor_dynamic_smpl(this, meta, longYXZ)


    const         = meta.flagConst;
    numLags       = meta.numLags;
    Bu            = meta.Bu;

    alpha0        = this.Settings.alpha0;
    delta0        = this.Settings.delta0;
    rho           = this.Settings.rho;
    gama          = this.Settings.gamma;
    a0            = this.Settings.a0;
    b0            = this.Settings.b0;


    [longY, longX, ~] = longYXZ{:};
    % compute preliminary elements
    [Ymat,Xmat,N,n,m,p,T,k,q,h]=bear.panel6prelim(longY,longX,const,numLags);

    % obtain prior elements
    [d1,d2,d3,d4,d5,d,~,~,~,~,~,Xi,y,Xtilde,thetabar,theta0,H,Thetatilde,Theta0,G]=bear.panel6prior(N,n,p,m,k,q,h,T,Ymat,Xmat,rho,gama);


    % preparation for gibbs sampleing
    % compute first  preliminary elements
    % compute the series of abar values
    a1bar=T*d1+a0;
    a2bar=T*d2+a0;
    a3bar=T*d3+a0;
    a4bar=T*d4+a0;
    a5bar=T*d5+a0;
    % compute alphabar
    alphabar=T+alpha0;

    % step 1: compute initial values
    % initial value for Theta
    Theta=repmat(thetabar,T,1);
    
    % initial value for sigmatilde
    eps=reshape(y-Xtilde*Theta,N*n,T);
    sigmatilde=(1/T)*eps*eps';
    % initial value for Zeta
    Zeta=zeros(T,1);
    % initial value for phi
    phi=0.001;

    function smpl = sampler()
        % step 2: obtain sigmatilde
        % compute Sbar
        % because using a loop is slow, express the summation as a matrix product
        % compute in matrix form the series of residuals yt-Xt*thetat
        % TODO optimization - check sparse, is it needed
        eps=sparse(reshape(y-Xtilde*Theta,N*n,T));
        % create a diagonal matrix for which each diagonal entry is a zeta value
        zetamat=sparse(diag(exp(-Zeta)));
        % obtain Sbar
        Sbar=full(eps*zetamat*eps');
        % finally draw sigmatilde
        sigmatilde=bear.iwdraw(Sbar,T);
        invsigmatilde=sigmatilde\speye(n*N);

        % step 3: obtain Zeta
        eps=eps';
        % compute in matrix form the series of residuals yt-Xt*thetat
        for tt=1:T
            % obtain the residual product for the acceptance probability
            term=eps(tt,:)*invsigmatilde*eps(tt,:)';
            % obtain phibar
            if tt==1
                phibar=phi/(1+gama^2);
                zetabar=(phibar/phi)*gama*Zeta(2,1);

            elseif tt==T
                phibar=phi;  
                zetabar=gama*Zeta(T-1,1);

            else
                phibar=phi/(1+gama^2);
                zetabar=(phibar/phi)*gama*(Zeta(tt-1,1)+Zeta(tt+1,1));
            end

            % obtain a candidate value
            cand=zetabar+sqrt(phibar)*randn;
            % obtain the probability of acceptance
            [prob]=bear.mhprob(Zeta(tt,1),cand,term,n,N);
            % draw a uniform random number
            draw=rand;
            % keep the candidate if the draw value is lower than the prob
            if draw<=prob
                Zeta(tt,1)=cand;
                % if not, just keep the former value
            end
        end

        % step 4: obtain phi
        % obtain deltabar
        deltabar=Zeta'*G'*G*Zeta+delta0;
        % draw phi
        phi=bear.igrandn(alphabar/2,deltabar/2);

        % step 5: obtain the series of bi values
        % first reshape the Theta vector so that each column corresponds to a sample period
        Thetamat=reshape(Theta,d,T);
        % then draw b values for each structural factor in turn

        % factor 1 (common component)
        % extract the theta component related to structural factor 1 (for all periods)
        theta1=Thetamat(1:d1,:);
        % obtain lagged values
        theta1lag=[theta0(1:d1,1) theta1(:,1:end-1)];
        % generate the difference
        theta1diff=theta1-theta1lag;
        % obtain the summation
        summ1=bear.vec(theta1diff)'*bear.vec(theta1diff);
        % obtain b1bar
        b1bar=summ1+b0;
        % draw b1
        b1=bear.igrandn(a1bar/2,b1bar/2);

        % factor 2 (unit component)
        % extract the theta component related to structural factor 2 (for all periods)
        theta2=Thetamat(d1+1:d1+d2,:);
        % obtain lagged values
        theta2lag=[theta0(d1+1:d1+d2,1) theta2(:,1:end-1)];
        % generate the difference
        theta2diff=theta2-theta2lag;
        % obtain the summation
        summ2=bear.vec(theta2diff)'*bear.vec(theta2diff);
        % obtain b1bar
        b2bar=summ2+b0;
        % draw b2
        b2=bear.igrandn(a2bar/2,b2bar/2);

        % factor 3 (endogenous variable component)
        % extract the theta component related to structural factor 3 (for all periods)
        theta3=Thetamat(d1+d2+1:d1+d2+d3,:);
        % obtain lagged values
        theta3lag=[theta0(d1+d2+1:d1+d2+d3,1) theta3(:,1:end-1)];
        % generate the difference
        theta3diff=theta3-theta3lag;
        % obtain the summation
        summ3=bear.vec(theta3diff)'*bear.vec(theta3diff);
        % obtain b1bar
        b3bar=summ3+b0;
        % draw b3
        b3=bear.igrandn(a3bar/2,b3bar/2);

        % factor 4 (lag component, only if the model includes more than one lag)
        if d4~=0
            % extract the theta component related to structural factor 4 (for all periods)
            theta4=Thetamat(d1+d2+d3+1:d1+d2+d3+d4,:);
            % obtain lagged values
            theta4lag=[theta0(d1+d2+d3+1:d1+d2+d3+d4,1) theta4(:,1:end-1)];
            % generate the difference
            theta4diff=theta4-theta4lag;
            % obtain the summation
            summ4=bear.vec(theta4diff)'*bear.vec(theta4diff);
            % obtain b1bar
            b4bar=summ4+b0;
            % draw b4
            b4=bear.igrandn(a4bar/2,b4bar/2);

        else 
            b4=nan;
        end

        % factor 5 (exogenous variable component, only if the model includes at least one exogenous)
        if d5~=0
            % extract the theta component related to structural factor 4 (for all periods)
            theta5=Thetamat(d1+d2+d3+d4+1:d1+d2+d3+d4+d5,:);
            % obtain lagged values
            theta5lag=[theta0(d1+d2+d3+d4+1:d1+d2+d3+d4+d5,1) theta5(:,1:end-1)];
            % generate the difference
            theta5diff=theta5-theta5lag;
            % obtain the summation
            summ5=bear.vec(theta5diff)'*bear.vec(theta5diff);
            % obtain b1bar
            b5bar=summ5+b0;
            % draw b5
            b5=bear.igrandn(a5bar/2,b5bar/2);

        else 
            b5=nan;
        end

        % step 6: obtain Theta
        % first generate B
        B=sparse(blkdiag(b1*eye(d1),b2*eye(d2),b3*eye(d3),b4*eye(d4),b5*eye(d5)));
        % then obtain the inverse of B0: since B0=H-1*Btilde*(H-1)', then inv(Bo)=H'*Btilde-1*H=H'*kron(eye(T),B-1)-1*H
        % obtain first the inverse of B; B is diagonal, so just take elementwise inverse of diagonal entries
        invB=sparse(diag(1./diag(B)));
        % then obtain the inverse of B0
        invB0=H'*kron(eye(T),invB)*H;
        % compute Sigma
        Sigma=kron(sparse(diag(exp(Zeta))),sigmatilde);
        % obtain the inverse
        C=bear.trns(chol(bear.nspd(full(Sigma)),'Lower'));
        invC=C\speye(T*N*n);
        invSigma=invC*invC';
        % obtain Bbar
        invBbar=(Xtilde'*invSigma*Xtilde+invB0);
        % obtain the inverse
        C=bear.trns(chol(bear.nspd(full(invBbar)),'Lower'));
        invC=C\speye(T*d);
        Bbar=invC*invC';
        % obtain Thetabar
        Thetabar=Bbar*(Xtilde'*invSigma*y+invB0*Theta0);
        % draw Theta
        Theta=Thetabar+chol(bear.nspd(Bbar),'lower')*mvnrnd(zeros(d*T,1),eye(d*T))';

        % store results
        sigmatilde_gibbs=bear.vec(sigmatilde);
        Zeta_gibbs=Zeta;
        phi_gibbs=phi;
        B_gibbs=B;
        theta_gibbs=reshape(Theta,d,T);
        % recover sigma for all periods and record      
        temp=kron(exp(Zeta),bear.vec(sigmatilde));
        sigma_gibbs=reshape(temp,(N*n)^2,T);

        smpl            = struct();
        smpl.sigmatilde = sigmatilde_gibbs;
        smpl.Zeta       = Zeta_gibbs;
        smpl.phi        = phi_gibbs;
        smpl.B          = B_gibbs;
        smpl.theta      = theta_gibbs;
        smpl.sigma      = sigma_gibbs;
        smpl.Xi         = Xi;
        smpl.thetabar   = thetabar;
      
    end

    % Burning part before returning the sampler
    for count=1:Bu
        sampler();
    end

    outSampler = @sampler;

end