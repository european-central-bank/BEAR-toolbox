
%% Construct Density Probabilities Corresponding to Grid

densitygrid = zeros(T,length(gridDF)-1);
draws = Bu;

for i=1:T
       
    for j = 1:length(gridDF)-1
        
        obj = forecasts_dist(:,ind_feval(1),i);

        logic = sum((gridDF(j)<=obj) & (obj<gridDF(j+1)));
        num = sum(logic);
        
        if isempty(num) 
            num = 0;
        end
            
        densitygrid(i,j) = (num/draws)*100;

    end
    
end

 %% Construct Midpoints of Bins in Grid
gridDF_mid = zeros(1,length(gridDF)-1);
for j = 1:length(gridDF)-1
    gridDF_mid(1,j) = (gridDF(j+1)+gridDF(j))/2;
end

%% Obtain PIT Histogram and RS Test-Statistic
result = RS_DF_Test(densitygrid,actualdata(ind_deval(1),:)',gridDF_mid',hstep,el,bootMC); 
