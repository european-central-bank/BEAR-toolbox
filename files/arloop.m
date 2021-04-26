function arvar=arloop(data_endo,const,p,n)


% function arvar=arloop(data_endo,const,p,n)
% computes individual OLS estimations of autoregressive models and record their residual variances, as stated p16 of technical guide
% inputs:  - matrix 'data_endo': matrix of endogenous data used for model estimation
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - vector 'arvar': residual variance of individual AR models estimated for each endogenous variable




%loop over the columns of data_endo
for ii=1:n
% estimate an AR model with p lags for each series
% and record residual variance in vector ARvar
[~,~,arvar(ii,1),~,~,~,~,~,~,~,~,~,~,~,~]=olsvar(data_endo(:,ii),[],const,p);
end

























