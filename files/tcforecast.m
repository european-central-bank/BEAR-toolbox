function [cforecast_record]=tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,It,Bu)














% initiate the cell storing the draws for the conditional forecasts
cforecast_record=cell(n,1);


% first record the conditions supplied by the user
% initiate the record matrix
% column 1: variable ; column 2: forecast horizon ; column 3: condition value ; column 4: quantile
rec=[];
% loop over variables
for ii=1:n
   % loop over forecast periods
   for jj=1:Fperiods
      % check whether there is a constraint for variable ii at forecast horizon T+jj
      if ~isempty(cfconds{jj,ii})
      % if there is a condition, add a row to the record matrix to save the information
      rec=[rec;zeros(1,4)];
      % then record the variable, forecast horizon, condition and quantile (here the median, thus 0.5 quantile)
      rec(end,:)=[ii jj cfconds{jj,ii} 0.5];
         % if the conditions cover also intervals, record the additional information for the interval
         if CFt==4
         % record the variable, forecast horizon, value and quantile for the lower bound
         rec=[rec;zeros(1,4)];
         rec(end,:)=[ii jj cfintervals{jj,ii}(1,1) 0.5-0.5*Fband];
         % record the variable, forecast horizon, value and quantile for the upper bound
         rec=[rec;zeros(1,4)];
         rec(end,:)=[ii jj cfintervals{jj,ii}(1,2) 0.5+0.5*Fband];
         end
      end
   end
end


% determine L, the total number of conditions
L=size(rec,1);


% define pii, the vector of weights, defined in (XXX.21)
pii=repmat(1/(It-Bu),It-Bu,1);


% create the matrix G, defined in (XXX.21)
% loop over rows of G
for ii=1:It-Bu
   % loop over columns of G, using the indicator function (XXX.7) for g(y)
   for jj=1:L
   G(ii,jj)=gy(forecast_record{rec(jj,1),1}(ii,rec(jj,2)),rec(jj,3))-rec(jj,4);
   end
end


% now minimise (XXX.18), reformulated as (XXX.20), to obtain the Lagrange multipliers
% minimize
[~,lambda,~,~,~,~,~]=sims_csminwel(@(lambdatilde) lagrange(lambdatilde,pii,G),zeros(L,1),eye(L),[],1e-20,1000);


% generate g and eyepi
for ii=1:It-Bu
   % loop over columns of G, using the indicator function (XXX.7) for g(y)
   for jj=1:L
   g(ii,jj)=gy(forecast_record{rec(jj,1),1}(ii,rec(jj,2)),rec(jj,3));
   end
end
eyepi=spdiags(pii,0,It-Bu,It-Bu);


% recover piistar from (XXX.22)
piistar=((pii'*exp(g*lambda))^(-1))*eyepi*(exp(g*lambda));


% with the new weights, obtain random draws from the modified distribution
% obtain a draw from the multinomial mn~(200*(It-Bu),piistar)
multinomdraw=mnrnd(200*(It-Bu),piistar')';

% generate the sample from the new distribution
% loop over draws
for ii=1:It-Bu
   % loop over variables
   for jj=1:n
   % duplicate values
   cforecast_record{jj,1}=[cforecast_record{jj,1};repmat(forecast_record{jj,1}(ii,:),multinomdraw(ii,1),1)];
   end
end







