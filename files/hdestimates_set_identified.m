function [hd_estimates,favar]=hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar)

if strctident.MM==0
    % loop over variables
    for ii=1:n
        % deal with shocks in turn
        for jj=1:length(hd_record)
            % loop over time periods
            for kk=1:T
                % consider the higher and lower confidence band for the hd
                % lower bound
                hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(HDband)/2);
                %mean value
                hd_estimates{jj,ii}(2,kk)=quantile(hd_record{jj,ii}(:,kk),0.5);
                % upper bound
                hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),HDband+(1-HDband)/2);
            end
        end
    end
    
    if favar.FAVAR==1 && favar.HD.plot==1
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
        
    elseif strctident.MM==1 %Median Model
        [medianmodel,~,~]=find_medianmodel(n,struct_irf_record,IRFperiods,HDband);
        
        for ii=1:n
            % loop over variables
            for jj=1:length(hd_record)
                % loop over time periods
                for kk=1:T
                    % consider the higher and lower confidence band for the hd
                    % lower bound
                    hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
                    %hd_estimates{jj,ii}(1,kk)= hd_record{jj,ii}(lowerboundmodel,kk);
                    %medianmodel
                    hd_estimates{jj,ii}(2,kk)= hd_record{jj,ii}(medianmodel,kk); %get the best performing model in terms of IRFs
                    % upper bound
                    hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),IRFband+(1-HDband)/2);
                    % upper bound
                    %hd_estimates{jj,ii}(3,kk)= hd_record{jj,ii}(upperboundmodel,kk);
                end
            end
        end
        
    if favar.FAVAR==1 && favar.HD.plot==1
        for nn=1:favar.npltX
            % loop over variables
            for ii=1:n
                % consider shocks in turn
                for jj=1:length(favar.HD.favar_hd_record)
                    % consider sample periods in turn
                    for kk=1:T
                        favar.HD.hd_estimates{jj,ii,nn}(1,kk)=quantile(favar.HD.favar_hd_record{jj,ii,nn}(:,kk),0.5);
                    end
                end
            end
        end
    end
end
