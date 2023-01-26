function [medianmodel, upperboundmodel, lowerboundmodel]=find_medianmodel(n,irf_record,IRFperiods, IRFband)
standardize=1;
        Accepted_draws=size(irf_record{1,1},1);
        distance=cell(n,n);
        distancesum=cell(n,n);
%step 1: get the median for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_median{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),0.5);
                end
            end
        end
        
        
if standardize==1
%step 1: get the mean for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_mean{jj,ii}(1,kk)=mean(irf_record{jj,ii}(:,kk));
                end
            end
        end
        
 %step 2: get the standard deviation 
         for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_std{jj,ii}(1,kk)=std(irf_record{jj,ii}(:,kk));
                end 
            end
         end
         
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = ((irf_record{kk,jj}(yy,pp)-irf_median{kk,jj}(1,pp))/irf_std{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
         
else        


        
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = (irf_record{kk,jj}(yy,pp)-irf_median{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
end 
        
        %step 3: Sum over distance
        for kk=1:n %select row of cells of hd_record
            for jj=1:n %select column of cell of hd_record
                for yy=1:Accepted_draws %loop over accepted draws
                    distancesum{kk,jj}(yy,1) = sum(distance{kk,jj}(yy,:));
                end
            end
        end
        collect=0;
        %step 4: collaps the distance in each model
        for yy=1:Accepted_draws %loop over accepted draws
            for nn=1:n  %loop over variables and collect the entry for this model
                for kk=1:n %loop over contributors
                    collect=collect+distancesum{kk,nn}(yy,1);
                end
            end
            finaldistance(yy,1)=collect;
            collect=0;
        end
        [~, medianmodel]=min(finaldistance);  %%find the difference from the median
   
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%upper bound model%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        distance=cell(n,n);
        distancesum=cell(n,n);
%step 1: get the median for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_upperbound{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),IRFband+(1-IRFband)/2);
                end
            end
        end
        
        
if standardize==1
%step 1: get the mean for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_mean{jj,ii}(1,kk)=mean(irf_record{jj,ii}(:,kk));
                end
            end
        end
        
 %step 2: get the standard deviation 
         for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_std{jj,ii}(1,kk)=std(irf_record{jj,ii}(:,kk));
                end 
            end
         end
         
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = ((irf_record{kk,jj}(yy,pp)-irf_upperbound{kk,jj}(1,pp))/irf_std{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
         
else        


        
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = (irf_record{kk,jj}(yy,pp)-irf_upperbound{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
end 
        
        %step 3: Sum over distance
        for kk=1:n %select row of cells of hd_record
            for jj=1:n %select column of cell of hd_record
                for yy=1:Accepted_draws %loop over accepted draws
                    distancesum{kk,jj}(yy,1) = sum(distance{kk,jj}(yy,:));
                end
            end
        end
        collect=0;
        %step 4: collaps the distance in each model
        for yy=1:Accepted_draws %loop over accepted draws
            for nn=1:n  %loop over variables and collect the entry for this model
                for kk=1:n %loop over contributors
                    collect=collect+distancesum{kk,nn}(yy,1);
                end
            end
            finaldistance(yy,1)=collect;
            collect=0;
        end
        [~, upperboundmodel]=min(finaldistance);  %%find the difference from the median        
        
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%lower bound model%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        distance=cell(n,n);
        distancesum=cell(n,n);
%step 1: get the median for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_lowerbound{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),(1-IRFband)/2);
                end
            end
        end
        
        
if standardize==1
%step 1: get the mean for each variable, each shock and each period
        for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_mean{jj,ii}(1,kk)=mean(irf_record{jj,ii}(:,kk));
                end
            end
        end
        
 %step 2: get the standard deviation 
         for ii=1:n
            % loop over variables
            for jj=1:length(irf_record)
                % loop over time periods
                for kk=1:IRFperiods
                    irf_std{jj,ii}(1,kk)=std(irf_record{jj,ii}(:,kk));
                end 
            end
         end
         
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = ((irf_record{kk,jj}(yy,pp)-irf_lowerbound{kk,jj}(1,pp))/irf_std{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
         
else        


        
        %step 2: Calculate the squared distance from the median
        for kk=1:n %select row of cells of irf_record
            for jj=1:n %select column of cell irf_record
                for yy=1:Accepted_draws %loop over accepted draws
                    for pp=1:IRFperiods
                        distance{kk,jj}(yy,pp) = (irf_record{kk,jj}(yy,pp)-irf_lowerbound{kk,jj}(1,pp))^2;
                    end
                end
            end
        end
end 
        
        %step 3: Sum over distance
        for kk=1:n %select row of cells of hd_record
            for jj=1:n %select column of cell of hd_record
                for yy=1:Accepted_draws %loop over accepted draws
                    distancesum{kk,jj}(yy,1) = sum(distance{kk,jj}(yy,:));
                end
            end
        end
        collect=0;
        %step 4: collaps the distance in each model
        for yy=1:Accepted_draws %loop over accepted draws
            for nn=1:n  %loop over variables and collect the entry for this model
                for kk=1:n %loop over contributors
                    collect=collect+distancesum{kk,nn}(yy,1);
                end
            end
            finaldistance(yy,1)=collect;
            collect=0;
        end
        [~, lowerboundmodel]=min(finaldistance);  %%find the difference from the median        
        
      
        
%         rank = tiedrank(finaldistance)/length(finaldistance); %assign a rank to the models based on their squared distance from the median 
%        %find the upperbound
%        for jj=1:length(rank)
%           upperbounddistance(jj,1)=(rank(jj,1)-(1-IRFband)/2)^2;
%        end
%        [~,upperboundmodel] = min(upperbounddistance); %find the entry corresponding to the minimum distance from the upperbound in terms of percentiles
%         
%        %find the lowerboundmodel
%        for jj=1:length(rank)
%           lowerbounddistance(jj,1)=(rank(jj,1)-(IRFband+(1-IRFband)/2))^2;
%        end
%        [~,lowerboundmodel] = min(lowerbounddistance); %find the entry corresponding to the minimum distance from the upperbound in terms of percentiles
%     
        %finally use the IRFs of this model
end 