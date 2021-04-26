function [struct_irf_record D_record gamma_record hd_record ETA_record IVcorrelation PofIVcorrelation beta_gibbs_reshuffle sigma_gibbs_reshuffle]=irfres_zeros_magn_correl_fevd_bayesian_stvol4(beta_gibbs, sigma_gibbs, It, Bu,betahat,sigmahat,IRFperiods,n,m,p,k,T,signrestable,signresperiods, relmagnrestable, relmagnresperiods, names, startdate, enddate, ShockwithInstrument, Ycycle, Xcycle, signreslabels, FEVDresperiods, FEVDrestable, data_exo, HD, const, exo, InstrumentforCorrel, IRFt, YincLags, Psi_gibbs)
%betahat = betahatcycle                                                                                                       irfres_zeros_magn_correl_fevd_bayesian_stvol4(beta_gibbs, sigma_gibbs, It, Bu,betahatcycle,sigmahatcycle,IRFperiods,n,m,p,k,T,signrestable,signresperiods, relmagnrestable, relmagnresperiods, namespostratining, startdateposttraining, enddate, strctident.ShockwithInstrument, Ycycle, Xcycle, signreslabels, FEVDresperiods, FEVDrestable,data_exo, HD, 0, exo, strctident.InstrumentforCorrel, IRFt, YincLags);
%sigmahat = sigmahatcycle
%names =namespostraining
%startdate = startdateposttraining
%ShockwithInstrument =  strctident.ShockwithInstrument
%InstrumentforCorrel = strctident.InstrumentforCorrel

% inputs:  - matrix 'betahat': OLS estimate for beta
%          - matrix 'sigmahats': OLS estimate for sigma
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - cell 'signrestable': table recording the sign restriction input from the user
%          - cell 'signresperiods': table containing the periods corresponding to each restriction
%          - string 'ShockwithInstrument' Name of the shock where the instrument belongs to
% outputs: - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - integer 'Qdraw': total number of draws of the Q matrix
%          - integer 'Qsuccess': number of successful draws of the Q matrix



tic

%%Phase 1: Preliminary tasks

%% draw from VAR posterior
%sample beta and sigma from the VAR distribution centered around the OLS estimate
inv_sigma_hat = inv(sigmahat); %invert sigmahat as it is frequently used afterwards
Acc=It-Bu; %%number of minimum draws accepted


%% Preliminiaries for sign restrictions
% now identify all the periods concerned with restrictions
% first expand the non-empty entries in signresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; I don't think this can done without a loop
temp=cell2mat(signresperiods(~cellfun(@isempty,signresperiods)));
periods=[];
for ii=1:size(temp,1)
    periods=[periods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
periods=sort(unique(periods))';
% count the total number of restriction periods (required for IRF matrix)
nperiods=size(periods,1);

% Identify the restriction matrices
% create five cells, corresponding to the three possible restrictions:
% one cell for sign restrictions, three cells for magnitude restrictions, one cell for zero restrictions
Scell=cell(1,n);
Mcell=cell(1,n);
Mlcell=cell(1,n);
Mucell=cell(1,n);
Zcell=cell(1,n);

% Check if value and periods restrictions correspond to each other
if sum(sum(~cellfun(@isempty,signresperiods) == ~cellfun(@isempty,signrestable))) == n^2
    % All cells with sign restrictions also specify the horizon over which
    % these are applied
else
    disp('Warning: Value restrictions do not correspond to period restrictions one to one')
    pause(1)
end

% loop over rows and columns of the period matrix
for ii=1:n
    for jj=1:n
        % if entry (ii,jj) of the period matrix and of the value matrix is not empty...
        if ~isempty(signresperiods{ii,jj}) && ~isempty(signrestable{ii,jj})
            % ... then there is a restriction over one (or several) periods
            % loop overt those periods
            for kk=signresperiods{ii,jj}(1,1):signresperiods{ii,jj}(1,2)
                % identify the position of the considered period within the list of all periods (required to build the matrix)
                position=find(periods==kk);
                % now create the restriction matrix: this will depend on the type of restriction
                % if it is a positive sign restriction...
                if strcmp(signrestable{ii,jj},'+')
                    % ... then input a 1 entry in the corresponding S matrix
                    Scell{1,jj}=[Scell{1,jj};zeros(1,n*nperiods)];
                    Scell{1,jj}(end,(position-1)*n+ii)=1;
                    % if it is a negative sign restriction...
                elseif strcmp(signrestable{ii,jj},'-')
                    % ... then input a -1 entry in the corresponding S matrix
                    Scell{1,jj}=[Scell{1,jj};zeros(1,n*nperiods)];
                    Scell{1,jj}(end,(position-1)*n+ii)=-1;
                    % if it is a zero restriction...
                elseif strcmp(signrestable{ii,jj},'0')
                    % ... then input a 1 entry in the corresponding Z matrix
                    Zcell{1,jj}=[Zcell{1,jj};zeros(1,n*nperiods)];
                    Zcell{1,jj}(end,(position-1)*n+ii)=1;
                    % else, a non-empty entry being neither a sign nor a zero restriction has to be a magnitude restriction
                else
                    % fill the corresponding M matrices:
                    % input a 1 in M
                    Mcell{1,jj}=[Mcell{1,jj};zeros(1,n*nperiods)];
                    Mcell{1,jj}(end,(position-1)*n+ii)=1;
                    % input the lower value of the interval in Ml
                    temp=str2num(signrestable{ii,jj});
                    Mlcell{1,jj}=[Mlcell{1,jj};temp(1,1)];
                    % input the upper value of the interval in Mu
                    Mucell{1,jj}=[Mucell{1,jj};temp(1,2)];
                end
            end
        end
    end
end

%% Preliminaries for relative magnitude restrictions
% now identify all the periods concerned with relative magnitude
% restrictions
% first expand the non-empty entries in magresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4];
temp=cell2mat(relmagnresperiods(~cellfun(@isempty,relmagnresperiods)));
mperiods=[];
for ii=1:size(temp,1)
    mperiods=[mperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
mperiods=sort(unique(mperiods))';
% count the total number of restriction periods (required for IRF matrix)
rmperiods=size(periods,1);

%create matrix entry for relative magnitude restrictions
[r clm] = find(~cellfun('isempty',relmagnrestable));
%2. Indentify which entry corresponds to the positive magnitude
%restriction (which shock is supposed to have a larger impact on which
%variable)
num_magres=length(r)/2; %number of relative magnitude restrictions
IndextempL=double.empty;
kk=1; %number of the restrictions
IndextempS=double.empty;
kk=1; %%number of restriction

rowsS = [];
columnsS = [];
for jj=1:num_magres %%loop over number of magnitude restrictions
    strtemp = strcat('S',num2str(jj)); %%find entry in the table corresponding to the Stronger than restriction
    Stronger = strcmp(relmagnrestable, strtemp);
    [rowS columnS] = find(Stronger==1);
    rowsS = [rowsS rowS];
    columnsS = [columnsS columnS];
end

rowsW = [];
columnsW = [];
for jj=1:num_magres
    strtemp = strcat('W',num2str(jj));
    Weaker = strcmp(relmagnrestable, strtemp);
    [rowW columnW] = find(Weaker==1);
    rowsW = [rowsW rowW];
    columnsW = [columnsW columnW];
end

%% Preliminiaries for IV correlation restrictions
%%load the instrument
ShockwithIV = find(contains(signreslabels,ShockwithInstrument)); %find index for the Shock with correlation restriction

% check for correlation restrictions
if isempty(ShockwithIV)%when there is no shock with an extra instrument
    IVcorrelcheck=0; %there is noting to check
    IVcorrelation=nan(Acc,1); %empty vector such that the paralel loop doesnt crash
    IVcorrel=nan(T,1); %empty vector such that the paralel loop doesnt crash
    PofIVcorrelation=nan(Acc,1); %empty vector such that the paralel loop doesnt crash
    ETA_record=nan(Acc,1); %empty vector such that the paralel loop doesnt crash
    IVcorrel='noexist'; %empty vector such that the paralel loop doesnt crash
    OverlapIVcorrelinY='noexist';%empty vector such that the paralel loop doesnt crash
    Flipcorrel=0; %there is nothing to flip
else
    IVcorrelcheck=1;
end
if IVcorrelcheck==1
    [IVcorrel txtcorrel]=xlsread('data.xlsx','IV');
    
    Index = strcmp(txtcorrel(1,:), InstrumentforCorrel);           %find the instrument in the IV sheet
    IVnum = find(Index==1, 1, 'first')-1;
    IVcorrel = IVcorrel(:, IVnum);
    IVcorrel = IVcorrel(~isnan(IVcorrel));
    txtcorrel = txtcorrel(2:length(IVcorrel)+1,1);              % drop IV names from txt
    date = names(2:end,1);                                   %get the datevector of the VAR
    startlocationY_in_Y=find(strcmp(date,startdate));        %location of sample startdate in Y datevector
    endlocationY_in_Y=find(strcmp(date,enddate));            %location of sample enddate in Y datevector
    date = date(startlocationY_in_Y+p:endlocationY_in_Y,:);  %cut datevector of Y such that it corresponds to the time dates used in the VAR
    OverlapIVcorrelinY = ismember(date,txtcorrel);           %Use this to cut EPS
    OverlapYinIVcorrel = ismember(txtcorrel,date);           %Use this to cut IV
    IVcorrel = IVcorrel(OverlapYinIVcorrel,:);               %cut all the entries from IV that are not in the sample
end

IsNotIdentified = find(contains(signreslabels,'shock'));        %find not identified shock
IsIdentified = find(~contains(signreslabels,'shock'));    %
if min(IsNotIdentified)==0
    identified=n;
else
    identified=min(IsNotIdentified)-1;                              %number of identified shocks
end

%finally check if there are sign restrictions on the shock of interest. If
%not we can use the flipped entry of the rotation matrix aswell
if ~isempty(ShockwithIV)
    if isempty(Scell{1,ShockwithIV})
        FlipCorrel=1;
    else
        FlipCorrel=0;
    end
end


%% Preliminaries for FEVD restriction
% now identify all the periods concerned with FEVD restrictions
% first expand the non-empty entries in FEVDresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4];
temp=cell2mat(FEVDresperiods(~cellfun(@isempty,FEVDresperiods)));
FEVDperiods=[];
for ii=1:size(temp,1)
    FEVDperiods=[FEVDperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
FEVDperiods=sort(unique(FEVDperiods))';
% count the total number of restriction periods (required for IRF matrix)
FEVDperiodstot=size(FEVDperiods,1);

%create matrix entry for relative magnitude restrictions
[rowsFEVD clmFEVD] = find(~cellfun('isempty',FEVDrestable));
num_FEVDres=length(rowsFEVD); %number of FEVD restrictions

%check if rows are unique. Two FEVD restrictions for one variable are not
%included in the algorithm. Two columns (shocks) are fine.
uniquerows = unique(rowsFEVD);

if length(uniquerows) < length(rowsFEVD)
    error('Two FEVD restrictions for one variable are not permitted')
end


%now identify if the FEVD restrictions are absolute ones or relative ones
numrelativeFEVD =0;
numabsoluteFEVD =0;
for kk=1:num_FEVDres
    if strcmp(FEVDrestable{rowsFEVD(kk,1),clmFEVD(kk,1)},'Relative')==1
        numrelativeFEVD=numrelativeFEVD+1;
        rowrelativeFEVD(kk,1)=rowsFEVD(kk,1); %rows are the variables for the FEVD
        clmrelativeFEVD(kk,1)=clmFEVD(kk,1);%Columns are the variables for the FEVD
    elseif strcmp(FEVDrestable{rowsFEVD(kk,1),clmFEVD(kk,1)},'Absolute')==1
        numabsoluteFEVD=numabsoluteFEVD+1;
        rowabsoluteFEVD(kk,1)=rowsFEVD(kk,1);%rows are the variables for the FEVD
        clmabsoluteFEVD(kk,1)=clmFEVD(kk,1); %Columns are the variables for the FEVD
    end
end

%if no restriction of one kind exist,set empty cells
if numabsoluteFEVD ==0
    rowabsoluteFEVD = [];
    clmabsoluteFEVD = [];
end

if numrelativeFEVD ==0
    rowrelativeFEVD = [];
    clmrelativeFEVD = [];
end


%% preliminaries for historical decomposition
contributors = n + 1 + 1 + length(exo); %variables + constant + exogenous + initial conditions
hd_estimates2=cell(contributors+2,n); %shocks+constant+initial values+exogenous+unexplained+to be explained by shocks only

%% Check kind of restrictions
% now check what kind of restrictions apply among sign, zero and magnitude restrictions
% check for sign restrictions: if there are any, at least one entry in the cell Scell is non-empty
if sum(~cellfun(@isempty,Scell))~=0
    signres=1;
else
    signres=0;
end
% similarly check for zero restrictions
if sum(~cellfun(@isempty,Zcell))~=0
    zerores=1;
else
    zerores=0;
end
% check for absolute magnitude restrictions
if sum(~cellfun(@isempty,Mcell))~=0
    magnres=1;
else
    magnres=0;
end
% check for relative magnitude restrictions
if length(columnsS)~=0
    relmagnres=1;
else
    relmagnres=0;
end
% check for correlation restrictions
if isempty(ShockwithIV)%when there is no shock with an extra instrument
    IVcorrelcheck=0;
else
    IVcorrelcheck=1;
end
% check for FEVD restrictions
if numabsoluteFEVD ==0 && numrelativeFEVD==0 %when there are no absolute and no relative FEVD restrictions
    FEVDcheck=0;
else
    FEVDcheck=0;
end

%%Activate the restriction, that unidentified shocks should not have the
%%same pattern as identified
patterncheck=0;
%%activate the possibility of absolute relative magnitude restriction
%%(i.e. credit spreads should rise by more than interest rates fall)
%%--> abs(credit spread) > abs(interes rate) instead of
%%--> credit spread>interest rate
ABS=0;

%% Storage cells
% create first the cell that will store the results from the simulations
struct_irf_record=cell(n,n);
% storage cell
storage1=cell(Acc,1);
storage2=cell(Acc,1);
storage3=cell(Acc,1);
storage4=cell(Acc,1);
In= eye(n);

% initiate rotation draws
not_successful = 0;
hbar = parfor_progressbar(Acc,'Progress of Sign, Magnitude, Zero, Correlation and FEVD Restriction Draws');  %create the progress bar

%rearrange Psidraw such that it can be accessed in a parfor loop
for yyy=1:It-Bu
    for kkk=1:n 
Psi_gibbs_new(:,kkk,yyy) = Psi_gibbs{1,kkk}(:,yyy);
    end
end 

parfor ii=1:Acc
    % initiate the variable 'success'; this variable will be used to check whether the restrictions are satisfied
    % if there are only zero restrictions, they will be satisfied by construction, and 'success' will simply be ignored
    success=0;
    % how the algorithm will be conducted will depend on the types of restrictions implemented
    % if there are only zero restrictions, the algorithm is simple as no checking is required: the conditions are satisfied by construction
   if zerores==1 && signres==0 && magnres==0 && relmagnres==0
   % draw beta and sigma
   beta=beta_gibbs(:,ii);
   sigma=reshape(sigma_gibbs(:,ii),n,n);
   hsigma=chol(nspd(sigma),'lower');
   % obtain orthogonalised IRFs
   [~, ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
   % generate the stacked IRF matrix
   stackedirfmat=[];
      for kk=1:numel(periods)
      stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(kk,1)+1)];
      end
   % draw an entire random matrix Q satisfying the zero restrictions
   [Q]=qzerores(n,Zcell,stackedirfmat);
   % there is no need to verify the restrictions: there are satisfied by construction



   % if there are sign/magnitude/correlation restrictions, possibly associated with zero restrictions
   else
        % the algorithm becomes a bit more complicated as conditions now need to be checked
        % to maintain efficiency, the algorithm proceeds recursively shock by shock, and stops as soon as a condition on the considered shock fails
        % repeat algorithm for the iteration as long as not all conditions are satisfied
        while success==0
            not_successful = not_successful+1;
            % switch 'success' to 1; it will be turned back to zero if at any time Q is detected as a candidate not satisfying the restrictions
            success=1;
            % draw randomly the vector of VAR coefficients: draw a random index
            index=floor(rand*(Acc))+1;
            % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
            beta=beta_gibbs(:,index);
            sigma=reshape(sigma_gibbs(:,index),n,n);
            hsigma=chol(nspd(sigma),'lower');
            %also draw the corresponding local mean
            Psidraw = Psi_gibbs_new(:,:,index)
            %create the vector Ydraw by subtracting the local mean from the data
            Ypsi = YincLags(p+1:end,:)-Psidraw(p+1:end,:);
            %ultimately create the RHS and LHS of the demeaned data VAR
            temp=lagx(Ypsi,p);
            % to build X, take off the n initial columns of current data
            Xdraw=[temp(:,n+1:end)];
            Ydraw=temp(:,1:n);
            % obtain orthogonalised IRFs
            [~, ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
            % generate the stacked IRF matrix
            stackedirfmat=[];
            for kk=1:numel(periods)
                stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(kk,1)+1)];
            end
            
            % now start looping over the shocks and checking sequentially whether conditions on these shocks hold
            % stop as soon as one restriction fails
            okay = zeros(n,1); %initiate okay vector
            Qjstore = [];
            % initiate Qj
            Qj=[];
            jj=1;
            while success==1 && jj<=n && sum(okay)<n
                    % draw a random vector from the standard normal
                    if okay(1,1)==0 %first find the first column
                        qj=qrandj(n,Zcell{1,jj},stackedirfmat,Qj);
                        % obtain the candidate column fj
                        fj=stackedirfmat*qj;
                        [success qj]=checksignres(Scell{1,jj},qj,fj);
                        if success==1
                            Qjstore=[Qj qj];
                            Qj(:,1) = qj; %set column yy of Qj to qj
                            jj=1+1;
                            okay(1,1)=1;
                        end
                    else
                        x=normrnd(0,1,n,1);
                        qj=(In-Qjstore*Qjstore')*x/norm((In-Qjstore*Qjstore')*x);
                        %compute the rotated impulse responses
                        fj=stackedirfmat*qj;
                        [success, qj, okay, yy]=checksignres_inc_other_shocks(qj, fj, Scell, okay, IRFt, n);
                        if success==1
                            Qjstore=[Qj qj];
                            Qj(:,yy) = qj; %set column yy of Qj to qj
                            jj=jj+1;
                        end
                    end

            
            %once all n columns are build and fullfill the sign restriction
            %% if sign and magnitude restrictions are fullfilled, check proxy correlation restriction
            if size(Qj,2)==n && success==1  && IVcorrelcheck==1
                %disp('I reached correlation restrictions')
                D=hsigma*Qj;
                % recover the VAR coefficients, reshaped for convenience
                B=reshape(beta,k,n);
                % obtain the residuals from (this draw)
                EPS=Ydraw-Xdraw*B;
                %compute structural shocks
                ETA=D\EPS';
                [success corIV pivShockwithIV Qj] = CheckCorrelWithIV(ETA,n,ShockwithIV, IVcorrel,OverlapIVcorrelinY, FlipCorrel, Qj);
                if success==1
                    disp('correlation restriction fulfilled');
                end
            end
            %% check relative magnitudes
            if size(Qj,2)==n && success==1  && relmagnres==1
                %              disp('I reached magnitude restrictions')
                D=hsigma*Qj;
                [~, ortirfmatrixmagnitude]=irfsim(beta,D,n,m,p,k,max(IRFperiods,max(mperiods)));
                % generate the stacked IRF matrix
                stackedirfmatmagn=[];
                for kk=1:numel(mperiods)
                    stackedirfmatmagn=[stackedirfmatmagn;ortirfmatrixmagnitude(:,:,mperiods(kk,1)+1)];
                end
                [success]=checkrelmag(stackedirfmatmagn,columnsS, columnsW, rowsS, rowsW, n, mperiods, ABS);
                if success ==1
                    disp('Magnitude Restrictions fullfilled')
                end
            end
            
            %% if sign, zero and relative magnitude restrictions are fullfilled, check FEVD restrictions
            if size(Qj,2)==n && success==1  && FEVDcheck==1
                disp('I reached FEVD restrictions')
                D=hsigma*Qj; %again compute D
                [~,ortirfmatrixFEVD]=irfsim(beta,D,n,m,p,k,IRFperiods); %obtain orthogonalized IRFs
                % record the results in the cell irf_record
                %check FEVDrestrictions
                [success] = CheckFEVDrestriction(ortirfmatrixFEVD,IRFperiods,n,D,FEVDperiodstot, clmrelativeFEVD, rowrelativeFEVD, rowabsoluteFEVD, clmabsoluteFEVD, FEVDresperiods, rowsFEVD);
                if success==1
                    disp('FEVD restriction fulfilled');
                end
            end
            
            end 
            %finally compute the historical decomposition
            if size(Qj,2)==n && success==1  && HD==1
                D=hsigma*Qj;
                B=reshape(beta,k,n);
                % obtain the residuals from (this draw)
                EPS=Ydraw-Xdraw*B;
                %compute structural shocks
                ETA=D\EPS';
                Psidrawcut = Psidraw(2*p:end,:);
                %decompose the data into trend and cycle and further
                [hd_estimates] = hd_new_for_signres_stvol4(0,beta,k,n,p,D,m,T,Xdraw,Ydraw, data_exo, contributors, hd_estimates2, Psidrawcut, YincLags(2*p+1:end,:));
            end
            % repeat this loop until a succesful draw is obtained

        end %end of while loop ´
        % with succesful Qj at hand, eventually set Q as Qj
        Q=Qj;
   end %end of if loop
    % store
    for kk=1:IRFperiods
        storage1{ii,1}(:,:,kk)=ortirfmatrix(:,:,kk)*Q;
    end
    storage2{ii,1}=hsigma*Q;
    % store historical decompositions
    if HD==1
        storage3{ii,1}=hd_estimates;
        storage4{ii,1}=ETA;
    end
    storage5(:,ii) = beta;
    storage6(:,ii) = vec(sigma);

    %lpdf = irfpdf(hsigma*Q,betahat,aux1,T,sigmahat,beta);
    %lpdfirf(ii,1)=lpdf;
    if IVcorrelcheck==1
        IVcorrelation(ii,1)=corIV;
        PofIVcorrelation(ii,1)=pivShockwithIV;
    else 
        IVcorrelation(ii,1)=0;
        PofIVcorrelation(ii,1)=0;
    end
    %  FEVDrestrictionvalue(ii,1) = FEVDrestrictionvalue;
    hbar.iterate(1);   % update progress by one iteration
end
close(hbar);   %close progress bar


beta_gibbs_reshuffle = storage5; %save the reshuffled beta and sigma such that they correspond to the structural matrix D
sigma_gibbs_reshuffle = storage6;
% reorganise storage
% loop over iterations
for ii=1:Acc
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
%reorganize historical decompositions
hd_record=cell(contributors+2,n);
if HD==1
    for ii=1:Acc %loop over draws
        for kk=1:contributors+2 %loop over contributors
            for ll=1:n %loop over variables
                hd_record{kk,ll}(ii,:) = storage3{ii,1}{kk,ll};
            end
        end
    end
end
ETA_record=cell(n,1);
if HD==1
    for jj=1:Acc
        for kk=1:n
            ETA_record{kk,1}(jj,:)= storage4{jj,1}(kk,:);
        end
    end
end

%hdrecord is ordered such that columns are variables and rows are contributors
%row n+1 = contribution of the constant
%row n+2 = contribution of initial conditions (past shocks)
%row n+3 = unexplained part (for partially identified model
%row n+4 = part that was left to explain by the structural shocks after
%accounting for exogenous, constant and initial conditions

toc
fprintf('Accepted Draws in Percent of Total Number of Draws: %f', 100*(Acc)/(not_successful + Acc))
end




