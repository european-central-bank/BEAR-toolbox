function [struct_irf_record D_record gamma_record]=irfbootstrapiv_ols(names, betahat,sigmahat,T, m,n,X,Y,k,p,enddate,startdate, endo, IRFperiods, pref, IRFband,beginInstrument, EndInstrument, IV, data_endo, data_exo, const)
% Wild Bootstrap for instrumental variable identification in an OLS setting
% the codes are based on the codes distributed by Ambrogio Cesa-Bianchi in
% his VAR toolbox
% inputs:  - matrix 'betahat': vec(OLS estimates of the reduced form)
%          - matrix 'sigmahat': vec(OLS estimates of sigma)
%          - matrix 'X': Independend Variable
%          - matrix 'Y': Dependend Variable
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the VAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of observations
%          - string  'stardate': VAR startdate
%          - string  'enddate': VAR enddate
% outputs: - cell 'struct_irf_record': record of the draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the accepted draws for the structural matrix D
%          - matrix 'gamma_record': record of the draws for the structural disturbances variance-covariance matrix gamma

%% Wild bootstrap including uncertainty about instrument
%% Create the matrices for the loop
parameters = k;
variables = n;

beta = betahat;
B    = reshape(beta,parameters,variables);
EPS  = Y-X*B;
%Cut EPS or IV such that it corresponds to the IV period

%==================================
endo_artificial = zeros(T+p,n);

%% Loop over the number of draws
%==========================================================================

AA = 1; % numbers of accepted draws
ww = 1; % index for printing on screen
BB = 1000; %Number of draws from bootstrap
while AA<=BB
    

%% STEP 1: generate the artificial data
% Initialize wild bootstrap by drawing residuals and flipping the sign at
% random get reduced form residuals

        rotationvector = 1-2*(rand(T,1)>0.5); 
        EPSrotate = EPS.*(rotationvector*ones(1,n));
%make residual series comparable with IV series and rotate the instrument       
        IVrotate = [IV(1:p,1); IV(p+1:end,1).*rotationvector(beginInstrument+p:EndInstrument)];
    %% STEP 1.1: initial values for the artificial data
    % Intialize the first p observations with real data
    Temp=[];
    for jj = 1:p
        endo_artificial(jj,:) = data_endo(jj,:);
        Temp = [endo_artificial(jj,:) Temp]; %Temp captures all the current and past realizations of the artificial series                                         %that are necesarry to produce the artificially generated data 
    end
    % Initialize the artificial series and take care of exogenous variables
    if const==0
        Temp2 = Temp;
    elseif const==1
        Temp2 = [Temp 1];
    end
    
    %% STEP 2.2: generate artificial series
    % From observation p+1 to T(number of observations), compute the artificial data
    for jj = p+1:T+p
        for mm = 1:n
            % Compute the value for time=jj
            endo_artificial(jj,mm) = Temp2 * B(1:end,mm) + EPSrotate(jj-p,mm);
        end
        % now update the Temp matrix
        if jj<T+p
            Temp = [endo_artificial(jj,:) Temp(1,1:(p-1)*n)];
            if const==0
                Temp2 = Temp;
            elseif const==1
                Temp2 = [Temp 1];
            end
        end
    end

%% STEP 3: estimate reduced form VAR on artificial data. 
[~, betadraw, sigmadraw, Xdraw, ~, Ydraw, ~, ~, ~, ~, ~, ~, ~, ~, ~]=olsvar(endo_artificial,data_exo,const,p);
%[Bdraw betadraw sigmadraw Xdraw Xbardraw Ydraw ydraw EPSdraw epsdraw n m p T k q]=olsvar(endo_artificial,data_exo,const,lags);

%% STEP 4: identify the model
[Ddraw, gammadraw]=irfiv_ols_for_bootstrap(beginInstrument,EndInstrument, names,IVrotate, betadraw,sigmadraw,m,n,Xdraw,Ydraw,k,p,enddate,startdate, endo, IRFperiods, pref);
%% Step 5: Calculate impulse responses and store them
[ortirfmatrix]=irfsim_new(betadraw,Ddraw,n,m,p,k,IRFperiods);

%% Step 6: Store the output
       for jj=1:IRFperiods
       storage1{AA,1}(:,:,jj)=ortirfmatrix(:,:,jj);
       end
       storage2{AA,1}=Ddraw; 
       beta_gibbs(:,AA)=betadraw;
       sigma_gibbs(:,AA)=vec(sigmadraw);
       AA = AA+1 ;
end
disp('-- Done!');
disp(' ');
%% Step 7: Reorganize stored output
% reorganise storage
% loop over iterations
for ii=1:BB
   % loop over IRF periods
   for jj=1:IRFperiods
      % loop over variables
      for kk=1:n
         % loop over shocks
         for ll=1:n
         struct_irf_record{kk,ll}(ii,jj)=storage1{ii,1}(kk,ll,jj);    
         end
      end
   end
D_record(:,ii)=storage2{ii,1}(:);
gamma_record(:,ii)=vec(eye(n));
end 
end 