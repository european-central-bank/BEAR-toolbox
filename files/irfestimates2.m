function [irf_estimates_allt,favar]=irfestimates2(irf_record_allt,n,T,IRFperiods,IRFband,endo,stringdates1,pref,favar)

% Favar preliminaries
if favar.FAVAR==1
    npltX=favar.npltX;
    if npltX>0
        favar_FAVAR=1;
    else
        favar_FAVAR=0;
    end
else
    favar_FAVAR=0;
end


if favar_FAVAR==1
    % create first the cell that will contain the IRF estimates
    favar.IRF.favar_irf_estimates_allt=cell(favar.npltX,n);
    %check if the variables have been transformed
    if favar.transformation==1 || favar.plot_transform==1
        % re-transform favar_struct_irf_record
        favar_irf_record_allt=favar.IRF.favar_irf_record_allt;
        favar.IRF.favar_irf_record_allt_nottransformed=favar_irf_record_allt;
        transformationindex=favar.transformationindex(favar.plotX_index,1);
        % re-transform
        [favar_irf_record_allt]=favar_retransX_irf_record(favar_irf_record_allt,transformationindex,favar.levels);
        % save
        favar.IRF.favar_irf_record_allt=favar_irf_record_allt;
        
        % re-transform irf_record
        favar.IRF.irf_record_allt_nottransformed=irf_record_allt; % before, save untransformed IRFs
        transformationindex_endo=favar.transformationindex_endo;
        % re-transform
        [irf_record_allt]=favar_retransX_irf_record(irf_record_allt,transformationindex_endo,favar.levels);
    end
    
    % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
    % consider variables in turn
    for ii=1:npltX
        if favar.onestep==1
            scale=favar.X_stddev(1,favar.plotX_index(ii));
        else % on the two step procedure the data are standardised, so skip this step, no scaling, scale=1
            scale=1;
        end
        % consider shocks in turn
        for jj=1:n
            % consider IRF periods in turn
            for kk=1:IRFperiods
                % consider sample periods in turn
                for tt=1:T
                    % compute first the lower bound
                    favar.IRF.favar_irf_estimates_allt{ii,jj}(1,kk,tt)=quantile(favar_irf_record_allt{ii,jj}(:,kk,tt),(1-IRFband)/2)/scale;
                    % then compute the median
                    favar.IRF.favar_irf_estimates_allt{ii,jj}(2,kk,tt)=quantile(favar_irf_record_allt{ii,jj}(:,kk,tt),0.5)/scale;
                    % finally compute the upper bound
                    favar.IRF.favar_irf_estimates_allt{ii,jj}(3,kk,tt)=quantile(favar_irf_record_allt{ii,jj}(:,kk,tt),1-(1-IRFband)/2)/scale;
                end
            end
        end
    end
    
    
    
    % create first the cell that will contain the IRF estimates
    irf_estimates_allt=cell(n,n);
    
    % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
    % consider variables in turn
    for ii=1:n
        if favar.onestep==1
            scale=favar.data_exfactors_stddev(ii);
        else % on the two step procedure the data are standardised, so skip this step, no scaling, scale=1
            scale=1;
        end
        % consider shocks in turn
        for jj=1:n
            % consider IRF periods in turn
            for kk=1:IRFperiods
                % consider sample periods in turn
                for tt=1:T
                    % compute first the lower bound
                    irf_estimates_allt{ii,jj}(1,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),(1-IRFband)/2)/scale;
                    % then compute the median
                    irf_estimates_allt{ii,jj}(2,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),0.5)/scale;
                    % finally compute the upper bound
                    irf_estimates_allt{ii,jj}(3,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),1-(1-IRFband)/2)/scale;
                end
            end
        end
    end
    
    
    
else % normal procedure without FAVARs
    
    % create first the cell that will contain the IRF estimates
    irf_estimates_allt=cell(n,n);
    
    % for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
    % consider variables in turn
    for ii=1:n
        % consider shocks in turn
        for jj=1:n
            % consider IRF periods in turn
            for kk=1:IRFperiods
                % consider sample periods in turn
                for tt=1:T
                    % compute first the lower bound
                    irf_estimates_allt{ii,jj}(1,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),(1-IRFband)/2);
                    % then compute the median
                    irf_estimates_allt{ii,jj}(2,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),0.5);
                    % finally compute the upper bound
                    irf_estimates_allt{ii,jj}(3,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),1-(1-IRFband)/2);
                end
            end
        end
    end
end


% save on Excel
if pref.results==1
    % compute the cell for the time varying VAR coefficients
    % initiate the cell that will be saved on excel
    IRFcell={};
    % then loop over endogenous
    for ii=1:n
        varcell={};
        % loop over shocks
        for jj=1:n
            % create temporary cell
            temp={};
            temp=[{''} {''} {'Periods'} stringdates1' {''} {''} {''};repmat({''},IRFperiods+4,T+6)];
            temp{3,1}='response of:';
            temp{3,2}=endo{ii,1};
            temp{4,1}='to shocks in:';
            temp{4,2}=endo{jj,1};
            % loop over IRF periods
            for kk=1:IRFperiods
                temp{2+kk,3}=kk;
                % loop over sample periods
                for tt=1:T
                    temp{2+kk,3+tt}=irf_estimates_allt{ii,jj}(2,kk,tt);
                end
            end
            varcell=[varcell temp];
        end
        IRFcell=[IRFcell;varcell];
    end
    
    % write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],IRFcell,'IRF time variation','B2');
end

