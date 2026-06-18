function [hd_estimates] = hd_new_for_signres(const,exo,beta,k,n,p,D,m,T,X,Y,IRFt,signreslabels_shocks)
%computes the historical decomposition for the series
%ouput hd_estimates = cell array where columns capture variables, and rows
%the contributions of shocks, exogenous, constant and initial conditions to
%these variables. The second to last rows capture the unexplained part for models
%that are not fully identified, while the last row captures the part of
%the fluctuation that should be explained by the VAR, after accounting for
%exogenous/deterministic components.

%row 1 to n = contribution of shock x the movement in variable y hd_estimates(x,y)
%row n+1 = contribution of the constant
%row n+2 = contribution of initial conditions (past shocks)
%row n+3 = unexplained part (for partially identified model
%row n+4 = part that was left to explain by the structural shocks after
%accounting for exogenous, constant and initial conditions
%% Preliminaries

% preliminaries for historical decomposition
%1. Determine how many contributions we are going to calculate
contributors = n + 1 + 1 + length(exo); %variables + constant + initial conditions + exogenous
hd_estimates2=cell(contributors+2,n); %shocks+constant+initial values+exogenous+unexplained+to be explained by shocks only
% number of identified shocks
if IRFt==2 || IRFt==3
    identified=n; % fully identified
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
elseif IRFt==5
    identified=1; % one IV shock
elseif IRFt==1
    identified=0;
end

%===============================================
Bfull=reshape(beta,k,n);                     %get the Bfull matrix
B=Bfull(1:n*p,:);                            %drop the coefficients for all exogenous variables from the matrix
Bcomp = [B'; eye(n*(p-1)) zeros(n*(p-1),n)]; %put into companion form
EPS=Y-X*Bfull;                               %get reduced form residuals
ETA=(D\EPS');                                %get structural shocks


%% Compute historical decompositions
%===============================================
% Contribution of each shock
aux_D = zeros(n*p,n); %auxilary D matrix, that is consistent with companion matrix
aux_D(1:n,:) = D; %set the first entrys equal to Dinv
HDestimates_store = zeros(p*n,T+1,n); %cell aray to store results
HDestimates = zeros(n,T+1,n);
ETAcomp = zeros(n,T+1,n); %structural shock matrix that is consistent with companion form
for j=1:n % for each variable
    if j <= identified %if j is an identified shock
        ETAcomp(j,2:end,j) = ETA(j,:); %fill in the entry for shock n, leave the first entry blank
    end
end

% contribution of the initial values
HDinitial_storage   = zeros(p*n,T+1);
HDinitial_estimates = zeros(n, T+1);
Xnoexo = X(:,1:n*p);
HDinitial_storage(:,1) = Xnoexo(1,:)'; %set the initial values to the first row of X (n*P)+exo
HDinitial_estimates(:,1) = HDinitial_storage(1:n,1); %select the initial values for the first n variables (i.e. the values at Y_{t-1}

%  Contribution of the Constant
if const==1
    HDconstant_storage = zeros(p*n,T+1);
    HDconstant_estimates = zeros(n, T+1);
    Coefficients = zeros(p*n,1);
    Coefficients(1:n,:) = Bfull(n*p+1,:);
end

% Contribution of exogenous variables, no lags of exogenous variables just
% the contemporaneous values
if (m-const) >= 1
    HDexo_storage = zeros(p*n,T+1);
    HDexo_estimates = zeros(n,T+1);
    Coefficients_exo = zeros(p*n,m-const);
    data_exocut=X(:,n*p+const+1:end); % take exogenous data from X
    Coefficients_exo(1:n,:) = Bfull(n*p+const+1:end,:)'; %get the corresponding coefficients
end

for i = 2:T+1 %loop over periods and compute the impact of the initial conditions recursively
    HDestimates_store(:,i,:) = pagemtimes(aux_D, ETAcomp(:,i,:)) + pagemtimes(Bcomp, HDestimates_store(:,i-1,:)); %recursively sum over shock impulse at period i on variable j and the previous period
    HDestimates(1:n,i,:) =  HDestimates_store(1:n,i,:); %select the entry corresponding to the current period

    HDinitial_storage(:,i) = Bcomp*HDinitial_storage(:,i-1); %compute the impact of those values (which in principle consist of past shocks)
    HDinitial_estimates(:,i) = HDinitial_storage(1:n,i);

    if const==1
        HDconstant_storage(:,i) = Coefficients + Bcomp*HDconstant_storage(:,i-1);
        HDconstant_estimates(:,i) = HDconstant_storage(1:n,i);
    end

    if (m-const) >= 1
        HDexo_storage(:,i) = Coefficients_exo*data_exocut(i-1,:)' + Bcomp*HDexo_storage(:,i-1);
        HDexo_estimates(:,i) = HDexo_storage(1:n,i);
    end
end


%% put these values into the corresponding cell for hd_estimates such that
% for variable x (hd_estimates(x,n+1)) = HDinitial_estimates(x,:)
% for variable x (hd_estimates(x,n+1)) = HDconstant_estimates(x,:)
%reorganize storage
idx = 1:T+1;
for jj = 1:n
    for ii = 1:n
        hd_estimates2{ii,jj} = HDestimates(jj,idx,ii);
    end
    hd_estimates2{n+1,jj}=HDinitial_estimates(jj,idx);
    if const == 1
        hd_estimates2{n+2,jj} = HDconstant_estimates(jj,idx);
    else
        hd_estimates2{n+2,jj} = zeros(1, T+1);
    end
    if (m-const) >= 1
        hd_estimates2{n+3,jj} = HDexo_estimates(jj,idx);
    end
end

HDsum = zeros(T+1,n); %if we sum over all variables this should give Y
Exosum = zeros(T+1,n); %if we sum over all variables this should give Y
for jj=1:n %loop over variables (columns)
    summatrix = vertcat(hd_estimates2{1:contributors,jj});
    HDsum(:,jj)=sum(summatrix);

    %finally substract the sum of the contribution of the
    %exogenous, constant,initial conditions from Y to get the
    %part that was left to be explained by the shocks (for plotting reasons)
    summatrix = vertcat(hd_estimates2{n+1:contributors,jj});
    Exosum(:,jj)=sum(summatrix);
end

%determine the unexplained part (if model is not fully identified)
aux = zeros(1,n);
unexplained = Y-HDsum(2:end,:);
unexplained = [aux; unexplained];

%determine the part that was left to be explained by the shocks
aux = zeros(1,n);
tobeexplained = Y - Exosum(2:end,:);
tobeexplained = [aux; tobeexplained];

for jj=1:n
    hd_estimates2{contributors+1,jj}=unexplained(:,jj)';
    hd_estimates2{contributors+2,jj}=tobeexplained(:,jj)';
end

hd_estimates = cell(contributors+2,n);

%drop the initial entry for each cell in hd_estimates
for jj=1:n
    for ii=1:contributors+2
        hd_estimates{ii,jj}(2,:)=hd_estimates2{ii,jj}(2:end);
    end
end