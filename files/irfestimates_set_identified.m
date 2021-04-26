function [irf_estimates,D_estimates,gamma_estimates,favar]=irfestimates_set_identified(irf_record,n,IRFperiods,IRFband,D_record,strctident,favar)


% function [irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record)
% calculates the point estimate (median), lower bound and upper bound of the IRFs from the posterior distribution
% inputs:  - cell 'irf_record': record of the gibbs sampler draws for the IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - scalar 'IRFband': confidence level for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
% outputs: - cell 'irftrig_estimates': lower bound, point estimates, and upper bound for the orthogonalised IRFs obtained from triangular factorisation
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form

if strctident.MM==0
    % create first the cell that will contain the IRF estimates
    irf_estimates=cell(n,n);
    
    %check if the variables have been transformed
    if favar.FAVAR==1
        if favar.transformation==1 || favar.plot_transform==1
            % re-transform favar_struct_irf_record
            favar_irf_record=favar.IRF.favar_irf_record;
            favar.IRF.favar_irf_record_nottransformed=favar_irf_record;
            transformationindex=favar.transformationindex(favar.plotX_index,1);
            % re-transform
            [favar_irf_record]=favar_retransX_irf_record(favar_irf_record,transformationindex,favar.levels);
            % save
            favar.IRF.favar_irf_record=favar_irf_record;
            
            % re-transform irf_record
            favar.IRF.irf_record_nottransformed=irf_record; % before, save untransformed IRFs
            transformationindex_endo=favar.transformationindex_endo;
            % re-transform
            [irf_record]=favar_retransX_irf_record(irf_record,transformationindex_endo,favar.levels);
        end
    end
    
    % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
    % consider variables in turn
    for ii=1:n
        if favar.FAVAR==1 && favar.onestep==1
            scale=favar.data_exfactors_stddev(ii);
        else % on the two step procedure the data are standardised, so skip this step, no scaling, scale=1
            scale=1;
        end
        % consider shocks in turn
        for jj=1:n
            % consider IRF periods in turn
            for kk=1:IRFperiods
                % compute first the lower bound
                %irf_estimates{ii,jj}(1,kk)=quantile(irf_record{ii,jj}(:,kk),(1-IRFband)/2);
                irf_estimates{ii,jj}(1,kk)=quantile(irf_record{ii,jj}(:,kk),(1-IRFband)/2)/scale;
                % then compute the median
                %irf_estimates{ii,jj}(2,kk)=quantile(irf_record{ii,jj}(:,kk),0.5);
                irf_estimates{ii,jj}(2,kk)=quantile(irf_record{ii,jj}(:,kk),0.5)/scale;
                % finally compute the upper bound
                %irf_estimates{ii,jj}(3,kk)=quantile(irf_record{ii,jj}(:,kk),1-(1-IRFband)/2);
                irf_estimates{ii,jj}(3,kk)=quantile(irf_record{ii,jj}(:,kk),1-(1-IRFband)/2)/scale;
            end
        end
    end
    
    % D estimates and gamma estimates
    for ii=1:n^2
        D_estimates(ii,1)=quantile(D_record(ii,1),0.5);
    end
    gamma_estimates=reshape(eye(n),n^2,1);
    
    
    if favar.FAVAR==1 && favar.npltX>0
        favar_irf_record=favar.IRF.favar_irf_record;
        % create first the cell that will contain the IRF estimates
        favar.IRF.favar_irf_estimates=cell(favar.npltX,n);
        
        % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
        % consider variables in turn
        for ii=1:favar.npltX
            if favar.onestep==1
                scale=favar.X_stddev(1,favar.plotX_index(ii));
            else % on the two step procedure the data are standardised, so skip this step, no scaling, scale=1
                scale=1;
            end
            % consider shocks in turn
            for jj=1:n
                % consider IRF periods in turn
                for kk=1:IRFperiods
                    % compute first the lower bound
                    favar.IRF.favar_irf_estimates{ii,jj}(1,kk)=quantile(favar_irf_record{ii,jj}(:,kk),(1-IRFband)/2)/scale;
                    % then compute the median
                    favar.IRF.favar_irf_estimates{ii,jj}(2,kk)=quantile(favar_irf_record{ii,jj}(:,kk),0.5)/scale;
                    % finally compute the upper bound
                    favar.IRF.favar_irf_estimates{ii,jj}(3,kk)=quantile(favar_irf_record{ii,jj}(:,kk),1-(1-IRFband)/2)/scale;
                end
            end
        end
    end
    
    
elseif strctident.MM==1
    [medianmodel,~,~]=find_medianmodel(n,irf_record,IRFperiods,IRFband);
    for ii=1:n
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                %lower bound
                irf_estimates{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),(1-IRFband)/2);
                %medianmodel
                irf_estimates{jj,ii}(2,kk)=irf_record{jj,ii}(medianmodel,kk);
                % upper bound
                irf_estimates{jj,ii}(3,kk)=quantile(irf_record{jj,ii}(:,kk),IRFband+(1-IRFband)/2);
            end
        end
    end
    
    % D estimates and gamma estimates
    D=reshape(D_record(:,medianmodel),n,n);
    gamma=eye(n);
    D_estimates=D(:);
    gamma_estimates=gamma(:);
    
    if favar.FAVAR==1 && favar.npltX>0
        favar_irf_record=favar.IRF.favar_irf_record;
        % create first the cell that will contain the IRF estimates
        favar.IRF.favar_irf_estimates=cell(favar.npltX,n);
        
        % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
        % consider variables in turn
        for ii=1:favar.npltX
            if favar.onestep==1
                scale=favar.X_stddev(1,favar.plotX_index(ii));
            else % on the two step procedure the data are standardised, so skip this step, no scaling, scale=1
                scale=1;
            end
            % consider shocks in turn
            for jj=1:n
                % consider IRF periods in turn
                for kk=1:IRFperiods
                    % compute first the lower bound
                    favar.IRF.favar_irf_estimates{ii,jj}(1,kk)=quantile(favar_irf_record{ii,jj}(:,kk),(1-IRFband)/2)/scale;
                    % then compute the median
                    favar.IRF.favar_irf_estimates{ii,jj}(2,kk)=favar_irf_record{ii,jj}(medianmodel,kk)/scale;
                    % finally compute the upper bound
                    favar.IRF.favar_irf_estimates{ii,jj}(3,kk)=quantile(favar_irf_record{ii,jj}(:,kk),1-(1-IRFband)/2)/scale;
                end
            end
        end
    end
    
end

