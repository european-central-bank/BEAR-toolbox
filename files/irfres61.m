function [irf_record,D_record,gamma_record,hd_record,ETA_record,beta_record,sigma_record]=irfres(beta_gibbs,sigma_gibbs,C_draws,IV_draws,IRFperiods,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,HD,const,exo,strctident,pref,favar,IRFt,It,Bu,prior,theta_gibbs,Z,k3)


% inputs:  - matrix 'betahat': OLS estimate for beta
%          - matrix 'sigmahats': OLS estimate for sigma
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - cell 'signrestable': table recording the sign restriction input from the user
%          - cell 'signresperiods': table containing the periods corresponding to each restriction
%          - string 'ShockwithInstrument' Name of the shock where the instrument belongs to
% outputs: - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - integer 'Qdraw': total number of draws of the Q matrix
%          - integer 'Qsuccess': number of successful draws of the Q matrix

%% Phase 1: Preliminary tasks
Acc=It-Bu; %%number of minimum draws accepted
%preliminaries: initiate variables for the parfor loop
%run('irfres46prelim.m') %%%% this is not working for parforloop
%%%%
%preliminaries for IRFt 4,6: prepare variables for parfor loop
signres=strctident.signres;
zerores=strctident.zerores;
magnres=strctident.magnres;
relmagnres=strctident.relmagnres;
FEVDres=strctident.FEVDres;
checkCorrelInstrumentShock=strctident.checkCorrelInstrumentShock;
signreslabels_shocks=strctident.signreslabels_shocks;

%sign, zero, magnitude
if signres==1 | zerores==1 | magnres==1
    Scell=strctident.Scell;
    Zcell=strctident.Zcell;
    Mcell=strctident.Mcell;
    Mlcell=strctident.Mlcell;
    Mucell=strctident.Mucell;
    periods=strctident.periods;
else
    Scell=NaN;
    Zcell=strctident.Zcell;
    Mcell=NaN;
    Mlcell=NaN;
    Mucell=NaN;
    periods=NaN;
end

%rel. magn
if relmagnres==1
    mperiods=strctident.mperiods;
    columnsS=strctident.columnsS;
    columnsW=strctident.columnsW;
    rowsS=strctident.rowsS;
    rowsW=strctident.rowsW;
    if signres==0 && zerores==0 && magnres==0
        periods=strctident.mperiods;
    end
else
    mperiods=NaN;
    columnsS=NaN;
    columnsW=NaN;
    rowsS=NaN;
    rowsW=NaN;
end

%FEVD
if FEVDres==1
    clmrelativeFEVD=strctident.clmrelativeFEVD;
    rowrelativeFEVD=strctident.rowrelativeFEVD;
    rowabsoluteFEVD=strctident.rowabsoluteFEVD;
    clmabsoluteFEVD=strctident.clmabsoluteFEVD;
    rowsFEVD=strctident.rowsFEVD;
    FEVDperiods=strctident.FEVDperiods;
%     if signres==0 && zerores==0 && magnres==0 && relmagnres==0
%         periods=strctident.FEVDperiods;
%     end
else % provide NaN for par loop
    clmrelativeFEVD=NaN;
    rowrelativeFEVD=NaN;
    rowabsoluteFEVD=NaN;
    clmabsoluteFEVD=NaN;
    rowsFEVD=NaN;
    FEVDperiods=NaN;
end

%correlation res
if checkCorrelInstrumentShock==1
    CorrelShock_index=strctident.CorrelShock_index;
    IVcorrel=strctident.IVcorrel;
    OverlapIVcorrelinY=strctident.OverlapIVcorrelinY;
    FlipCorrel=strctident.FlipCorrel;
%         if signres==0 && zerores==0 && magnres==0 && relmagnres==0 && FEVDres==0
%         periods=strctident.periods;
%         end
else
    CorrelShock_index=NaN;
    IVcorrel=NaN;
    OverlapIVcorrelinY=NaN;
    FlipCorrel=NaN;
end

% favar restrictions
favar_signres=strctident.favar_signres;
favar_zerores=strctident.favar_zerores;
favar_magnres=strctident.favar_magnres;
favar_relmagnres=strctident.favar_relmagnres;
favar_FEVDres=strctident.favar_FEVDres;

if favar.FAVAR==1
    if favar_signres==1 | favar_magnres==1
        favar_Scell=strctident.favar_Scell;
        favar_Zcell=strctident.favar_Zcell;
        favar_Mcell=strctident.favar_Mcell;
        favar_Mlcell=strctident.favar_Mlcell;
        favar_Mucell=strctident.favar_Mucell;
        favar_periods=strctident.favar_periods;
        nsignresX=favar.nsignresX;
        %relevant loadings of restricted information variables
        L=favar.L(favar.signresX_index,:);
    else % provide NaNs
        favar_Scell=NaN;
        favar_Zcell=NaN;
        favar_Mcell=NaN;
        favar_Mlcell=NaN;
        favar_Mucell=NaN;
        favar_periods=NaN;
        nsignresX=NaN;
        L=NaN;
        nrelmagnresX=NaN;
        Lrelmagn=NaN;
    end
    
    % if we also have favar rel. magnitude restrictions
        if favar_relmagnres==1
            favar_columnsS=strctident.favar_columnsS;
            favar_columnsW=strctident.favar_columnsW;
            favar_rowsS=strctident.favar_rowsS;
            favar_rowsW=strctident.favar_rowsW;
            favar_mperiods=strctident.favar_mperiods;
            nrelmagnresX=favar.nrelmagnresX;
            %relevant loadings of restricted information variables
            Lrelmagn=favar.L(favar.relmagnresX_index,:);
        else
            favar_columnsS=NaN;
            favar_columnsW=NaN;
            favar_rowsS=NaN;
            favar_rowsW=NaN;
            favar_mperiods=NaN;
            nrelmagnresX=NaN;
            Lrelmagn=NaN;
        end
    
    if favar_FEVDres==1
        favar_clmrelativeFEVD=strctident.favar_clmrelativeFEVD;
        favar_rowrelativeFEVD=strctident.favar_rowrelativeFEVD;
        favar_rowabsoluteFEVD=strctident.favar_rowabsoluteFEVD;
        favar_clmabsoluteFEVD=strctident.favar_clmabsoluteFEVD;
        favar_rowsFEVD=strctident.favar_rowsFEVD;
        favar_FEVDresperiods=strctident.favar_FEVDresperiods;
        favar_FEVDperiods=strctident.favar_FEVDperiods;
        nFEVDresX=favar.nFEVDresX;
        %relevant loadings of restricted information variables
        LFEVD=favar.L(favar.FEVDresX_index,:);
    else % provide NaNs
        favar_clmrelativeFEVD=NaN;
        favar_rowrelativeFEVD=NaN;
        favar_rowabsoluteFEVD=NaN;
        favar_clmabsoluteFEVD=NaN;
        favar_rowsFEVD=NaN;
        favar_FEVDresperiods=NaN;
        favar_FEVDperiods=NaN;
        nFEVDresX=NaN;
        LFEVD=NaN;
    end
	
	    %for HD
    if favar.HD.plot==1 
        HD=1;
    end
    
else % we do not have a favar, provide NaNs for parfor loop
    favar_Scell=NaN;
    favar_Zcell=NaN;
    favar_Mcell=NaN;
    favar_Mlcell=NaN;
    favar_Mucell=NaN;
    favar_periods=NaN;
    nsignresX=NaN;
    L=NaN;
    favar_columnsS=NaN;
    favar_columnsW=NaN;
    favar_rowsS=NaN;
    favar_rowsW=NaN;
    favar_mperiods=NaN;
    nrelmagnresX=NaN;
    Lrelmagn=NaN;
    favar_clmrelativeFEVD=NaN;
    favar_rowrelativeFEVD=NaN;
    favar_rowabsoluteFEVD=NaN;
    favar_clmabsoluteFEVD=NaN;
    favar_rowsFEVD=NaN;
    favar_FEVDresperiods=NaN;
    favar_FEVDperiods=NaN;
    nFEVDresX=NaN;
    LFEVD=NaN;
    %favar_stackedirfmatmagn=NaN;

end

checkperiods={
periods;
mperiods;
FEVDperiods;
favar_periods;
favar_mperiods;
favar_FEVDperiods};
count=0;
for pp=1:size(checkperiods,1)
    if isnan(checkperiods{pp,1})==0
  %      checkperiods2{pp,1}=sum(checkperiods{pp,1});
        count=count+1;
        for uu=1:2
            if uu==1
                checkperiods2(count,uu)=checkperiods{pp,1}(uu,1);
            elseif uu==2
                checkperiods2(count,uu)=checkperiods{pp,1}(end,1);
            end
        end
    end
end
periods=[min(checkperiods2(:,1)); max(checkperiods2(:,2))];
periods=[periods(1,1):periods(2,1)]';


%hbar
hbartext_signres=strctident.hbartext_signres;
hbartext_favar_signres=strctident.hbartext_favar_signres;
hbartext_zerores=strctident.hbartext_zerores;
hbartext_favar_zerores=strctident.hbartext_favar_zerores;
hbartext_magnres=strctident.hbartext_magnres;
hbartext_favar_magnres=strctident.hbartext_favar_magnres;
hbartext_relmagnres=strctident.hbartext_relmagnres;
hbartext_favar_relmagnres=strctident.hbartext_favar_relmagnres;
hbartext_FEVDres=strctident.hbartext_FEVDres;
hbartext_favar_FEVDres=strctident.hbartext_favar_FEVDres;
hbartext_CorrelInstrumentShock=strctident.hbartext_CorrelInstrumentShock;

% Storage cells in any case
% create first the cell that will store the results from the simulations
irf_record=cell(n,n);
% storage cell
storage1=cell(Acc,1);
storage2=cell(Acc,1);
storage3=cell(Acc,1);
storage4=cell(Acc,1);
In=eye(n);


%%%%

%% initiate rotation draws
not_successful=0;
% create the progress bar
hbartext=['Progress of ',hbartext_signres,hbartext_favar_signres,hbartext_zerores,hbartext_favar_zerores,hbartext_magnres,hbartext_favar_magnres,hbartext_relmagnres,hbartext_favar_relmagnres,hbartext_FEVDres,hbartext_favar_FEVDres,hbartext_CorrelInstrumentShock,':::',' Restriction Draws.'];
hbartext=erase(hbartext,', :::'); % delete the last ,
hbar=parfor_progressbar(Acc,hbartext);
for ii=1:Acc %parfor
    % initiate the variable 'success'; this variable will be used to check whether the restrictions are satisfied
    % if there are only zero restrictions, they will be satisfied by construction, and 'success' will simply be ignored
    success=0;
    % how the algorithm will be conducted will depend on the types of restrictions implemented
    % if there are only zero restrictions, the algorithm is simple as no checking is required: the conditions are satisfied by construction
    if IRFt==4 && zerores==1 && signres==0 && magnres==0 && relmagnres==0 && favar_signres==0 && favar_magnres==0
        % draw beta and sigma
        beta=beta_gibbs(:,ii);
        sigma=reshape(sigma_gibbs(:,ii),n,n);
        hsigma=chol(nspd(sigma),'lower');
                if prior==61
                theta=theta_gibbs(:,index);
                end
        % obtain orthogonalised IRFs
        [~,ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)),prior);
        % generate the stacked IRF matrix
        stackedirfmat=[];
        for jj=1:numel(periods)
            stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
        end
        % draw an entire random matrix Q satisfying the zero restrictions
        [Q]=qzerores(n,Zcell,stackedirfmat);
        % there is no need to verify the restrictions: there are satisfied by construction
		
        %%%%% FAVAR
        % atm zero restrictions are not available for information variables,
        %%%%%
        
        % if there are sign/magnitude/correlation restrictions, possibly associated with zero restrictions
    else
        % the algorithm becomes a bit more complicated as conditions now need to be checked
        % to maintain efficiency, the algorithm proceeds recursively shock by shock, and stops as soon as a condition on the considered shock fails
        % repeat algorithm for the iteration as long as not all conditions are satisfied
        while success==0
            not_successful=not_successful+1;
            % switch 'success' to 1; it will be turned back to zero if at any time Q is detected as a candidate not satisfying the restrictions
            success=1;
            
            % different procedures for IRFt 4 and 6: we have already the first
            % column (shock) of the structural matrix in IRFt==6, the IV shock,
            % this is why we have other Qj and hsigma there and need to provide
            % IV_draws C_draws in this case
            if IRFt==4
                % draw randomly the vector of VAR coefficients: draw a random index
                index=floor(rand*(Acc))+1;
                % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
                beta=beta_gibbs(:,index);
                sigma=reshape(sigma_gibbs(:,index),n,n);
                hsigma=chol(nspd(sigma),'lower');
                if prior==61
                theta=theta_gibbs(:,index);
                end
            elseif IRFt==6
                %stationary=0;
                %while stationary==0 %%%%% this test only for IRFt6?, comment
                % draw randomly the vector of VAR coefficients: draw a random index
                index=floor(rand*(Acc))+1;
                % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
                beta=beta_gibbs(:,index);
                %[stationary]=checkstable(beta,n,p,k); %switches stationary to 0, if the draw is not stationary
                %end
                %B=reshape(beta,k,n); %reshape Bdraw
                sigma=reshape(sigma_gibbs(:,index),n,n);
                Qj1=IV_draws(:,index);
                hsigma=reshape(C_draws(:,index),n,n);
            end
            
            % obtain orthogonalised IRFs
            [~,ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)),prior);
            % generate the stacked IRF matrix
            stackedirfmat=[];
            for kk=1:numel(periods)
                stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(kk,1)+1)];
            end
            
            % if we have FAVAR restrictions we scale the ortirfmatrix from the previous step
            if favar_signres==1 | favar_magnres==1
                favar_ortirfmatrix=[];
                % scale with loading
                for uu=1:nsignresX %over variables in X that we choose to restrict
                    for ll=1:IRFperiods
                        for qq=1:n % over shocks
                            favar_ortirfmatrix(uu,qq,ll)=L(uu,:)*ortirfmatrix(:,qq,ll);
                        end
                    end
                end
                %stack over periods
                favar_stackedirfmat=[];
                for ll=1:numel(favar_periods)
                    favar_stackedirfmat=[favar_stackedirfmat;favar_ortirfmatrix(:,:,favar_periods(ll,1)+1)];
                end
            end
            
            % now start looping over the shocks and checking sequentially whether conditions on these shocks hold
            % stop as soon as one restriction fails
            % initiate Qj
            jj=1;
            okay=zeros(n,1); %initiate okay vector
            Qj=[];
            if IRFt==6 % if IRFt6
                Qj(:,1)=Qj1; % fill first column (IV shock)
                okay(1,1)=1; % first shock is okay
                jj=2; % skip the first iteration
            end
            
            while success==1 && jj<=n && sum(okay)<n
                % build column j of the random matrix Q
                if IRFt==4 && zerores==1 || magnres==1 %if we have zero restrictions, we cannot reshuffle the columns
                    qj=qrandj(n,Zcell{1,jj},stackedirfmat,Qj);
                    % obtain the candidate column fj
                    fj=stackedirfmat*qj;
                    % check restrictions: first sign restrictions
                    if signres==1
                        [success,qj]=checksignres(Scell{1,jj},qj,fj);
                    end
                    % if 'success' is still equal to 1, also check for magnitude restrictions
                    if success==1
                        [success]=checkmagres(Mcell{1,jj},Mlcell{1,jj},Mucell{1,jj},fj);
                    end
                    
                    % if sign and magnitude restrictions are fullfilled, check favar sign, magnitude restrictions
                    if success==1 && favar_signres==1 | favar_magnres==1
                        % obtain the candidate column fj
                        favar_fj=favar_stackedirfmat*qj; % the qj from the computation is checked
                        % simple success check
                        if favar_signres==1
                            [success]=checksignres_favar(favar_Scell{1,jj},favar_fj);
                        end
                        % if 'success' is still equal to 1, also check for magnitude restrictions
                        if success==1 && favar_magnres==1
                            [success]=checkmagres(favar_Mcell{1,jj},favar_Mlcell{1,jj},favar_Mucell{1,jj},favar_fj);
                        end
                    end
                    % also, if 'success' is still equal to 1, update Qj by concatenating qj
                    if success==1
                        Qj=[Qj qj];
                    end
                    okay(jj,1)=1; %set okay (jj,1) to 1
                    jj=jj+1; %iterate jj
                    
                else %if there are no zero restrictions, we can reshuffle columns
                    % draw a random vector from the standard normal
                    if okay(1,1)==0 %first find the first column
                        %jj=1;
                        % build column j of the random matrix Q
                        qj=qrandj(n,Zcell{1,jj},stackedirfmat,Qj); % why is it build with Zcell
                        % obtain the candidate column fj
                        fj=stackedirfmat*qj;
                        if signres==1
                            [success,qj]=checksignres(Scell{1,jj},qj,fj);
                        end
                        % if sign and magnitude restrictions are fullfilled, check favar sign, magnitude restrictions
                        if success==1 && favar_signres==1 | favar_magnres==1
                            % obtain the candidate column fj
                            favar_fj=favar_stackedirfmat*qj; % the qj from the computation is checked
                            % simple success check
                            if favar_signres==1
                                [success]=checksignres_favar(favar_Scell{1,jj},favar_fj);
                            end
                            % if 'success' is still equal to 1, also check for magnitude restrictions
                            if success==1 && favar_magnres==1
                                [success]=checkmagres(favar_Mcell{1,jj},favar_Mlcell{1,jj},favar_Mucell{1,jj},favar_fj);
                            end
                        end
                        % the restrictions must be fullfilled to save qj as success in Qj
                        % if 'success' is still equal to 1, update Qj by concatenating qj
                        if success==1
                            %Qjstore=[Qj qj];
                            Qj(:,1)=qj; %set column yy of Qj to qj
                            okay(1,1)=1;
                            jj=jj+1;
                        end
                        
                    else % when success is 0, okay is 0, then check if potential qj suits other shocks
 
                        if IRFt==6 && zerores ==1 % different computation of qj if we have zero res in IRFt6, we cannot reshuffle
                            qj=qrandj(n,Zcell{1,jj},stackedirfmat,Qj);
                        else
                            x=normrnd(0,1,n,1);
                            qj=(In-Qj*Qj')*x/norm((In-Qj*Qj')*x);
                        end
                        
                        if signres==1
                            fj=stackedirfmat*qj;
                            if zerores==0
                                [success,qj,okay,yy]=checksignres_inc_other_shocks(qj,fj,Scell,okay,IRFt,n);
                            elseif zerores==1 % in this case we cannot reshuffle
                                [success,qj]=checksignres(Scell{1,jj},qj,fj);
                            end
                        end
                        % the routine simply runs for one collumn after another, we cannot reshuffle
                        if signres==0 || zerores==1 % in case we have e.g. FEVD res only
                            yy=jj;
                        end
                        
                        % check for mag res
                        if success==1 && magnres==1
                            [success]=checkmagres(Mcell{1,yy},Mlcell{1,yy},Mucell{1,yy},fj);
                        end
                        
                        % check if favar_signres==1
                        if success==1 && favar_signres==1 | favar_magnres==1
                            % obtain the candidate column fj
                            favar_fj=favar_stackedirfmat*qj; % the qj from the computation is checked
                            % simple check
                            if favar_signres==1
                                [success]=checksignres_favar(favar_Scell{1,yy},favar_fj);
                            end
                            % if 'success' is still equal to 1, also check for magnitude restrictions
                            if success==1 && favar_magnres==1
                                [success]=checkmagres(favar_Mcell{1,yy},favar_Mlcell{1,yy},favar_Mucell{1,yy},favar_fj);
                            end
                        end
                        if success==1
                            Qj(:,yy)=qj; %set column yy of Qj to qj
                            jj=jj+1;
                        end
                    end
                end
            end
            
            %% once all n columns are build and fullfill the sign, zero, magnitude restrictions
            %% if all the restrictions are fullfilled, check proxy correlation restriction
            if size(Qj,2)==n && success==1  && checkCorrelInstrumentShock==1
                D=hsigma*Qj;
                % recover the VAR coefficients, reshaped for convenience
                B=reshape(beta,k,n);
                % obtain the residuals from (this draw)
                EPS=Y-X*B;
                %compute structural shocks
                ETA=D\EPS';
                [success,corIV,pivShockwithIV,Qj]=CheckCorrelWithIV(ETA,n,CorrelShock_index, IVcorrel,OverlapIVcorrelinY,FlipCorrel,Qj);
            end
            
            %% check relative magnitude restrictions
            if size(Qj,2)==n && success==1  && relmagnres==1 | favar_relmagnres==1
                D=hsigma*Qj;
                [~,ortirfmatrixmagnitude]=irfsim(beta,D,n,m,p,k,max(IRFperiods,max(mperiods)),prior);

                    % check relmagnres
                    if relmagnres==1
                    % generate the stacked IRF matrix
                    stackedirfmatmagn=[];
                    for kk=1:numel(mperiods)
                        stackedirfmatmagn=[stackedirfmatmagn;ortirfmatrixmagnitude(:,:,mperiods(kk,1)+1)];
                    end
                    [success]=checkrelmag(stackedirfmatmagn,columnsS,columnsW,rowsS,rowsW,n,mperiods,n);
                    end
                
                % check favar_relmagnres
                if success==1 && favar_relmagnres==1
                    favar_ortirfmatrixmagnitude=[]; % compute favar_ortirfmatrixmagnitude
                    % scale with loading
                    for uu=1:nrelmagnresX %over variables in X that we choose to restrict
                        for ll=1:IRFperiods
                            for qq=1:n % over shocks
                                favar_ortirfmatrixmagnitude(uu,qq,ll)=Lrelmagn(uu,:)*ortirfmatrixmagnitude(:,qq,ll);
                            end
                        end
                    end
                    %stack over periods
                    favar_stackedirfmatmagn=[];
                    for ll=1:numel(favar_mperiods)
                        favar_stackedirfmatmagn=[favar_stackedirfmatmagn;favar_ortirfmatrixmagnitude(:,:,favar_mperiods(ll,1)+1)];
                    end
                    % check
                    [success]=checkrelmag(favar_stackedirfmatmagn,favar_columnsS,favar_columnsW,favar_rowsS,favar_rowsW,n,favar_mperiods,nrelmagnresX);
                end
            end
            
            %% check FEVD restrictions
            if size(Qj,2)==n && success==1  && FEVDres==1 | favar_FEVDres==1
                D=hsigma*Qj; %again compute D
                [~,ortirfmatrixFEVD]=irfsim(beta,D,n,m,p,k,IRFperiods,prior); %obtain orthogonalized IRFs
                gamma=eye(n,n);
                %check FEVDrestrictions
                if FEVDres==1
                    [success]=CheckFEVDrestriction(ortirfmatrixFEVD,gamma,IRFperiods,n,rowrelativeFEVD,clmrelativeFEVD,rowabsoluteFEVD,clmabsoluteFEVD,FEVDresperiods,rowsFEVD,n);
                end
                
                % check also favar FEVD restrictions
                if success==1 && favar_FEVDres==1
                    favar_ortirfmatrixFEVD=[]; %compute favar_ortirfmatrixFEVD
                    % scale with loading
                    for uu=1:nFEVDresX %over variables in X that we chose to restrict
                        for ll=1:IRFperiods %over Periods
                            for qq=1:n %over shocks
                                favar_ortirfmatrixFEVD(uu,qq,ll)=LFEVD(uu,:)*ortirfmatrixFEVD(:,qq,ll);
                            end
                        end
                    end
                    % check
                    [success]=CheckFEVDrestriction_favar(favar_ortirfmatrixFEVD,gamma,IRFperiods,n,favar_rowrelativeFEVD,favar_clmrelativeFEVD,favar_rowabsoluteFEVD,favar_clmabsoluteFEVD,favar_FEVDresperiods,favar_rowsFEVD,nFEVDresX,LFEVD);
                end
            end
            
            
            %% finally compute the historical decomposition
            if size(Qj,2)==n && success==1 && HD==1
                D=hsigma*Qj;
                [hd_estimates]=hd_new_for_signres(const,exo,beta,k,n,p,D,m,T,X,Y,data_exo,IRFt,signreslabels_shocks,prior,theta,Z,k3);
            end
            % repeat this loop until a succesful draw is obtained
        end
        % with succesful Qj at hand, eventually set Q as Qj
        Q=Qj;
        % save D from this draw
        D=hsigma*Q;
    end
    % obtain B from this draw
    B=reshape(beta,k,n);
    % obtain the residuals from this draw
    EPS=Y-X*B;
    % compute structural shocks for this draw
    ETA=D\EPS';
    
    %% store
    % store IRFs
    for jj=1:IRFperiods
        storage1{ii,1}(:,:,jj)=ortirfmatrix(:,:,jj)*Q;
    end
    
    % store D
    storage2{ii,1}=D;
    
    % store historical decompositions
    if HD==1
        storage3{ii,1}=hd_estimates;
    end
    
    % store structural shocks
    storage4{ii,1}=ETA;
    
    % store betas and sigmas
    beta_record(:,ii)=vec(B);
    sigma_record(:,ii)=vec(sigma);
    
    % correl res statistics
    if checkCorrelInstrumentShock==1
        IVcorrelation(ii,1)=corIV;
        PofIVcorrelation(ii,1)=pivShockwithIV;
    end
    
    % update progress by one iteration
    hbar.iterate(1);
end
close(hbar);   %close progress bar

%% reorganise storage
for ii=1:Acc % loop over iterations
    for jj=1:IRFperiods % loop over IRF periods
        for kk=1:n % loop over variables
            for ll=1:n % loop over shocks
                irf_record{kk,ll}(ii,jj)=storage1{ii,1}(kk,ll,jj);
            end
        end
    end
    D_record(:,ii)=storage2{ii,1}(:);
    gamma_record(:,ii)=vec(eye(n));
end

%reorganize historical decompositions
contributors=n+1+1+length(exo); %variables + constant + initial conditions + exogenous
hd_record=cell(contributors+2,n);
if HD==1
    for ii=1:Acc %loop over draws
        for ll=1:n %loop over variables
            for kk=1:contributors+2 %loop over contributors
                hd_record{kk,ll}(ii,:) = storage3{ii,1}{kk,ll};
            end
        end
    end
end
%hdrecord is ordered such that columns are variables and rows are contributors
%row n+1 = contribution of the constant
%row n+2 = contribution of initial conditions (past shocks)
%row n+3 = unexplained part (for partially identified model
%row n+4 = part that was left to explain by the structural shocks after accounting for exogenous, constant and initial conditions

%reorganize structural shocks
ETA_record={};
for ii=1:Acc %loop over draws
    for ll=1:n %loop over variables
        ETA_record{ll,1}(ii,:)= storage4{ii,1}(ll,:);
    end
end

%% print accepted draws in command window and results file
filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('Accepted Draws in Percent of Total Number of Draws: %f', 100*(Acc)/(not_successful + Acc)); %from posterior
fprintf(fid,'Accepted Draws in Percent of Total Number of Draws: %f', 100*(Acc)/(not_successful + Acc));
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fclose(fid);

