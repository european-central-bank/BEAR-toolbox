function [irfmatrix,ortirfmatrix,irflmatrix,ortirflmatrix]=irfsim(beta,D,n,m,p,k,horizon,prior)

% [irfmatrix ortirfmatrix]=irfsim(beta,D,n,m,p,k,horizon)
% computes IRF matrices and orthogonalised IRF matrices
% inputs:  - vector 'beta': vectorised form of VAR coefficients (defined in 1.1.12)
%          - matrix 'D': structural matrix for the OLS model (defined in 2.3.3)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'horizon': number of IRF periods
% outputs: - matrix 'irfmatrix': record of the series of irf matrices
%          - matrix 'ortirfmatrix': record of the series of orthogonalised irf matrices

% lt_id=1 if long-term restrictions apply
lt_id=max(horizon)==1000;
if numel(horizon)>1
   % define horizon as second highest in sorted list of horizons if lt_id=1
   horizon=lt_id*horizon(end-1)+(1-lt_id)*horizon(end);
else
   % define horizon at zero (no marginal/short-term IRFs produced) if lt_id=1
   horizon=lt_id*0+(1-lt_id)*horizon;
end

% first reshape beta to obtain B
B=reshape(beta,k,n);


if prior==61 % special case: mean adjusted BVAR
for ii=1:n


% create a matrix of zeros of dimension p*n
Y=zeros(p,n);
% set the value of the last row, column i, equal to 1
Y(p,ii)=1;


      %repeat the algorithm from period T+1 to period T+h
   for jj=1:horizon-1
        
   %use the function lagx to obtain the matrix X; retain only the last row
   X=lagx(Y,p-1);
   X=X(end,:);

   %obtain predicted value for T+jj
   yp=X*B;

   %place yp at the top of the matrix Y
   Y=[Y;yp];

   %repeat until values are obtained for T+h
   end

% consider 'Y' and trim the (p-1) initial periods: what remains is the series of IRFs for period T to period T+h-1
Y=Y(p:end,:);

   % loop over periods
   for jj=1:horizon
   
      % loop over variables
      for kk=1:n
      irfmatrix(kk,ii,jj)=Y(jj,kk);
      end

   end

% conduct the same process with shocks in other variables
end
   
   
   else
   
% deal with shocks in turn
for ii=1:n


% create a matrix of zeros of dimension p*n
Y=zeros(p,n);
% set the value of the last row, column i, equal to 1
Y(p,ii)=1;

   % repeat the algorithm from period T+1 to period T+h
   for jj=1:horizon-1
   % step 1
   % use the function lagx to obtain the matrix temp, containing the endogenous regressors
   temp=lagx(Y,p-1);
   % step 2
   % define the vector X
   X=[temp(end,:) zeros(1,m)];
   % step 3
   % obtain the predicted value for T+jj
   yp=X*B;
   % step 4
   % concatenate yp at the top of Y
   Y=[Y;yp];
   % repeat until values are obtained for T+h
   end
 
% consider 'Y' and trim the (p-1) initial periods: what remains is the series of IRFs for period T to period T+h-1
Y=Y(p:end,:);


% record the results in the matrix irfmatrix

   % loop over periods
   for jj=1:horizon
   
      % loop over variables
      for kk=1:n
      irfmatrix(kk,ii,jj)=Y(jj,kk);
      end

   end

% conduct the same process with shocks in other variables
end
end

% obtain now orthogonalised IRFs
% loop over periods
for ii=1:horizon
    ortirfmatrix(:,:,ii)=irfmatrix(:,:,ii)*D;
end


if lt_id && prior~=61
   % remove parameters related to exogenous variables
   B=B(1:end-m,:);
   B=reshape(B,n,p,n);

   % obtain long-run cumulative IRFs
   irflmatrix=eye(n)/(eye(n)-squeeze(sum(B,2))');
   
   % obtain long-run cumulative orthogonolized IRFs
   ortirflmatrix=irflmatrix*D;
else
   % need to produce output
   irflmatrix=[];
   ortirflmatrix=[];
end






