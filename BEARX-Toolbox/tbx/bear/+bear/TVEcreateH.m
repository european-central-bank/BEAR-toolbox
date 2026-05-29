function [TVEH TVEHfuture]=TVEcreateH(equilibrium,r,T,p,Fperiods)
% The function TVEcreateH(equilibrium,r,T) creates the array H in system
% (*) to estimate deterministic trends in the TVE-VAR approach. If n is the
% number of variables, equilibrium is a (1 x n) vector in which each
% element indicates if the equilibrium of the corresponding variable is
% constant (if equal to 1), has a linear trend (if equal to 2), or a
% quadratic trend (if equal to 3); r is a (1 x n) vector in which each
% element is the number of regimes for each variable; T is the time length.

if isempty(Fperiods)
    Fperiods=0;
end
    
T=T+p+Fperiods;
n=length(r); % number of variables
q=equilibrium*r'; % dimension of theta
rbar=max(r); % number of regimes

%% Initialize
H=zeros(n,q,rbar,T);
counter=1;
J1=find(r==1); % The set of variables that do not change regime
Jr=find(r~=1); % The set of variables that change regime

%% First part
% First consider the variables that don't change regime
for indj1=1:length(J1)
    j=J1(indj1);
    for t=1:T 
        for i=1:rbar
            if equilibrium(j)==1
                H(j,counter,i,t)=1;
            elseif equilibrium(j)==2
                H(j,counter:counter+1,i,t)=[1 t];
            else
                H(j,counter:counter+2,i,t)=[1 t t^2];
            end
        end
    end
    counter=counter+equilibrium(j);
end

%% Second part
% Then consider the variables that change regime
for i=1:rbar
    for indjr=1:length(Jr)
        j=Jr(indjr);
        for t=1:T
            if equilibrium(j)==1
                H(j,counter,i,t)=1;
            elseif equilibrium(j)==2
                H(j,counter:counter+1,i,t)=[1 t];
            else
                H(j,counter:counter+2,i,t)=[1 t t^2];
            end
        end
        counter=counter+equilibrium(j);
    end
end

TVEH=H(:,:,:,1:end-Fperiods);
TVEHfuture=H(:,:,:,end-Fperiods+1:end);

end        
                


