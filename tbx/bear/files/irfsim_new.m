function [ortirfmatrix]=irfsim_new(beta,D,n,m,p,k,horizon)



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



% first reshape beta to obtain B
B=reshape(beta,k,n);

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


% obtain now orthogonalised IRFs
% loop over periods
for ii=1:horizon
ortirfmatrix(:,:,ii)=irfmatrix(:,:,ii)*D;
end









