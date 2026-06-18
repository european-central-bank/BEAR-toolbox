function[success,val,pivShockwithIV,Qjstore] = CheckCorrelWithIV(ETA,n,CorrelShock_index,IVcorrel, OverlapIVcorrelinY, FlipCorrel,Qjstore)


ETA = ETA';
ETAcut = ETA(OverlapIVcorrelinY,:);

for kk=1:n
[cor,pvalue] = corrcoef(ETAcut(:,kk),IVcorrel);
coriv(1,kk)=cor(2,1);
corivsq(1,kk) = cor(2,1)^2;
piv(1,kk)=pvalue(2,1);
end 

if FlipCorrel==1
[val,best]=max(abs(coriv)); %%if it is allowed to flip the entry of q
else 
[val,best]=max(coriv);      %%if not find the highest positive correlation
end

[~,bestsq]=max(corivsq);

pivShockwithIV = piv(1,CorrelShock_index);

if best == CorrelShock_index && bestsq==CorrelShock_index && pivShockwithIV < 0.1
    success = 1;
else 
    success = 0;
end 

if sign(coriv(1,CorrelShock_index))==-1 &&FlipCorrel==1 && success==1 %if the sign of the correlation is positiv
Qjstore(:,CorrelShock_index) = -1*Qjstore(:,CorrelShock_index); %flip the sign of the column
end

end