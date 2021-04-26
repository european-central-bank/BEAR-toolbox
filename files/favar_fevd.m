function [favar]=favar_fevd(gamma_record,It,Bu,n,IRFperiods,FEVDband,favar,IRFt,strctident)

% function [fevd_estimates]=olsfevd(irf_estimates,IRFperiods,gamma,n,endo,datapath)
% computes and displays fevd values for the OLS VAR model
% inputs:  - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs
%          - integer 'IRFperiods': number of periods for IRFs
%          - matrix 'gamma': structural disturbance variance-covariance matrix (defined p 48 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD



% preliminary tasks
npltX=favar.npltX;

% load IRFs
favar_irf_record=favar.IRF.favar_irf_record;

if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels,1); % count the labels provided in the sign res sheet (+ IV)
elseif IRFt==5
    identified=1; % one IV shock
end

% create the first cell
temp=cell(npltX,identified+1);

% start by filling the first column of every Tij matrix in the cell
% loop over rows of temp
for jj=1:npltX
    % loop over columns of temp
    for ii=1:identified
        % square each element
        temp{jj,ii}(:,1)=favar_irf_record{jj,ii}(:,1).^2;
    end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:npltX
    % loop over columns of temp
    for ii=1:identified
        % loop over remaining columns
        for kk=2:IRFperiods
            % define the column as the square of the corresponding column in orthogonalised_irf_record
            % additioned to the value of the preceeding columns, which creates the cumulation
            temp{jj,ii}(:,kk)=favar_irf_record{jj,ii}(:,kk).^2+temp{jj,ii}(:,kk-1);
        end
    end
end

% reshape gamma for loop
gamma_gibbs=reshape(gamma_record,n,n,It-Bu);

% recall L from the sampling process in this case, analogue to beta and sigma
Lgibbs=reshape(favar.L_gibbs,size(favar.L,1),size(favar.L,2),It-Bu);
%relevant loadings of restricted information variables
Lgibbs=Lgibbs(favar.plotX_index,:,:);
% R2 for scaling
R2_gibbs=reshape(favar.R2_gibbs,size(favar.plotX_index,1),1,It-Bu);

% multiply each matrix in the cell by the variance of the structural shocks
% to do so, loop over simulations (rows of the Tij matrices)
for kk=1:It-Bu
    % recover the covariance matrix of structural shocks gamma for this iteration
    gamma=squeeze(gamma_gibbs(:,:,kk));
    L=squeeze(Lgibbs(:,:,kk));
    R2=squeeze(R2_gibbs(:,:,kk));
    
    % scale gamma, irf estimates are already scaled,do we need this step????
    for ii=1:npltX
        for ll=1:identified
            favar_gamma{ii}(:,ll)=L(ii,ll)*gamma(:,ll);
        end
    end
    
    % loop over rows of temp
    for ii=1:npltX
        % loop over columns of temp
        for jj=1:identified
            % multiply column jj of the matrix by the variance of the structural shock
            temp{ii,jj}(1,:)=temp{ii,jj}(1,:)*favar_gamma{ii}(jj,jj);
        end
    end
end

% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for ii=1:npltX
    % start the summation over Tij matrices
    temp{ii,identified+1}=temp{ii,1};
    % sum over remaining columns
    for jj=2:identified
        temp{ii,identified+1}=temp{ii,identified+1}+temp{ii,jj};
    end
end

% create the output cell fevd_record, scale the shocks with R2 in spirit of BBE (2005)
favar_fevd_record=cell(npltX,identified);

% fill the cell
% loop over rows of fevd_estimates
for ii=1:npltX
    % load the R2 to determine the "true" share of variance explained by
    % the common component
    scale=R2(ii);
    shocks=[];
    % loop over columns of fevd_estimates
    for jj=1:identified
        % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
        shock=(temp{ii,jj}./temp{ii,identified+1})*scale;
        favar_fevd_record{ii,jj}=shock; % changed to abs(shock) from shock here
        % save shocks to compute residual
        shocks(:,:,jj)=shock;
    end
    % finally add the residual, reflecting the share explained by the idiosyncratic component (residual)
    favar_fevd_record{ii,jj+1}=1-sum(shocks,3);
end



%% create the FEVD estimates output
% create first the cell that will contain the estimates
favar_fevd_estimates=cell(npltX,identified+1);

% for each variable and each variable contribution along with each period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:npltX
    % consider contributions in turn
    for jj=1:identified+1
        % consider periods in turn
        for kk=1:IRFperiods
            % compute first the lower bound
            favar_fevd_estimates{ii,jj}(1,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),(1-FEVDband)/2);
            % then compute the median
            favar_fevd_estimates{ii,jj}(2,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),0.5);
            % finally compute the upper bound
            favar_fevd_estimates{ii,jj}(3,kk)=quantile(favar_fevd_record{ii,jj}(:,kk),1-(1-FEVDband)/2);
        end
    end
end

%save output
favar.FEVD.favar_fevd_estimates=favar_fevd_estimates;
