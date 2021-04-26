function [irfmatrix ortirfmatrix]=mairfsim(B,D,p,n,horizon)



% function [irfmatrix ortirfmatrix]=mairfsim(B,D,p,n,horizon)
% computes IRF matrices and orthogonalised IRF matrices
% inputs:  - matrix 'B': the matrix containing the VAR coefficients, defined in (3.5.10)
%          - matrix 'D': the structural decomposition matrix
%          - integer 'p': the number of lags in the model
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'horizon':the number of periods for which IRFs have to be produced
% outputs: - matrix 'irfmatrix': a 3D matrix recording the IRFs (each page represents one period)
%          - matrix 'ortirfmatrix': a 3D matrix recording the orthogonalised IRFs (each page represents one period)



% deal with shocks in turn
for ii=1:n


% create a matrix of zeros of dimension p*n
Y=zeros(p,n);
% set the value of the last row, column ii, equal to 1
Y(p,ii)=1;


   % repeat the algorithm from period T+1 to period T+h
   for jj=1:horizon-1
  
   % use the function lagx to obtain the matrix X; retain only the last row
   X=lagx(Y,p-1);
   X=X(end,:);

   % obtain predicted value for T+jj
   yp=X*B;

   % place yp at the top of the matrix Y
   Y=[Y;yp];

   % repeat until values are obtained for T+h
   end


% trim the p initial conditions in Y: what remains are the IRFs
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









