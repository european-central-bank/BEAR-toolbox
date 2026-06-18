function [forecastmatrix] = ogrTVEmaforecastsim(yhattemp, B, p, n, Fcperiods)

temp1 = reshape(yhattemp(sort(1:p,'descend'),:)',1,n*p);% compute the matrix exo

% repeat the process for periods T+1 to T+h

for jj = 1:Fcperiods

   yhattemp = temp1*B;    
   % obtain predicted value for T+jj by using (3.5.9)
   yhatforc(jj,:) = yhattemp;

   temp1 = [yhattemp temp1(1:(n*p-n))];     % as changed on 2018 05 

end

% record the values in the matrix forecastmatrix
forecastmatrix = yhatforc;



