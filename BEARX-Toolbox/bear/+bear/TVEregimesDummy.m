%% Creates D-matrix to calculate trends endogenously

function D = TVEregimesDummy(startdate,regimeperiods,T)
% TVEregimesDummy(startdate,regimeperiods,X) creates is a matrix in which
% each row is a selector vector of the active regime

gdates=eval(sprintf(startdate(1:4)))+eval(sprintf(startdate(6)))*0.25:0.25:eval(sprintf(startdate(1:4)))+eval(sprintf(startdate(6)))*0.25-0.25+T/4;
NumberofRegimes=size(regimeperiods,1)+1;

% Create the dummy variable
D=zeros(T,NumberofRegimes);
for it=1:NumberofRegimes-1
    NumberofPeriods=size( regimeperiods(it,:),2)/2;
    for it2=1:NumberofPeriods
        startperiod=eval(sprintf(regimeperiods{it,2*it2-1}(1:4)))+eval(sprintf(regimeperiods{it,2*it2-1}(6)))*0.25;
        endperiod=eval(sprintf(regimeperiods{it,2*it2}(1:4)))+eval(sprintf(regimeperiods{it,2*it2}(6)))*0.25;
        startD=find(gdates==startperiod);
        endD=find(gdates==endperiod);
        D(startD:endD,it+1)=1;
    end
end
if NumberofRegimes>1
    D(:,1)=1-sum(D(:,2:end),2);
else
    D(:,1)=ones(size(D,1),1);
end

end

