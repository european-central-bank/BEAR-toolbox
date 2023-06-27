function [hd_estimates] = hd_new_for_signres_61(const,exo,beta,k,n,p,D,m,T,X,Y,data_exo,IRFt,signreslabels_shocks,prior,theta,Z,k3)
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
end

%===============================================
if prior==61
    Zfull=reshape(theta,k3,n);
    Bfull=reshape(beta,k,n);
    Bfull=[Bfull;Zfull];
    B=Bfull(1:n*p,:);                           %drop the coefficients for all exogenous variables from the matrix
    Bcomp = [B'; eye(n*(p-1)) zeros(n*(p-1),n)];
    X=[X Z];
    EPS=Y-X*Bfull;                               %get reduced form residuals
    ETA=(D\EPS');                        %get structural shocks
else
Bfull=reshape(beta,k,n);                    %get the Bfull matrix
B=Bfull(1:n*p,:);                           %drop the coefficients for all exogenous variables from the matrix
Bcomp = [B'; eye(n*(p-1)) zeros(n*(p-1),n)];%put into companion form
EPS=Y-X*Bfull;                               %get reduced form residuals
ETA=(D\EPS');                        %get structural shocks
end


%% Compute historical decompositions
%===============================================
% Contribution of each shock
    aux_D = zeros(n*p,n); %auxilary D matrix, that is consistent with companion matrix
    aux_D(1:n,:) = D; %set the first entrys equal to Dinv
    Selec = [eye(n) zeros(n,(p-1)*n)]; %selection matrix
    HDestimates_store = zeros(p*n,T+1,n); %cell aray to store results 
    HDestimates = zeros(n,T+1,n);
    for j=1:n % for each variable
        ETAcomp = zeros(n,T+1); %structural shock matrix that is consistent with companion form
        if j <= identified %if j is an identified shock
        ETAcomp(j,2:end) = ETA(j,:); %fill in the entry for shock n, leave the first entry blank
        end 
        for i = 2:T+1
            HDestimates_store(:,i,j) = aux_D*ETAcomp(:,i) + Bcomp*HDestimates_store(:,i-1,j); %recursively sum over shock impulse at period i on variable j and the previous period
            HDestimates(:,i,j) =  Selec*HDestimates_store(:,i,j); %select the entry corresponding to the current period
        end
    end
    
% contribution of the initial values
    HDinitial_storage   = zeros(p*n,T+1);
    HDinitial_estimates = zeros(n, T+1);
    Xnoexo = X(:,1:n*p);
    HDinitial_storage(:,1) = Xnoexo(1,:)'; %set the initial values to the first row of X (n*P)+exo
    HDinitial_estimates(:,1) = Selec*HDinitial_storage(:,1); %select the initial values for the first n variables (i.e. the values at Y_{t-1}
    for i = 2:T+1 %loop over periods and compute the impact of the initial conditions recursively
        HDinitial_storage(:,i) = Bcomp*HDinitial_storage(:,i-1); %compute the impact of those values (which in principle consist of past shocks)
        HDinitial_estimates(:,i) = Selec*HDinitial_storage(:,i);
    end
 
%  Contribution of the Constant
    HDconstant_storage = zeros(p*n,T+1);
    HDconstant_estimates = zeros(n, T+1);
    Coefficients = zeros(p*n,1);
    if const==1
        Coefficients(1:n,:) = Bfull(n*p+1,:);
        for i = 2:T+1 %loop over periods 
            HDconstant_storage(:,i) = Coefficients + Bcomp*HDconstant_storage(:,i-1);
            HDconstant_estimates(:,i) = Selec * HDconstant_storage(:,i);
        end
    end
        
 % Contribution of exogenous variables
 if m > 1
    HDexo_storage = zeros(p*n,T+1);
    HDexo_estimates = zeros(n,T+1);
    Coefficients_exo = zeros(p*n,(m-1)*(1));
    data_exocut=data_exo(p+1:end,:); %cut initial conditions from exogenous
    Coefficients_exo(1:n,:) = Bfull(n*p+const+1:end,:)'; %get the corresponding coefficients
        for i = 2:T+1
            HDexo_storage(:,i) = Coefficients_exo*data_exocut(i-1,:)' + Bcomp*HDexo_storage(:,i-1);
            HDexo_estimates(:,i) = Selec * HDexo_storage(:,i);
        end
  end
 
 %% put these values into the corresponding cell for hd_estimates such that
 % for variable x (hd_estimates(x,n+1)) = HDinitial_estimates(x,:)
 % for variable x (hd_estimates(x,n+1)) = HDconstant_estimates(x,:)
%reorganize storage      
        for jj=1:n %for variables
            for kk=1:T+1 %for periods
                for ii=1:n %for shock contributions
                    hd_estimates2{ii,jj}(1,kk) = HDestimates(jj,kk,ii);
                end
                hd_estimates2{n+1,jj}(1,kk)=HDinitial_estimates(jj,kk);
                if const==1
                hd_estimates2{n+2,jj}(1,kk)=HDconstant_estimates(jj,kk);
                else
                hd_estimates2{n+2,jj}(1,kk)=0;                    
                end
                if m>1
                hd_estimates2{n+3,jj}(1,kk)=HDexo_estimates(jj,kk);
                end
            end
        end
        
 
 HDsum = zeros(T+1,n); %if we sum over all variables this should give Y
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T+1);
 for kk=1:T+1 %loop over periods
     sumperiod=0; 
  for ii=1:contributors %loop over contributors (rows)
      value = hd_estimates2{ii,jj}(1,kk);
      sumperiod = sumperiod+value; 
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 HDsum(:,jj)=sumvariable(1,:); 
 end 
  
 %determine the unexplained part (if model is not fully identified)
 aux = zeros(1,n);
 unexplained = Y-HDsum(2:end,:); 
 unexplained = [aux; unexplained];
for jj=1:n
    hd_estimates2{contributors+1,jj}=unexplained(:,jj)';
end 

%finally substract the sum of the contribution of the
%exogenous, constant,initial conditions from Y to get the
%part that was left to be explained by the shocks (for plotting reasons)
 Exosum = zeros(T+1,n); %if we sum over all variables this should give Y
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T+1);
 for kk=1:T+1 %loop over periods
     sumperiod=0; 
  for ii=n+1:contributors %loop over contributors (rows)
      value = hd_estimates2{ii,jj}(1,kk);
      sumperiod = sumperiod+value; 
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 Exosum(:,jj)=sumvariable(1,:); 
 end 
 
 %determine the part that was left to be explained by the shocks
 aux = zeros(1,n);
 tobeexplained = Y - Exosum(2:end,:); 
 tobeexplained = [aux; tobeexplained];
for jj=1:n
    hd_estimates2{contributors+2,jj}=tobeexplained(:,jj)';
end

hd_estimates = cell(contributors+2,n);

%drop the initial entry for each cell in hd_estimates
for jj=1:n
    for ii=1:contributors+2
        hd_estimates{ii,jj}=hd_estimates2{ii,jj}(2:end);
    end
end

