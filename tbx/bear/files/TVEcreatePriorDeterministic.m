function [m0,C0] = TVEcreatePriorDeterministic(equilibrium,r,data_endo,Dmatrix,f,Fpconfint,Fpconfint2)

% TVEcreatePriorDeterministic(equilibrium,r,X,D,f) gives the mean and the
% variance covariance matrix of a Normal distribution, to be used as prior
% density for the coefficients of deterministic trends estimated in the
% TVE-VAR approach

% Initialize
T=size(data_endo,1); % time length
NumberofRegimes=size(Dmatrix,2); % number of regimes
nvar=size(data_endo,2); % number of variables
q=equilibrium*r'; % dimension of theta

m0=zeros(q,1);
C0=zeros(q,q);
counter=1;
J1=find(r==1);
Jr=find(r~=1);

% Partition the data for different regimes
Xregimes=zeros(T,nvar,NumberofRegimes);
for j=1:nvar
    for i=1:NumberofRegimes
        Xregimes(:,j,i)=data_endo(:,j).*Dmatrix(:,i);
    end
end

% Create time matrix as regressors for OLS estimates
time=(1:T)';
timesq=time.^2;
timematrix=[ones(T,1) time timesq];

% 1) First part: the variables that don't change regime
for indj1=1:length(J1)
    j=J1(indj1);
    if equilibrium(j)==1 && isnan(Fpconfint{j}(1,1))~=1;
    m0(counter:counter+equilibrium(j)-1)=(Fpconfint{j}(1,1)+Fpconfint{j}(1,2))/2;
    C0(counter:counter+equilibrium(j)-1,counter:counter+equilibrium(j)-1)=((Fpconfint{j}(1,2)-Fpconfint{j}(1,1))/(1.96*2))^2;
    else
    [m0(counter:counter+equilibrium(j)-1),C0(counter:counter+equilibrium(j)-1,counter:counter+equilibrium(j)-1)]=OLSPriorTheta(data_endo(:,j),timematrix(:,1:equilibrium(j)),f);
    end
    counter=counter+equilibrium(j);
end

Fpconfintmatrix=[Fpconfint Fpconfint2];

% 2) Second part: the variables that change regime
for i=1:NumberofRegimes
    for indjr=1:length(Jr)
        j=Jr(indjr);
        if equilibrium(j)==1 && isnan(Fpconfintmatrix{j,i}(1,1))~=1;
        m0(counter:counter+equilibrium(j)-1)=(Fpconfintmatrix{j,i}(1,1)+Fpconfintmatrix{j,i}(1,2))/2; 
        C0(counter:counter+equilibrium(j)-1,counter:counter+equilibrium(j)-1)=((Fpconfintmatrix{j,i}(1,2)-Fpconfintmatrix{j,i}(1,1))/(1.96*2))^2;
        else; 
        indic=find(Dmatrix(:,i)==1);
        datatemp=Xregimes(indic,j,i);
        timetemp=timematrix(indic,1:equilibrium(j));
        [m0(counter:counter+equilibrium(j)-1),C0(counter:counter+equilibrium(j)-1,counter:counter+equilibrium(j)-1)]=OLSPriorTheta(datatemp,timetemp,f);    
        end;
        counter=counter+equilibrium(j);
    end
end
end

