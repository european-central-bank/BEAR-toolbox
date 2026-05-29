function [retransformed_ortirfmatrix]=favar_retransX_ortirfmatrix(ortirfmatrix,transformationindex,levels)
% number of variables and shocks, and iterations (It-Bu)
[n1,n2,n3]=size(ortirfmatrix);
ItBu=1;
% initialise
retransformed_ortirfmatrix=zeros(size(ortirfmatrix));
% different treatment for different cases
if levels==1 % only cum sum, also for second differences
    for oo=1:n2 % shocks
        for ll=1:n1 %  variables
            if transformationindex(ll)==1 %1: no transformation, Level
                retransformed_ortirfmatrix(ll,oo,:)=ortirfmatrix(ll,oo,:);
            elseif transformationindex(ll)==2
                retransformed_ortirfmatrix(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),3); %2: First Difference
                %retransformed_ortirfmatrix(ll,oo,:)=ortirfmatrix(ll,oo,:);
            elseif transformationindex(ll)==3
                %retransformed_irf_record(ll,oo,:)=cumsum(ortirfmatrix{ll,oo},2);    %3: Second Difference
                retransformed_ortirfmatrix(ll,oo,:)=ortirfmatrix(ll,oo,:);
            elseif transformationindex(ll)==4
                %retransformed_irf_record(ll,oo,:)=ortirfmatrix{ll,oo};
                retransformed_ortirfmatrix(ll,oo,:)=exp(ortirfmatrix(ll,oo,:))-ones(ItBu,1);       %4: Log-Level
            elseif transformationindex(ll)==5
                %retransformed_irf_record(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),2); %5: Log-First-Difference
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(ortirfmatrix(ll,oo,:),3))-ones(ItBu,1); %5: Log-First-Difference
            elseif transformationindex(ll)==6
                %retransformed_irf_record(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),2); %6: Log-Second-Difference
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(ortirfmatrix(ll,oo,:),3))-ones(ItBu,1); %5: Log-First-Difference
            end
        end
    end
elseif levels==2 % exp + cum sum
    for oo=1:n2 % shocks
        for ll=1:n1 % variables
            if transformationindex(ll)==1 %1: no transformation, Level
                retransformed_ortirfmatrix(ll,oo,:)=ortirfmatrix(ll,oo,:);
            elseif transformationindex(ll)==2
                retransformed_ortirfmatrix(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),3); %2: First Difference
            elseif transformationindex(ll)==3
                retransformed_ortirfmatrix(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),3);    % 6: Second Difference
            elseif transformationindex(ll)==4
                retransformed_ortirfmatrix(ll,oo,:)=exp(ortirfmatrix(ll,oo,:),3)-ones(ItBu,1);       %4: Log-Level
            elseif transformationindex(ll)==5
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(ortirfmatrix(ll,oo,:),3))-ones(ItBu,1); %5: Log-First-Difference
            elseif transformationindex(ll)==6
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(ortirfmatrix(ll,oo,:),2))-ones(ItBu,1); %6: Log-Second-Difference
            end
        end
    end
elseif levels==3 % exp + cum sum + cum sum for second differences types
    for oo=1:n2 % shocks
        for ll=1:n1 %  variables
            if transformationindex(ll)==1 %1: no transformation, Level
                retransformed_ortirfmatrix(ll,oo,:)=ortirfmatrix(ll,oo,:);
            elseif transformationindex(ll)==2
                retransformed_ortirfmatrix(ll,oo,:)=cumsum(ortirfmatrix(ll,oo,:),3); %2: First Difference
            elseif transformationindex(ll)==3
                retransformed_ortirfmatrix(ll,oo,:)=cumsum(cumsum(ortirfmatrix(ll,oo,:),3),3);    % 6: Second Difference
            elseif transformationindex(ll)==4
                retransformed_ortirfmatrix(ll,oo,:)=exp(ortirfmatrix(ll,oo,:))-ones(ItBu,1);       %4: Log-Level
            elseif transformationindex(ll)==5
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(ortirfmatrix(ll,oo,:),3))-ones(ItBu,1); %5: Log-First-Difference
            elseif transformationindex(ll)==6
                retransformed_ortirfmatrix(ll,oo,:)=exp(cumsum(cumsum(ortirfmatrix(ll,oo,:),3),3))-ones(ItBu,1); %6: Log-Second-Difference
            end
        end
    end
    
else % do nothing, e.g. levels=0
    retransformed_ortirfmatrix=ortirfmatrix;
end
