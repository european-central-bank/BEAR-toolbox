function [retransformed_contributions2,retransformed_HDTobeexplained_plotX]=...
    favar_retransX_contributions2(contributions2,HDTobeexplained_plotX,transformationindex,levels)
% number of variables and shocks, and iterations (It-Bu)
%[n1,n2]=size(contributions2);
ItBu=1;
%%% skip the restransformation in the HD
levels=0;
%%%
% initialise
% different treatment for different cases
if levels==1
    if transformationindex==1
        % no transformation, do nothing
        retransformed_contributions2=contributions2;
        retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
    elseif transformationindex==2
        retransformed_contributions2=contributions2;
        retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
    elseif transformationindex==3
        retransformed_contributions2=contributions2;
        retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
    elseif transformationindex==4
%         retransformed_contributions2=exp(contributions2)-ones(ItBu,1);
%         retransformed_HDTobeexplained_plotX=exp(HDTobeexplained_plotX)-ones(ItBu,1);
        retransformed_contributions2=exp(contributions2)-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(HDTobeexplained_plotX)-ones(ItBu,1);
    elseif transformationindex==5
%         retransformed_contributions2=exp(cumsum(contributions2))-ones(ItBu,1);
%         retransformed_HDTobeexplained_plotX=exp(cumsum(HDTobeexplained_plotX))-ones(ItBu,1);
        retransformed_contributions2=cumsum(contributions2);
        retransformed_HDTobeexplained_plotX=cumsum(HDTobeexplained_plotX);
    elseif transformationindex==6
        retransformed_contributions2=exp(cumsum(contributions2))-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(cumsum(HDTobeexplained_plotX))-ones(ItBu,1);
    end
elseif levels==2
    if transformationindex==1
        % no transformation, do nothing
        retransformed_contributions2=contributions2;
        retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
    elseif transformationindex==2
        retransformed_contributions2=cumsum(contributions2);
        retransformed_HDTobeexplained_plotX=cumsum(HDTobeexplained_plotX);
    elseif transformationindex==3
        retransformed_contributions2=cumsum(contributions2);
        retransformed_HDTobeexplained_plotX=cumsum(HDTobeexplained_plotX);
    elseif transformationindex==4
        retransformed_contributions2=exp(contributions2)-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(HDTobeexplained_plotX)-ones(ItBu,1);
    elseif transformationindex==5
        retransformed_contributions2=exp(cumsum(contributions2))-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(cumsum(HDTobeexplained_plotX))-ones(ItBu,1);
    elseif transformationindex==6
        retransformed_contributions2=exp(cumsum(contributions2))-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(cumsum(HDTobeexplained_plotX))-ones(ItBu,1);
    end
elseif levels==3
    if transformationindex==1
        % no transformation, do nothing
        retransformed_contributions2=contributions2;
        retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
    elseif transformationindex==2
        retransformed_contributions2=cumsum(contributions2);
        retransformed_HDTobeexplained_plotX=cumsum(HDTobeexplained_plotX);
    elseif transformationindex==3
        retransformed_contributions2=cumsum(cumsum(contributions2));
        retransformed_HDTobeexplained_plotX=cumsum(cumsum(HDTobeexplained_plotX));
    elseif transformationindex==4
        retransformed_contributions2=exp(contributions2)-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(HDTobeexplained_plotX)-ones(ItBu,1);
    elseif transformationindex==5
        retransformed_contributions2=exp(cumsum(contributions2))-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(cumsum(HDTobeexplained_plotX))-ones(ItBu,1);
    elseif transformationindex==6
        retransformed_contributions2=exp(cumsum(cumsum(contributions2)))-ones(ItBu,1);
        retransformed_HDTobeexplained_plotX=exp(cumsum(cumsum(HDTobeexplained_plotX)))-ones(ItBu,1);
    end
    
else % do nothing, e.g. levels=0
    retransformed_contributions2=contributions2;
    retransformed_HDTobeexplained_plotX=HDTobeexplained_plotX;
end
