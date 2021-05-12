function [Y1,X1]=data_forecast(data_endo,Fperiods,Fendlocation,n,cforecast_estimates,p)
%this function creates matrices of data and conditional forecasts

Yf=zeros(Fperiods,n);
for zz=1:n
  Yf(1:Fperiods,zz)=cforecast_estimates{zz}(2,:)';
end
data_endo=[data_endo(1:Fendlocation-Fperiods+p,:);Yf];
Xall=lagx(data_endo,p);
Y1=Xall(:,1:n);    
X1=[Xall(:,n+1:end) ones(Fendlocation,1)];
