function [hd_estimates,favar]=hdestimates_inc_exo(hd_record,n,T,HDband,favar)



% function [hd_estimates]=bear.hdestimates(hd_record,n,T,HDband)
% calculates the point estimate (median), lower bound and upper bound of the historical decomposition from the posterior distribution
% inputs:  - cell 'hd_record': record of the gibbs sampler draws for the historical decomposition
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - scalar 'HDband': confidence level for forecasts
% outputs: - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition



% create first the cell that will contain the estimates
hd_estimates=cell(length(hd_record),n);

% for each variable, each shock and each forecast period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
    % consider shocks in turn
    for jj=1:length(hd_record)
        % consider sample periods in turn
        for kk=1:T
            % compute first the lower bound
            hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
            % then compute the median
            hd_estimates{jj,ii}(2,kk)=quantile(hd_record{jj,ii}(:,kk),0.5);
            % finally compute the upper bound
            hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),1-(1-HDband)/2);
        end
    end
end

%
if favar.FAVAR==1 && favar.HDplot==1
    for nn=1:favar.npltX
        % loop over variables
        for ii=1:n
            % consider shocks in turn
            for jj=1:size(favar.HD.favar_hd_record,1)
                % consider sample periods in turn
                for kk=1:T
                    favar.HD.hd_estimates{jj,ii,nn}(1,kk)=quantile(favar.HD.favar_hd_record{jj,ii,nn}(:,kk),0.5);
                end
            end
        end
    end
end
