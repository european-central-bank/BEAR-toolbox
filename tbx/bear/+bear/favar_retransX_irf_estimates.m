
function [retransformed_irf_estimates]=favar_retransX_irf_estimates(irf_estimates,transformationindex,levels)
% number of variables and shocks, and iterations (It-Bu)
[n1,n2]=size(irf_estimates);
ItBu=1;
% initialise
retransformed_irf_estimates=cell(size(irf_estimates));
% different treatment for different cases
if levels==1 % only cum sum, also for second differences
    for oo=1:n1 % variables
        for ll=1:n2 % shocks
            for ii=1:3 %for up.,median,low.
                if transformationindex(oo)==1 %1: no transformation, Level
                    retransformed_irf_estimates{oo,ll}(ii,:)=irf_estimates{oo,ll}(ii,:);
                elseif transformationindex(oo)==2
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(irf_estimates{oo,ll}(ii,:),2); %2: First Difference
%                     retransformed_irf_estimates{oo,ll}(ii,:)=irf_estimates{oo,ll}(ii,:);
                elseif transformationindex(oo)==3
                    %retransformed_irf_record{oo,ll}(ii,:)=cumsum(irf_record{oo,ll}(ii,:),2);    %3: Second Difference
                    retransformed_irf_estimates{oo,ll}(ii,:)=irf_estimates{oo,ll}(ii,:);
                elseif transformationindex(oo)==4
                    %retransformed_irf_record{oo,ll}(ii,:)=irf_record{oo,ll}(ii,:);
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(irf_estimates{oo,ll}(ii,:))-ones(ItBu,1);       %4: Log-Level
                elseif transformationindex(oo)==5
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(irf_estimates{oo,ll}(ii,:),2); %5: Log-First-Difference
%                     retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(irf_estimates{oo,ll}(ii,:),2))-ones(ItBu,1); %5: Log-First-Difference
                elseif transformationindex(oo)==6
                    %retransformed_irf_record{oo,ll}(ii,:)=cumsum(irf_record{oo,ll}(ii,:),2); %6: Log-Second-Difference
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(irf_estimates{oo,ll}(ii,:),2))-ones(ItBu,1); %5: Log-First-Difference
                end
            end
        end
    end
elseif levels==2 % exp + cum sum
    for oo=1:n1 % variable
        for ll=1:n2 % shocks
            for ii=1:3 %for up.,median,low.
                if transformationindex(oo)==1 %1: no transformation, Level
                    retransformed_irf_estimates{oo,ll}(ii,:)=irf_estimates{oo,ll}(ii,:);
                elseif transformationindex(oo)==2
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(irf_estimates{oo,ll}(ii,:),2); %2: First Difference
                elseif transformationindex(oo)==3
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(irf_estimates{oo,ll}(ii,:),2);    % 6: Second Difference
                elseif transformationindex(oo)==4
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(irf_estimates{oo,ll}(ii,:))-ones(ItBu,1);       %4: Log-Level
                elseif transformationindex(oo)==5
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(irf_estimates{oo,ll}(ii,:),2))-ones(ItBu,1); %5: Log-First-Difference
                elseif transformationindex(oo)==6
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(irf_estimates{oo,ll}(ii,:),2))-ones(ItBu,1); %6: Log-Second-Difference
                end
            end
        end
    end
elseif levels==3 % exp + cum sum + cum sum for second differences types
    for oo=1:n1 % variables
        for ll=1:n2 % shocks
            for ii=1:3 %for up.,median,low.
                if transformationindex(oo)==1 %1: no transformation, Level
                    retransformed_irf_estimates{oo,ll}(ii,:)=irf_estimates{oo,ll}(ii,:);
                elseif transformationindex(oo)==2
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(irf_estimates{oo,ll}(ii,:),2); %2: First Difference
                elseif transformationindex(oo)==3
                    retransformed_irf_estimates{oo,ll}(ii,:)=cumsum(cumsum(irf_estimates{oo,ll}(ii,:),2),2);    % 6: Second Difference
                elseif transformationindex(oo)==4
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(irf_estimates{oo,ll}(ii,:))-ones(ItBu,1);       %4: Log-Level
                elseif transformationindex(oo)==5
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(irf_estimates{oo,ll}(ii,:),2))-ones(ItBu,1); %5: Log-First-Difference
                elseif transformationindex(oo)==6
                    retransformed_irf_estimates{oo,ll}(ii,:)=exp(cumsum(cumsum(irf_estimates{oo,ll}(ii,:),2),2))-ones(ItBu,1); %6: Log-Second-Difference
                end
            end
        end
    end
    
else % do nothing, e.g. levels=0
    retransformed_irf_estimates=irf_estimates;
end
