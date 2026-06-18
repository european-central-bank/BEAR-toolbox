function [Y, X] = lj_get_XY_format(data_endo,data_exo,const,lags)

    % first compute N, the number of units, as the dimension of the data_endo matrix
    N=size(data_endo,3);

    % then compute n, the number of endogenous variables in the model; it is simply the number of columns in the matrix 'data_endo'
    n=size(data_endo,2);

    % compute m, the number of exogenous variables in the model
    % if data_exo is empty, set m=0
    if isempty(data_exo)==1
      % if data_exo is not empty, count the number of exogenous variables that will be included in the model
    else
      % Also, trim a number initial rows equal to the number of lags, as they will be suppressed from the endogenous as well to create initial conditions
      data_exo=data_exo(lags+1:end,:);
    end


    Y = [];
    X = [];
    % Yi = [];
    % Xi = [];
    for ii = 1:N
      % use the lagx function on the data matrix
      temp=bear.lagx(data_endo(:,:,ii),lags);
      % set Yi as the first n columns of the result
      % Yi(:,:,ii)=temp(:,1:n);
      Y = [Y temp(:,1:n)];

      % to build Xi, take off the n initial columns of temp
      % Xi(:,:,ii)=[temp(:,n+1:end)];
      X = [X temp(:,n+1:end)];
    end

    % add exogenous variables to the end
    X = [X data_exo];
end