%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX           %
%                                                                          %
%    Authors:                                                              % 
%                                                                          %
%    Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                       %
%    Björn van Roye  (bvanroye@bloomberg.net)                              %
%                                                                          %
%    Version 5.0                                                           %
%                                                                          %
%    The updated version 5 of BEAR has benefitted from contributions from  %
%    Boris Blagov, Marius Schulte and Ben Schumann.                        %
%                                                                          %
%    This version builds-upon previous versions where Romain Legrand was   %
%    instrumental in developing BEAR.                                      %
%                                                                          %
%    The authors are grateful to the following people for valuable input   %
%    and advice which contributed to improve the quality of the toolbox:   %
%    Paolo Bonomolo, Mirco Balatti, Marta Banbura, Niccolo Battistini,     %
%	 Gabriel Bobeica, Martin Bruns, Fabio Canova, Matteo Ciccarelli,       %
%    Marek Jarocinski, Michele Lenza, Francesca Loria, Mirela Miescu,      %
%    Gary Koop, Chiara Osbat, Giorgio Primiceri, Martino Ricci,            %
%    Michal Rubaszek, Barbara Rossi, Peter Welz and Hugo Vega de la Cruz.  %
%                                                                          %
%    These programmes are the responsibilities of the authors and not of   %
%    the ECB and all errors and ommissions remain those of the authors.    %
%                                                                          %
%    Using the BEAR toolbox implies acceptance of the End User Licence     %
%    Agreement and appropriate acknowledgement should be made.             %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%---------------------|
% Initilisation phase |
%-------------------- |

%% init.m
% first create initial elements to avoid later crash of the code
% interinfo cells: required to save data when the back button is used with the interfaces
interinfo1={};
interinfo2={};
interinfo3={};
interinfo4={};
interinfo5={};
interinfo6={};
interinfo7={};
% panel scalar (non-model value): required to have the argument for interface 6, even if a non-panel model is selected 
if VARtype==4
else 
panel=10;
end
% signreslabels empty element: required to have the argument for IRF plots, even if sign restriction is not selected 
signreslabels=[];
% Units empty element: required to record estimation information on Excel even if the selected model is not a panel VAR
Units=[];
% blockexo empty element: required to have the code run properly for the BVAR model if block exogeneity is not selected
blockexo=[];
% forecast and IRFs empty elements: required for the display of panel results if forecast/IRFs are disactivated
forecast_record=[];
forecast_estimates=[];
gamma_estimates=[];
D_estimates=[];
% gamma empty elements: required for the display of stochastic volatility results if selected model is not random inertia
gamma_median=[];

%% prelim.m
% other checks and preliminaries
% turn off incompatible combinations of options and other preliminaries
% these steps have to be done before convertsrings
% first check for favar, turn off routines if favar doesn't exist (for VARtypes other than =1)
if exist('favar','var')~=1 | favar.FAVAR==0
    favar.FAVAR=0;
    favar.HD.plot=0;
    favar.IRF.plot=0;
    favar.FEVD.plot=0;
end

if favar.FAVAR==1
    if VARtype~=2
        favar.onestep=0; % always two-step (factors are static, principal components)
    end
	
	if favar.onestep==1 && favar.blocks==1
	    message='Please select two-step estimation (favar.onestep==0) to use Blocks.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
	end
    if favar.onestep==1 || IRFt>3 || favar.blocks==1
        favar.slowfast=0;
    end
    
    if favar.slowfast==1
        favar.blocknames='slow fast'; % specify in excel sheet 'factor data'
    end
    
    % changed the variable name in the settings for clarity to favar.plotXshock
    favar.IRF.plotXshock=favar.plotXshock;
    
    if favar.FEVD.plot==1
        % choose shock(s) to plot
        favar.FEVD.plotXshock=favar.IRF.plotXshock; % this option should be removed
    end
    if IRFt>4
        message='It is currently not recommended to use IRFt 5 and IRFt 6 in a FAVAR.';
        msgbox(message,'FAVAR warning','warn','warning');
    end
    
    if favar.blocks==0
        favar.HD.plotXblocks=0;
        favar.HD.HDallsumblock=0;
    end
    
    if VARtype==2 && (prior==51 || prior==61)
        message='Please choose other prior (51, 61 are currently not supported in FAVARs.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
    end
    
    if VARtype==5 && stvol==4
        message='stvol4 is currently not supported in FAVARs.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
    end
end

if VARtype==2 && (IRFt==5 || IRFt==6)
    if  prior==21 || prior==22
    else
        message='Please choose Normal-Wishart prior (21, 22) for IRFt 5 and 6.';
        msgbox(message,'IRFt warning','Error','error');
        error('programme termination');
    end
end

if exist('strctident','var')~=1
    strctident.strctident=0;
end

if VARtype==4 || VARtype==6 % turn off the correl res routines
    strctident.CorrelInstrument="";
    strctident.CorrelShock="";
end

if IRFt==5
    strctident.MM=0; %no medianmodel in this case
end

%% convertstrngs.m
% run a script to convert string into a list of endogenous, exogenous, and units (if applicable)
% as a preliminary task, fix all the strings that may require it
startdate=bear.fixstring(startdate);
enddate=bear.fixstring(enddate);
varendo=bear.fixstring(varendo);
varexo=bear.fixstring(varexo);
datapath=bear.fixstring(pref.datapath);
% FAVAR: additional strings
if favar.FAVAR==1
    favar.plotX=bear.fixstring(favar.plotX);
    if favar.blocks==1 || favar.slowfast==1
        favar.blocknames=bear.fixstring(favar.blocknames);
    end
        if favar.blocks==1
            favar.blocknumpc=bear.fixstring(favar.blocknumpc);
        end
        if favar.IRF.plot==1
            favar.IRF.plotXshock=bear.fixstring(favar.IRF.plotXshock);
        end
    favar.transform_endo=bear.fixstring(favar.transform_endo);
end
if F==1
Fstartdate=bear.fixstring(Fstartdate);
Fenddate=bear.fixstring(Fenddate);
end
if VARtype==4
unitnames=bear.fixstring(unitnames);
end

% first recover the names of the different endogenous variables; 
% to do so, separate the string 'varendo' into individual names
% look for the spaces and identify their locations
findspace=isspace(varendo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(varendo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo=nspace+1;
% now finally identify the endogenous
endo=cell(numendo,1);
for ii=1:numendo
endo{ii,1}=varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

% FAVAR: additional strings 
if favar.FAVAR==1
% favar.plotX
findspace=isspace(favar.plotX);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.plotX)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceplotX=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numplotX=nspaceplotX+1;
% now finally identify the endogenous
favar.pltX=cell(numplotX,1);
for ii=1:numplotX
favar.pltX{ii,1}=favar.plotX(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

if favar.blocks==1 || favar.slowfast==1
findspace=isspace(favar.blocknames);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.blocknames)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceblocknames=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numblocknames=nspaceblocknames+1;
% now finally identify the endogenous
favar.bnames=cell(numblocknames,1);
for ii=1:numblocknames
favar.bnames{ii,1}=favar.blocknames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end
end

if favar.blocks==1
findspace=isspace(favar.blocknumpc);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.blocknumpc)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceblocknumpc=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numblocknumpc=nspaceblocknumpc+1;
% now finally identify the endogenous
favar.bnumpc=cell(numblocknumpc,1);
for ii=1:numblocknumpc
favar.bnumpc{ii,1}=str2num(favar.blocknumpc(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
end
end
        
if favar.IRF.plot==1
findspace=isspace(favar.IRF.plotXshock);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.IRF.plotXshock)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceplotXshock=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numplotXshock=nspaceplotXshock+1;
% now finally identify the endogenous
favar.IRF.pltXshck=cell(numplotXshock,1);
for ii=1:numplotXshock
favar.IRF.pltXshck{ii,1}=favar.IRF.plotXshock(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end
end
 
findspace=isspace(favar.transform_endo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.transform_endo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspacetransform_endo=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numtransform_endo=nspacetransform_endo+1;
% now finally identify the endogenous
favar.trnsfrm_endo=cell(numtransform_endo,1);
for ii=1:numtransform_endo
favar.trnsfrm_endo{ii,1}=str2num(favar.transform_endo(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
end
        
end


% proceed similarly for exogenous series; note however that it may be empty
% so check first whether there are exogenous variables altogether
if isempty(varexo==1)
exo={};
% if not empty, repeat what has been done with the exogenous
else
findspace=isspace(varexo);
locspace=find(findspace);
delimiters=[0 locspace numel(varexo)+1];
nspace=sum(findspace(:)==1);
numexo=nspace+1;
exo=cell(numexo,1);
   for ii=1:numexo
   exo{ii,1}=varexo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
   end
end

% finally, if applicable, recover the names of the different units
if VARtype==4
% look for the spaces and identify their locations
findspace=isspace(unitnames);
locspace=find(findspace);
% use this to set the delimiters: each unit string is located between two delimiters
delimiters=[0 locspace numel(unitnames)+1];
% count the number of units
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two unit names, so there is one unit more than the number of spaces
numunits=nspace+1;
% now finally identify the units
Units=cell(numunits,1);
   for ii=1:numunits
   Units{ii,1}=unitnames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
   end 
end


%%
%--------------------|
% Data loading phase |
%------------------- |

% initiation of Excel result file
bear.initexcel(pref);

% generate the different sets of data
% if the model is the OLS VAR,
if VARtype==1
    [names, data, data_fendo, data_endo_a, data_endo_c, data_endo_c_lags, data_exo, data_exo_a, data_exo_p, data_exo_c, data_exo_c_lags, Fperiods, Fcomp, Fcperiods, Fcenddate,endo,n,favar]...
        =bear.gensampleols(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,favar,IRFt);
    % if the model is the Bayesian VAR, the mean-adjusted BVAR, the stochastic volatility BVAR, ot the time-varying BVAR:
elseif VARtype==2 || VARtype==5 || VARtype==6
    [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4,n,favar]...
        =bear.gensample(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,ar,lambda4,PriorExcel,priorsexogenous,pref,favar,IRFt);
    % else, if the model is the panel BVAR
elseif VARtype==4
    [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4]...
        =bear.gensamplepan(startdate,enddate,Units,panel,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,ar,0,0);
elseif VARtype==7
   [names, mf_setup, data, data_endo, data_endo_a, data_endo_c, data_endo_c_lags, data_exo, data_exo_a, data_exo_p, data_exo_c, data_exo_c_lags, Fperiods, Fcomp, Fcperiods, Fcenddate]...
        =bear.gensample_mf(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref);
end


%---------------------|
% Table loading phase |
%------------------- -|

% grid search table
if VARtype==2 && hogs==1
    [grid]=bear.loadhogs(scoeff,iobs,pref);
end
% block exogeneity table
if (VARtype==2 || VARtype==5) && bex==1
    [blockexo]=bear.loadbex(endo,pref);
end
% Long run prior table
H=[];
if (VARtype==2) && lrp==1
    H=bear.loadH(pref);
end

% load sign and magnitude restrictions table, relative magnitude restrictions table, FEVD restrictions table
if IRFt==4 || IRFt==6
    [signrestable,signresperiods,signreslabels,strctident,favar]=bear.loadsignres(n,endo,pref,favar,IRFt,strctident);
    [relmagnrestable,relmagnresperiods,signreslabels,strctident,favar]=bear.loadrelmagnres(n,endo,pref,favar,IRFt,strctident);
    [FEVDrestable,FEVDresperiods,signreslabels,strctident,favar]=bear.loadFEVDres(n,endo,pref,favar,IRFt,strctident);
    [strctident,signreslabels]=bear.loadcorrelres(strctident,endo,names,startdate,enddate,lags,n,IRFt,favar,pref);
end


% mean-adjusted prior table
if VARtype==2 && prior==61
    [equilibrium,chvar,regimeperiods,Fpconfint,Fpconfint2,regime1,regime2,Dmatrix]=bear.loadmaprior(endo,exo,startdate,pref,data_endo);
end

% conditional forecast tables (for BVAR, mean-adjusted BVAR, and stochastic volatility BVAR)
if (VARtype==2 || VARtype==5 || VARtype==6||VARtype==7) && CF==1
    [cfconds,cfshocks,cfblocks,cfintervals]=bear.loadcf(endo,CFt,Fstartdate,Fenddate,Fperiods,pref);
    % conditional forecast tables (for panel BVAR model)
elseif VARtype==4 && CF==1
    [cfconds,cfshocks,cfblocks]=bear.loadcfpan(endo,Units,panel,CFt,Fstartdate,Fenddate,Fperiods,pref);
end

%   conditional forecast for Mixed frequency model
% cond forecast for 
if VARtype==7 && CF==1
%     if exist('cfconds','var')   % Check if the conditional forecast is an empty matrix, need to be done better later (and add option for nonempty)
%         if isempty(cell2mat(cfconds))
%             YMC_orig = exp(99)*ones(size(cfconds));
%         end
%     end
    % converts the cell cfconds to a matrix with NaN values in the appropriate places (where cfconds is empty)
    YMC_orig = ones(size(cfconds))*exp(99);
    for ii = 1:size(cfconds,1)
        for ij = 1:size(cfconds,2)
            if ~isempty(cfconds{ii,ij})
                YMC_orig(ii,ij) = cfconds{ii,ij};
                if  mf_setup.select(1,ij)==0
                    cfconds{ii,ij} = log(cfconds{ii,ij});   % we need to transform to logs
                else
                    cfconds{ii,ij} = cfconds{ii,ij}/100;
                end
            end
        end
    end
    YMC_orig(:,mf_setup.select==0) = log(YMC_orig(:,mf_setup.select==0));
    YMC_orig(:,mf_setup.select==1) = YMC_orig(:,mf_setup.select==1)./100;
elseif VARtype == 7 && CF~=1
    YMC_orig=ones(Input.H,mf_setup.Nm+mf_setup.Nq)*exp(99);
end


%--------------------|
% Excel record phase |
%--------------------|

% record the estimation information
excelrecord1;

%-----------------------|
% date generation phase |
%-----------------------|

% generate the strings and decimal vectors of dates
[decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Beginning of rolling forecasting loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stringdatesforecast=stringdates2;
startdateini=startdate;
data_endo_full=data_endo;
if VARtype==2 && prior==61
    data_endo_a_full=data_endo_a;
    Dmatrix_full=Dmatrix; % Matrix for the regimes for the mean-adjusted BVARs
end
numt=1;% initialisation
Fstartdate_rolling={};%to keep track of iterations
if window_size>length(stringdates1)
    msgbox('Forecasting window size greater than sample size');
    error('Forecasting window size greater than sample size');
elseif window_size>0
    numt = length(stringdates1)-window_size+lags; % number of different dateroll dates
end

for iteration=1:numt % beginning of forecasting loop
    
    if window_size>0
        data_endo = data_endo_full(iteration:window_size+iteration,:);
        if VARtype==2 && prior==61
            Dmatrix = Dmatrix_full(iteration:window_size+iteration,:);
            data_endo_a = data_endo_a_full(iteration:window_size+iteration,:);
        end
        %if size(data_exo)>0 %need to fix
        %data_exo = data_exo_full(iteration:window_size+iteration,:);
        %end
        Fstartlocation1=find(strcmp(names(1:end,1),startdateini))+iteration-1;
        startdate=char(names(Fstartlocation1,1));
        Fendlocation=find(strcmp(names(1:end,1),startdateini))+window_size+iteration-1;
        enddate=char(names(Fendlocation,1));
        if F>0
            Fstartdate=char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+1,1));
            Fenddate=char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+hstep,1));
        end
        
        % if Fendlocation+hstep<=length(names)
        %       Fcperiods=hstep;
        %       % record the end date of the common periods
        %       Fcenddate=char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+hstep,1));
        %       % if the forecast period ends later than the data set, the common periods end at the end of the data set
        % else
        %       Fcperiods=Fendlocation-Fstartlocation+1;
        %       % record the end date of the common periods
        %       Fcenddate=names{end,1};
        % end
        
        % generate the different sets of data
        % if the model is the OLS VAR,
        if VARtype==1
            [names, data, data_endo, data_endo_a, data_endo_c, data_endo_c_lags, data_exo, data_exo_a, data_exo_p, data_exo_c, data_exo_c_lags, Fperiods, Fcomp, Fcperiods, Fcenddate,endo,n,favar]...
                =bear.gensampleols(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,favar,IRFt);
            % if the model is the Bayesian VAR, the mean-adjusted BVAR, the stochastic volatility BVAR, ot the time-varying BVAR:
        elseif VARtype==2 || VARtype==5 || VARtype==6
            [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4,n,favar]...
                =bear.gensample(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,ar,lambda4,PriorExcel,priorsexogenous,pref,favar,IRFt);
            % else, if the model is the panel BVAR
        elseif VARtype==4
            [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4]...
                =bear.gensamplepan(startdate,enddate,Units,panel,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,ar,0,0);
        end
        
        
        % generate the strings and decimal vectors of dates
        [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);
        
    end %window_size>0
    
    
    
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % MAIN CODE (NOT TO BE CHANGED)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Grand loop 1: OLS VAR model
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % if the selected model is an OLS/maximum likelihood  VAR, run this part
    if VARtype==1
        
        % model estimation
        [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
        % compute interval estimates
        [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.olsestimates(betahat,sigmahat,X,k,q,cband);
        % display the VAR results
        bear.olsvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,X,Y,n,m,p,k,q,T,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref,favar,strctident);
        % compute and display the steady state results
        bear.olsss(Y,X,n,m,p,Bhat,stringdates1,decimaldates1,endo,pref);
        
        % IRFt routines
        if IRFt==1||IRFt==2||IRFt==3
            [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]...
                =bear.olsirft123(betahat,sigmahat,IRFperiods,IRFt,Y,X,n,m,p,k,q,IRFband,IRF,favar);
        elseif IRFt==4 % set identified, %%%% adjust beta sigma hat estimates
            [irf_estimates,D_record,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_record,favar]...
                =bear.olsirft4(betahat,sigmahat,IRFperiods,Y,X,n,m,p,k,pref,IRFband,T,FEVDresperiods,strctident,favar,IRFt);
        elseif IRFt==5 %point identified %%%% adjust beta sigma hat estimates
            [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]...
                =bear.olsirft5(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,strctident,IRFt,IRF,favar);
        elseif IRFt==6 %combination of 4 and 5, nothing more %%%% adjust beta sigma hat estimates
            [irf_estimates,D_record,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_record,favar]...
                =bear.olsirft6(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,FEVDresperiods,favar,strctident,IRFt);
        end
        
        % Structual shocks
        if IRFt==2||IRFt==3||IRFt==5
            bear.strsdispols(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
        elseif IRFt==4||IRFt==6
            bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
        end
        
        % IRFs (if activated)
        if IRF==1
            % display IRFs
            bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
        end
        
        %compute IRFs for information variables, output in excel
        if favar.IRF.plot==1
            [favar]=bear.favar_irfols(irf_estimates,favar,const,Bhat,data_exo,n,m,k,lags,EPS,T,data_endo,IRFperiods,endo,IRFt,IRFband,strctident,pref);
        end
        
        
        % forecasts (if activated)
        if F==1
            [forecast_estimates]=bear.olsforecast(data_endo_a,data_exo_p,Fperiods,betahat,Bhat,sigmahat,n,m,p,k,const,Fband);
            bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
            % forecast evaluation (if activated)
            if Feval==1
                bear.olsfeval(data_endo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,n,forecast_estimates,names,endo,pref);
            end
        end
        
        
        % FEVD (if activated)
        if FEVD==1 || favar.FEVD.plot==1
            if IRFt==4&&size(strctident.signreslabels_shocks,1)~=n || IRFt==6&&size(strctident.signreslabels_shocks,1)~=n
                message='Model is not fully identified. FEVD results can be misleading.';
                msgbox(message,'FEVD warning','warn','warning');
            end
            % compute fevd estimates
            [fevd_estimates]=bear.olsfevd(irf_estimates,IRFperiods,gamma,n);
            %compute approximate favar fevd estimates
            if favar.FEVD.plot==1
                [favar]=bear.favar_olsfevd(IRFperiods,gamma,favar,n,IRFt,strctident);
            end
            % display the results
            bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
        end
        
        % historical decomposition (if activated)
        if HD==1 || favar.HD.plot==1
            % compute hd_record
            if IRFt==1||IRFt==2||IRFt==3||IRFt==5
                % compute hd_record, here we have the "true" values already
                [hd_estimates]=bear.hd_new_for_signres(const,exo,betahat,k,n,p,D,m,T,X,Y,data_exo,IRFt,[]);
            elseif IRFt==4||IRFt==6
                % compute hd_record
                [hd_record]=bear.hdecompols(const,exo,k,n,p,m,T,X,Y,data_exo,IRFt,beta_record,D_record,1001,0,endo,strctident);
                % and compute the point estimates
                [hd_estimates]=bear.HDestimatesols(hd_record,n,T,HDband,strctident);
            end
            
            % FAVAR: scale hd_estimates with loadings
            if favar.FAVAR==1
                if favar.HD.plot==1 && favar.pX==1
                    [favar,favar.HD.hd_estimates]=bear.favar_hdestimates(favar,hd_estimates,n,IRFt,endo,strctident,favar.L(favar.plotX_index,:));
                end
            end
            % finally display
            bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
        end
        
        % here finishes grand loop 1
        % if the model selected is not an OLS VAR, this part will not be run
    end
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Grand loop 2: BVAR model
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % this is the part of the code that will be run if the selected VAR model is a BVAR
    if VARtype==2
        
        %% BLOCK 1: OLS ESTIMATES
        
        % preliminary OLS VAR and univariate AR estimates
        if prior~=61
            [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
        elseif prior==61 % other preliminary steps for Mean-adjusted model (prior=61)
            [Y, X, Z, n, m, p, T, k1, k3, q1, q2, q3]=bear.TVEmaprelim(data_endo,data_exo,const,lags,regimeperiods,names);
            k=k1; %for some rountines
            q=q1+q2;
            %m=0;
        end
        [arvar]=bear.arloop(data_endo,const,p,n);
        
        
        
        %% BLOCK 2: PRIOR EXTENSIONS
        
        % if hyperparameter optimisation has been selected, run the grid search
        if hogs==1 && PriorExcel==0
            % grid for the Minnesota
            if prior==11||prior==12||prior==13
                [ar, lambda1, lambda2, lambda3, lambda4, lambda6, lambda7]=bear.mgridsearch(X,Y,y,n,m,p,k,q,T,lambda5,lambda6,lambda7,lambda8,grid,arvar,sigmahat,data_endo,data_exo,prior,priorexo,hogs,bex,blockexo,const,scoeff,iobs,pref,It,Bu,lrp,H);
                % grid for the normal- Wishart
            elseif prior==21||prior==22
                [ar, lambda1, lambda3, lambda4, lambda6, lambda7]=bear.nwgridsearch(X,Y,n,m,p,k,q,T,lambda2,lambda5,lambda6,lambda7,lambda8,grid,arvar,data_endo,data_exo,prior,priorexo,hogs,bex,const,scoeff,iobs,pref,It,Bu,lrp,H);
            end
            % update record of results on Excel
            excelrecord1
        end
        
        % implement any dummy observation extensions that may have been selected
        [Ystar,ystar,Xstar,Tstar,Ydum,ydum,Xdum,Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,lambda7,lambda8,scoeff,iobs,lrp,H);
        
        
        %% BLOCK 3: POSTERIOR DERIVATION
        
        % estimation of BVAR if a Minnesota prior has been chosen (i.e., prior has been set to 11,12 or 13)
        if prior==11||prior==12||prior==13
            % set prior values
            [beta0,omega0,sigma]=bear.mprior(ar,arvar,sigmahat,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k,q,prior,bex,blockexo,priorexo);
            % obtain posterior distribution parameters
            [betabar,omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
            % run Gibbs sampling for the Minnesota prior
            if favar.FAVAR==0
                [beta_gibbs,sigma_gibbs]=bear.mgibbs(It,Bu,betabar,omegabar,sigma,q);
            elseif favar.FAVAR==1
                [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_mgibbs(It,Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,m,p,k,prior,bex,blockexo,priorexo,Y,X,y);
            end
            % compute posterior estimates
            [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.mestimates(betabar,omegabar,sigma,q,cband);
            
            
            % estimation of BVAR if a normal-Wishart prior has been chosen (i.e., prior has been set to 21 or 22)
        elseif prior==21||prior==22
            if IRFt<=4
                % set prior values
                [B0,beta0,phi0,S0,alpha0]=bear.nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
                % obtain posterior distribution parameters
                [Bbar,betabar,phibar,Sbar,alphabar,alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
                % run Gibbs sampling for the normal-Wishart prior
                if favar.FAVAR==0
                    [beta_gibbs,sigma_gibbs]=bear.nwgibbs(It,Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);
                elseif favar.FAVAR==1
                    [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_nwgibbs(It,Bu,Bhat,EPS,n,m,p,k,T,q,lags,data_endo,ar,arvar,lambda1,lambda3,lambda4,prior,priorexo,const,data_exo,favar,Y,X);
                end
                % compute posterior estimates
                [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband);
            end
            
            
            % estimation of BVAR if an independent normal-Wishart prior has been chosen (i.e., prior has been set to 31 or 32)
        elseif prior==31||prior==32
            if IRFt<=4
                % set prior values
                [beta0,omega0,S0,alpha0]=bear.inwprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k,q,prior,bex,blockexo,priorexo);
                % run Gibbs sampling for the mixed prior
                if favar.FAVAR==0
                    [beta_gibbs,sigma_gibbs]=bear.inwgibbs(It,Bu,beta0,omega0,S0,alpha0,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
                elseif favar.FAVAR==1
                    [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_inwgibbs(It,Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,m,p,k,prior,bex,blockexo,priorexo,Y,X,y,endo);
                end
                % compute posterior estimates
                [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.inwestimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
            end
            
            
            % estimation of BVAR if a normal-diffuse prior has been chosen (i.e., prior has been set to 41 or 42)
        elseif prior==41
            if IRFt<=4
                % set prior values
                [beta0, omega0]=bear.ndprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k,q,bex,blockexo,priorexo);
                % run Gibbs sampling for the normal-diffuse prior
                if favar.FAVAR==0
                    if lambda1>999 % switch to flat prior in this case
                        [beta_gibbs,sigma_gibbs]=bear.ndgibbstotal(It,Bu,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
                    else
                        [beta_gibbs,sigma_gibbs]=bear.ndgibbs(It,Bu,beta0,omega0,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
                    end
                elseif favar.FAVAR==1
                    if lambda1>999 % switch to flat prior in this case
                        [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_ndgibbstotal(It,Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,X,Y,y,favar);
                    else
                        [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_ndgibbs(It,Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,m,p,k,bex,blockexo,priorexo,Y,X,y,endo);
                    end
                end
                % compute posterior estimates
                [beta_median, beta_std, beta_lbound, beta_ubound,sigma_median]=bear.ndestimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
            end
            
            % estimation of BVAR if a dummy observation prior has been chosen (i.e., prior has been set to 51, 52 or 53)
        elseif prior==51
            % set 'prior' values (here, the dummy observations)
            [Ystar,Xstar,Tstar]=bear.doprior(Ystar,Xstar,n,m,p,Tstar,ar,arvar,lambda1,lambda3,lambda4,priorexo);
            % obtain posterior distribution parameters
            [Bcap,betacap,Scap,alphacap,phicap,alphatop]=bear.dopost(Xstar,Ystar,Tstar,k,n);
            % run Gibbs sampling for the dummy observation prior
            if favar.FAVAR==0
                [beta_gibbs,sigma_gibbs]=bear.dogibbs(It,Bu,Bcap,phicap,Scap,alphacap,alphatop,n,k);
                % compute posterior estimates
                [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.doestimates(betacap,phicap,Scap,alphacap,alphatop,n,k,cband);
            elseif favar.FAVAR==1
                [beta_gibbs,sigma_gibbs,favar,It,Bu]=bear.favar_dogibbs(It,Bu,Bhat,EPS,n,T,lags,data_endo,data_exo,const,favar,ar,arvar,lambda1,lambda3,lambda4,m,p,k,priorexo,Y,X,cband,Tstar);
                % median of the posterior estimates in this case
                [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.favar_doestimates(favar);
            end
            
            
            % mean-adjusted BVAR model
        elseif prior==61
            % set prior distribution parameters for the model
            [beta0, omega0, psi0, lambda0,r] = bear.maprior(ar, arvar, lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k1,q1,q2,bex,blockexo,Fpconfint,Fpconfint2,chvar,regimeperiods,Dmatrix,equilibrium,data_endo,priorf);
            % Create H matrix
            [TVEH, TVEHfuture]=bear.TVEcreateH(equilibrium,r,T,p,Fperiods);
            % check the priors
            bear.checkpriors(psi0,lambda0,TVEH,decimaldates1,data_endo,Dmatrix);
            q2=length(psi0);
            % run Gibbs sampler for estimation
            [beta_gibbs, sigma_gibbs, theta_gibbs, ss_record,indH,beta_theta_gibbs]=bear.TVEmagibbs(data_endo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,n,T,k1,q1,p,regimeperiods,names,TVEH);
            %[beta_gibbs psi_gibbs sigma_gibbs delta_gibbs ss_record]=bear.magibbs(data_endo,data_exo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,Z,n,m,T,k1,k3,q1,q2,q3,p);
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, theta_median, theta_std, theta_lbound, theta_ubound, sigma_median]=bear.TVEmaestimates(beta_gibbs,theta_gibbs,sigma_gibbs,cband,q1,q2,n);
            %[beta_median beta_std beta_lbound beta_ubound psi_median psi_std psi_lbound psi_ubound sigma_median]=bear.maestimates(beta_gibbs,psi_gibbs,sigma_gibbs,cband,q1,q2,n);
        end
        
        % routines are different for IRFt 4, 5 & 6
        if IRFt==4
            if prior~=61
                % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
                [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                    =bear.irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);
            elseif prior==61
                [struct_irf_record,D_record,gamma_record,hd_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                    =bear.irfres_prior(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,HD,const,exo,strctident,pref,favar,IRFt,It,Bu,prior);
            end
            if prior~=61
                [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n);
            elseif prior==61
                [beta_median, beta_std, beta_lbound, beta_ubound, theta_median, theta_std, theta_lbound, theta_ubound, sigma_median]=bear.TVEmaestimates(beta_gibbs,theta_gibbs,sigma_gibbs,cband,q1,q2,n);
            end
        elseif IRFt==5 % If IRFs have been set to an SVAR with IV identification (IRFt=5):
            [struct_irf_record,D_record,gamma_record,ETA_record,It,Bu,beta_gibbs,sigma_gibbs]=...
                bear.IRFt5_Bayesian(names,betahat,m,n,Xstar,Ystar,k,p,enddate,startdate,IRFperiods,IRFt,T,arvar,q, It, Bu,lambda1, lambda3,lambda4,pref,strctident);
            [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
            % If IRFs have been set to an SVAR with IV identification & sign, rel. magnitude, FEVD, correlation restrictions (IRFt=6):
        elseif IRFt==6
            [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs]=...
                bear.IRFt6_Bayesian(betahat,IRFperiods,n,m,p,k,T,names,startdate,enddate,Xstar,FEVDresperiods,Ystar,pref,IRFt,arvar,q,It,Bu,lambda1,lambda3,lambda4,strctident,favar);
            [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
        end
        
        
        % FAVARs: we estimated the factors in data_endo (FY) It-Bu times, so compute a median estimate for X and Y
        if favar.FAVAR==1
            [X,Y,favar]=bear.favar_XYestimates(T,n,p,m,It,Bu,favar);
        end
        
        %% BLOCK 4: MODEL EVALUATION
        
        % compute the marginal likelihood for the model
        if prior==11||prior==12||prior==13
            [logml,log10ml,ml]=bear.mmlik(Xstar,Xdum,ystar,ydum,n,Tstar,Tdum,q,sigma,beta0,omega0,betabar,scoeff,iobs);
        elseif prior==21&&IRFt<=4 || prior==22&&IRFt<=4
            [logml,log10ml,ml]=bear.nwmlik(Xstar,Xdum,Ydum,n,Tstar,Tdum,k,B0,phi0,S0,alpha0,Sbar,alphabar,scoeff,iobs);
        elseif prior==31||prior==32
            [logml,log10ml,ml]=bear.inwmlik(Y,X,n,k,q,T,beta0,omega0,S0,alpha0,beta_median,sigma_median,beta_gibbs,It,Bu,scoeff,iobs);
        elseif prior==41||prior==51||prior==61||IRFt>4
            log10ml=nan;
        end
        
        %compute the DIC test
        if prior==11||prior==12||prior==13||prior==21||prior==22|| prior==31||prior==32||prior==41||prior==51||prior==61
            if IRFt<5
                [dic]=bear.dic_test(Y,X,n,beta_gibbs,sigma_gibbs,It-Bu,favar);
            else
                [dic]=0;
            end
        end
        
        if prior~=61
            % merged the disp files, but we need some to provide some extra variables in the case we do not have prior 61
            theta_median=NaN; TVEH=NaN; indH=NaN;
        end
        % display the VAR results
        bear.bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,dic,X,Y,n,m,p,k,q,T,prior,bex,hogs,lrp,H,ar,lambda1,lambda2,lambda3,lambda4,lambda5,lambda6,lambda7,lambda8,IRFt,const,beta_gibbs,endo,data_endo,exo,startdate,enddate,decimaldates1,stringdates1,pref,scoeff,iobs,PriorExcel,strctident,favar,theta_median,TVEH,indH);
        
        % compute and display the steady state results
        if prior~=61 %we have a ss_record output for the prior61
            [ss_record]=bear.ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu,favar);
        end
        [ss_estimates]=bear.ssestimates(ss_record,n,T,cband);
        % display steady state
        bear.ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref);
        
        
        %% BLOCK 5: IRFs
        % compute IRFs, HD and structural shocks
        if prior==61 %%%for the mean adjusted model set m to zero
            m=0;
        end
        
        % run the Gibbs sampler to obtain posterior draws
        if IRFt==1 || IRFt==2 || IRFt==3
            [irf_record]=bear.irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k);
        end
        
        % If IRFs have been set to an unrestricted VAR (IRFt=1):
        if IRFt==1
            % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
            [D_record, gamma_record]=bear.irfunres(n,It,Bu,sigma_gibbs);
            struct_irf_record=irf_record;
            % If IRFs have been set to an SVAR with Cholesky identification (IRFt=2):
        elseif IRFt==2
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.irfchol(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
            % If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
        elseif IRFt==3
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record,D_record,gamma_record,favar]=bear.irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
        end
        
        % If an SVAR was selected, also compute and display the structural shock series
        if IRFt==2||IRFt==3
            %%%%% I think we can merge both strshocks files
            if prior~=61
                % compute first the empirical posterior distribution of the structural shocks
                [strshocks_record]=bear.strshocks(beta_gibbs,D_record,Y,X,n,k,It,Bu,favar);
            elseif prior==61
                % compute first the empirical posterior distribution of the structural shocks
                [strshocks_record]=bear.TVEmastrshocks(beta_gibbs,theta_gibbs,D_record,n,k1,It,Bu,TVEH,indH,data_endo,p);
            end
            % compute posterior estimates
            [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
        elseif IRFt==4||IRFt==6||IRFt==5
            % compute posterior estimates
            [strshocks_estimates]=bear.strsestimates_set_identified(ETA_record,n,T,IRFband,struct_irf_record,IRFperiods,strctident);
        end
        % display the results
        if IRFt~=1
            bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
        end
        
        if IRF==1 || favar.IRF.plot==1
            % compute posterior estimates
            if IRFt==1 || IRFt==2 || IRFt==3
                [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
            elseif IRFt==4||IRFt==5||IRFt==6
                [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates_set_identified(struct_irf_record,n,IRFperiods,IRFband,D_record,strctident,favar);
            end
            
            if IRF==1
                % display the results
                bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
            end
            %display IRFs for information variables, output in excel
            if favar.IRF.plot==1
                [favar]=bear.favar_irfdisp(favar,IRFperiods,endo,IRFt,strctident,pref);
            end
        end
        
        % estimate IRFs for exogenous variables
        if isempty(data_exo)~=1 %%%%%&& m>0
            [exo_irf_record,exo_irf_estimates]=bear.irfexo(beta_gibbs,It,Bu,IRFperiods,IRFband,n,m,p,k,prior);
            % estimate IRFs for exogenous variables
            bear.irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref);
        end
        
        
        %% BLOCK 6: FORECASTS
        
        % compute forecasts if the option has been retained
        if F==1
            % run the Gibbs sampler to obtain draws form the posterior predictive distribution
            %%%%% I think we can merge both forecast files
            if prior~=61
                [forecast_record]=bear.forecast(data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const,Fstartlocation,favar);
            elseif prior==61
                [forecast_record]=bear.TVEmaforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,m,p,k1,k3,theta_gibbs,TVEHfuture,ss_record,indH);   %[forecast_record]=maforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,delta_gibbs,Fperiods,n,m,p,k1,k3);
            end
            
            % compute posterior estimates
            [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
            % display the results for the forecasts
            bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
            % finally, compute forecast evaluation if the option was selected
            if Feval==1
                %OLS single variable with BIC lag selection VAR for Rossi test
                [OLS_Bhat, OLS_betahat, OLS_sigmahat, OLS_forecast_estimates, biclag]=bear.arbicloop(data_endo,data_endo_a,const,p,n,m,Fperiods,Fband);
                %%%%% I think we can merge both forecast files
                if prior~=61
                    [Forecasteval]=bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
                elseif prior==61
                    [Forecasteval]=bear.TVEmafeval(data_endo_a,data_endo_c,data_endo_c_lags,data_exo_c,data_exo_c_lags,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,m,p,k1,k3,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref,theta_gibbs,TVEHfuture,ss_record,indH);
                end
            end
        end
        
        
        %% BLOCK 7: FEVD
        
        % compute FEVD if the option has been retained
        if FEVD==1 || favar.FEVD.plot==1
            % warning if the model is not fully identified as the results can be misleading
            if (IRFt==4 && size(strctident.signreslabels_shocks,1)~=n) || (IRFt==6 && size(strctident.signreslabels_shocks,1)~=n) || IRFt==5
                message='Model is not fully identified. FEVD results can be misleading.';
                msgbox(message,'FEVD warning','warn','warning');
            end
            
            % run the Gibbs sampler to compute posterior draws
            [fevd_estimates]=bear.fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
            % compute approximate favar fevd estimates
            if favar.FEVD.plot==1
                [favar]=bear.favar_fevd(gamma_record,It,Bu,n,IRFperiods,FEVDband,favar,IRFt,strctident);
            end
            % display the results
            bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
        end
        
        
        
        %% BLOCK 8: historical decomposition
        % compute historical decomposition if the option has been retained
        if HD==1 || favar.HD.plot==1
            if prior==61 % again, special case
                [strshocks_record]=bear.TVEmastrshocks(beta_gibbs,theta_gibbs,D_record,n,k1,It,Bu,TVEH,indH,data_endo,p);
                % run the Gibbs sampler to compute posterior draws
                [hd_record]=bear.TVEmahdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Y,n,p,k1,T); %ETA_record
                % compute posterior estimates
                [hd_estimates]=bear.hdestimates(hd_record,n,T,HDband);
                % display the results
                bear.hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels);
                
            else
                
                % run the Gibbs sampler to compute posterior draws
                [hd_record,favar]=bear.hdecomp_inc_exo(beta_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar);
                % compute posterior estimates
                if IRFt==1||IRFt==2||IRFt==3||IRFt==5
                    [hd_estimates,favar]=bear.hdestimates_inc_exo(hd_record,n,T,HDband,favar); % output is here named hd_record fit the naming conventions of HDestdisp
                elseif IRFt==4||IRFt==6
                    [hd_estimates,favar]=bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
                end
                % display the HDs
                bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
                %[favar]=HDdisp(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
            end
        end
        
        
        
        %% BLOCK 9: conditional forecasts
        
        % compute conditional forecasts if the option has been retained
        if CF==1
            % if the type of conditional forecasts corresponds to the standard methodology
            if CFt==1||CFt==2
                %%%%% I think both cforecast files can be merged
                if prior~=61
                    % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
                    [cforecast_record,CFstrshocks_record]=bear.cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
                elseif prior==61
                    [cforecast_record]=bear.TVEmacforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,n,m,p,k1,k3,beta_gibbs,D_record,gamma_record,theta_gibbs,TVEHfuture,ss_record,indH);
                end
                % if the type of conditional forecasts corresponds to the tilting methodology
            elseif CFt==3||CFt==4
                [cforecast_record]=bear.tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,It,Bu);
            end
            
            % compute posterior estimates
            [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
            %[CFstrshocks_estimates]=bear.strsestimates(CFstrshocks_record,n,Fperiods,Fband); % structural shocks of the conditional forecast
            
            % display the results for the forecasts
            bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
        end
        
        % option to save matlab workspace
        if pref.workspace==1
            if numt>1
                save(fullfile(pref.results_path, [ pref.results_sub Fstartdate '.mat'] )); % Save Workspace
            end
        end
        
        Fstartdate_rolling=[Fstartdate_rolling; Fstartdate];
        
        % here finishes grand loop 2
        % if the model selected is not a BVAR, this part will not be run
    end
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Grand loop 4: panel VAR model
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if the selected model is a panel VAR, run this part
    if VARtype==4
        
        %% BLOCK 1: MODEL ESTIMATION
        
        % if the model is the OLS mean group estimator
        if panel==1
            % compute preliminary elements
            [X, Y, N, n, m, p, T, k, q]=bear.panel1prelim(data_endo,data_exo,const,lags);
            % obtain the estimates for the model
            [bhat, sigmahatb, sigmahat]=bear.panel1estimates(X,Y,N,n,q,k,T);
            % plot a first set of results
            bear.panel1plot(endo,Units,X,Y,N,n,m,p,k,T,bhat,decimaldates1,stringdates1,pref);
            
            % else, if the model is the Bayesian pooled estimator
        elseif panel==2
            % compute preliminary elements
            [X, Xmat, Y, Ymat, N, n, m, p, T, k, q]=bear.panel2prelim(data_endo,data_exo,const,lags,Units);
            % obtain prior elements (from a standard normal-Wishart)
            [B0, beta0, phi0, S0, alpha0]=bear.panel2prior(N,n,m,p,T,k,q,data_endo,ar,lambda1,lambda3,lambda4,priorexo);
            % obtain posterior distribution parameters
            [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,N*T,k);
            % run the Gibbs sampler
            [beta_gibbs, sigma_gibbs]=bear.nwgibbs(It,Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);
            % compute posterior estimates
            [beta_median, B_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband);
            % plot a first set of results
            bear.panel2plot(endo,Units,Xmat,Ymat,N,n,m,p,k,T,beta_median,beta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,favar);
            
            % else, if the model is the random effect model (Zellner and Hong)
        elseif panel==3
            % compute preliminary elements
            [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel3prelim(data_endo,data_exo,const,lags);
            % obtain prior elements
            [b, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);
            % compute posterior distribution parameters
            [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);
            % run the Gibbs sampler
            [beta_gibbs, sigma_gibbs]=bear.panel3gibbs(It,Bu,betabar,omegabarb,sigeps,h,N,n,q);
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.panel3estimates(N,n,q,betabar,omegabarb,sigeps,cband);
            % plot a first set of results
            bear.panel3plot(endo,Units,Xi,Yi,N,n,m,p,k,T,beta_median,beta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,favar);
            
            % else, if the model is the random effect model (hierarchical)
        elseif panel==4
            % compute preliminary elements
            [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel4prelim(data_endo,data_exo,const,lags);
            % obtain prior elements
            [omegab]=bear.panel4prior(N,n,m,p,T,k,data_endo,q,lambda3,lambda2,lambda4);
            % run the Gibbs sampler
            [beta_gibbs,sigma_gibbs]=bear.panel4gibbs(N,n,h,T,k,q,Yi,Xi,s0,omegab,v0,It,Bu,pick,pickf);
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.panel4estimates(N,n,q,beta_gibbs,sigma_gibbs,cband,[],[]); % beta_mean,sigma_mean
            % plot a first set of results
            bear.panel4plot(endo,Units,Xi,Yi,N,n,m,p,k,T,beta_median,beta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,favar);
            
            % else, if the model is the factor model (static)
        elseif panel==5
            % compute preliminary elements
            [Ymat, Xmat, N, n, m, p, T, k, q, h]=bear.panel5prelim(data_endo,data_exo,const,lags);
            % obtain prior elements
            [d1, d2, d3, d4, d5, d, Xi1, Xi2, Xi3, Xi4, Xi5, Xi, Y, y, Xtilde, Xdot, theta0, Theta0]=bear.panel5prior(N,n,p,m,k,q,h,T,Ymat,Xmat);
            % run the Gibbs sampler
            [theta_gibbs,sigma_gibbs,sigmatilde_gibbs,sig_gibbs]=bear.panel5gibbs(y,Y,Xtilde,Xdot,N,n,T,d,theta0,Theta0,alpha0,delta0,It,Bu,pick,pickf);
            % compute posterior estimates
            [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median]=bear.panel5estimates(d,N,n,theta_gibbs,sigma_gibbs,cband);
            % plot a first set of results
            bear.panel5plot(endo,Units,Xmat,Xdot,Ymat,N,n,m,p,k,T,theta_median,theta_gibbs,Xi,It,Bu,decimaldates1,stringdates1,pref,cband)
            
            
            % else, if the model is the factor model (dynamic)
        elseif panel==6
            % compute preliminary elements
            [Ymat,Xmat,N,n,m,p,T,k,q,h]=bear.panel6prelim(data_endo,data_exo,const,lags);
            % obtain prior elements
            [d1,d2,d3,d4,d5,d,Xi1,Xi2,Xi3,Xi4,Xi5,Xi,y,Xtilde,thetabar,theta0,H,Thetatilde,Theta0,G]=bear.panel6prior(N,n,p,m,k,q,h,T,Ymat,Xmat,rho,gama);
            % run the Gibbs sampler
            [theta_gibbs,sigmatilde_gibbs,Zeta_gibbs,sigma_gibbs,phi_gibbs,B_gibbs,acceptrate]=bear.panel6gibbs(y,Xtilde,N,n,T,theta0,Theta0,thetabar,alpha0,delta0,a0,b0,psi,d1,d2,d3,d4,d5,d,It,Bu,H,G,pick,pickf,gama);
            % compute posterior estimates
            [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median]=bear.panel6estimates(d,N,n,T,theta_gibbs,sigma_gibbs,cband);
            % plot a first set of results
            bear.panel6plot(endo,Units,Xmat,Xtilde,Ymat,N,n,m,p,k,T,d,theta_median,theta_gibbs,Xi,Zeta_gibbs,It,Bu,decimaldates1,stringdates1,pref,cband,d1,d2,d3,d4,d5);
        end
        
        
        %% BLOCK 2: IRFS
        
        % impulse response functions (if activated)
        if IRF==1
            
            % if the model is the OLS mean group estimator
            if panel==1
                % estimate the IRFs
                [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates]=bear.panel1irf(Y,X,N,n,m,p,k,q,IRFt,bhat,sigmahatb,sigmahat,IRFperiods,IRFband);
                % display the results
                bear.panel1irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
                
                % else, if the model is the Bayesian pooled estimator
            elseif panel==2
                if IRFt==1 || IRFt==2 || IRFt==3
                    signrestable=[];
                    signresperiods=[];
                end
                % estimate the IRFs
                [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
                    bear.panel2irf(Ymat,Xmat,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,Y,X,signreslabels,[],data_exo,const,exo,IRFt,strctident,favar,signrestable,signresperiods);
                % display the results
                bear.panel2irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
                
                % else, if the model is the random effect model (Zellner and Hong)
            elseif panel==3
                if IRFt==1 || IRFt==2 || IRFt==3
                    signrestable=[];
                    signresperiods=[];
                end
                % estimate the IRFs
                [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
                    bear.panel3irf(Yi,Xi,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,signrestable,signresperiods,favar);
                % display the results
                bear.panel3irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
                
                % else, if the model is the random effect model (hierarchical)
            elseif panel==4
                if IRFt==1 || IRFt==2 || IRFt==3
                    signrestable=[];
                    signresperiods=[];
                end
                % estimate the IRFs
                [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
                    bear.panel4irf(Yi,Xi,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,signrestable,signresperiods,0,[],[],favar);
                % display the results
                bear.panel4irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
                
                % else, if the model is the factor model (static)
            elseif panel==5
                % estimate the IRFs
                [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
                    bear.panel5irf(Y,Xdot,theta_gibbs,sigma_gibbs,Xi,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,favar);
                % display the results
                bear.panel5irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
                
                % else, if the model is the factor model (dynamic)
            elseif panel==6
                % estimate the IRFs
                [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
                    bear.panel6irf(y,Xtilde,theta_gibbs,sigma_gibbs,B_gibbs,Xi,It,Bu,IRFperiods,IRFband,IRFt,rho,thetabar,N,n,m,p,T,d,favar);
                % display the results
                bear.panel6irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
            end
        end
        
        
        
        
        %% BLOCK 3: FORECASTS
        
        % forecasts (if activated)
        if F==1
            
            % if the model is the OLS mean group estimator
            if panel==1
                % estimate the forecasts
                [forecast_estimates]=bear.panel1forecast(sigmahat,bhat,k,n,const,data_exo_p,Fperiods,N,data_endo_a,p,T,m,Fband);
                % display the results
                bear.panel1fdisp(N,n,T,Units,endo,Y,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
                
                % else, if the model is the Bayesian pooled estimator
            elseif panel==2
                % estimate the forecasts
                [forecast_record, forecast_estimates]=...
                    bear.panel2forecast(N,n,p,k,data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,const,Fband,Fstartlocation,favar);
                % display the results
                bear.panel2fdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
                
                % else, if the model is the random effect model (Zellner and Hong)
            elseif panel==3
                % estimate the forecasts
                [forecast_record, forecast_estimates]=...
                    bear.panel3forecast(N,n,p,k,data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,const,Fband,Fstartlocation,favar);
                % display the results
                bear.panel3fdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
                
                % else, if the model is the random effect model (hierarchical)
            elseif panel==4
                % estimate the forecasts
                [forecast_record, forecast_estimates]=...
                    bear.panel4forecast(N,n,p,k,data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,const,Fband,Fstartlocation,favar);
                % display the results
                bear.panel4fdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
                
                % else, if the model is the factor model (static)
            elseif panel==5
                % estimate the forecasts
                [forecast_record, forecast_estimates]=...
                    bear.panel5forecast(N,n,p,data_endo_a,data_exo_p,It,Bu,theta_gibbs,sigma_gibbs,Xi,Fperiods,const,Fband);
                % display the results
                bear.panel5fdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
                
                % else, if the model is the factor model (dynamic)
            elseif panel==6
                % estimate the forecasts
                [forecast_record, forecast_estimates]=...
                    bear.panel6forecast(const,data_exo_p,Fstartlocation,It,Bu,data_endo_a,p,B_gibbs,sigmatilde_gibbs,N,n,phi_gibbs,theta_gibbs,Zeta_gibbs,Fperiods,d,rho,thetabar,gama,Xi,Fband);
                % display the results
                bear.panel6fdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref)
            end
            
        end
        
        
        
        %% BLOCK 4: FEVD
        
        % FEVD (if activated)
        if FEVD==1
            
            % if the model is the OLS mean group estimator
            if panel==1
                % estimate FEVD and display the results
                [fevd_estimates]=bear.panel1fevd(N,n,irf_estimates,IRFperiods,gamma,Units,endo,pref);
                
                % else, if the model is the Bayesian pooled estimator
            elseif panel==2
                % estimate the FEVD
                [fevd_record, fevd_estimates]=bear.panel2fevd(struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband);
                % display the results
                bear.panel2fevddisp(n,endo,fevd_estimates,IRFperiods,pref);
                
                % else, if the model is the random effect model (Zellner and Hong)
            elseif panel==3
                % estimate the FEVD
                [fevd_record, fevd_estimates]=bear.panel3fevd(N,struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband);
                % display the results
                bear.panel3fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
                
                % else, if the model is the random effect model (hierarchical)
            elseif panel==4
                % estimate the FEVD
                [fevd_record, fevd_estimates]=bear.panel4fevd(N,struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband);
                % display the results
                bear.panel4fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
                
                % else, if the model is the factor model (static)
            elseif panel==5
                % estimate the FEVD
                [fevd_record, fevd_estimates]=bear.panel5fevd(N,n,struct_irf_record,gamma_record,It,Bu,IRFperiods,FEVDband);
                % display the results
                bear.panel5fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
                
                % else, if the model is the factor model (dynamic)
            elseif panel==6
                % estimate the FEVD
                [fevd_record, fevd_estimates]=bear.panel6fevd(N,n,T,struct_irf_record,gamma_record,It,Bu,IRFperiods,FEVDband);
                % display the results
                bear.panel6fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
            end
            
        end
        
        
        
        
        %% BLOCK 5: HISTORICAL DECOMPOSITION
        
        % historical decomposition (if activated)
        if HD==1
            
            % if the model is the OLS mean group estimator
            if panel==1
                % estimate historical decomposition and display the results
                [hd_estimates]=bear.panel1hd(Y,X,N,n,m,p,T,k,D,bhat,endo,Units,decimaldates1,stringdates1,pref);
                
                % else, if the model is the Bayesian pooled estimator
            elseif panel==2
                % estimate historical decomposition
                [hd_record, hd_estimates]=bear.panel2hd(beta_gibbs,D_record,strshocks_record,It,Bu,Ymat,Xmat,N,n,m,p,k,T,HDband);
                % display the results
                bear.panel2hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
                
                % else, if the model is the random effect model (Zellner and Hong)
            elseif panel==3
                % estimate historical decomposition
                [hd_record, hd_estimates]=bear.panel3hd(beta_gibbs,D_record,strshocks_record,It,Bu,Yi,Xi,N,n,m,p,k,T,HDband);
                % display the results
                bear.panel3hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
                
                % else, if the model is the random effect model (hierarchical)
            elseif panel==4
                % estimate historical decomposition
                [hd_record, hd_estimates]=bear.panel4hd(beta_gibbs,D_record,strshocks_record,It,Bu,Yi,Xi,N,n,m,p,k,T,HDband);
                % display the results
                bear.panel4hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
                
                % else, if the model is the factor model (static)
            elseif panel==5
                % estimate historical decomposition
                [hd_record, hd_estimates]=bear.panel5hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,Xmat,N,n,m,p,k,T,HDband);
                % display the results
                bear.panel5hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
                
                % else, if the model is the factor model (dynamic)
            elseif panel==6
                % estimate historical decomposition
                [hd_record, hd_estimates]=bear.panel6hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,N,n,m,p,k,T,d,HDband);
                % display the results
                bear.panel6hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
            end
            
        end
        
        
        
        %% BLOCK 6: CONDITIONAL FORECASTS
        
        % conditional forecast (if activated)
        if CF==1
            
            % if the model is the Bayesian pooled estimator
            if panel==2
                % estimate conditional forecasts
                [nconds, cforecast_record, cforecast_estimates]=...
                    bear.panel2cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband);
                % display the results
                bear.panel2cfdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref,nconds);
                
                % else, if the model is the random effect model (Zellner and Hong)
            elseif panel==3
                % estimate conditional forecasts
                [nconds, cforecast_record, cforecast_estimates]=...
                    bear.panel3cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband);
                % display the results
                bear.panel3cfdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref,nconds);
                
                % else, if the model is the random effect model (hierarchical)
            elseif panel==4
                % estimate conditional forecasts
                [nconds, cforecast_record, cforecast_estimates]=...
                    bear.panel4cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband);
                % display the results
                bear.panel4cfdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref,nconds);
                
                % else, if the model is the factor model (static)
            elseif panel==5
                % estimate conditional forecasts
                [cforecast_record, cforecast_estimates]=...
                    bear.panel5cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,Xi,theta_gibbs,D_record,gamma_record,CFt,Fband);
                % display the results
                bear.panel5cfdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
                
                % else, if the model is the factor model (dynamic)
            elseif panel==6
                % estimate conditional forecasts
                [cforecast_record, cforecast_estimates]=...
                    bear.panel6cf(N,n,m,p,k,d,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,Xi,data_exo_p,theta_gibbs,B_gibbs,phi_gibbs,Zeta_gibbs,sigmatilde_gibbs,Fstartlocation,Ymat,rho,thetabar,gama,CFt,Fband);
                % display the results
                bear.panel6cfdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
            end
            
        end
        
        
        
        
        
        
        %% BLOCK 7: DISPLAY OF THE RESULTS
        
        
        % if the model is the OLS mean group estimator
        if panel==1
            bear.panel1disp(X,Y,n,N,m,p,T,k,q,const,bhat,sigmahat,sigmahatb,Units,endo,exo,gamma_estimates,D_estimates,startdate,...
                enddate,Fstartdate,Fcenddate,Fcperiods,Feval,Fcomp,data_endo_c,forecast_estimates,stringdates3,cband,pref,IRF,IRFt,names);
            
            % else, if the model is the Bayesian pooled estimator
        elseif panel==2
            bear.panel2disp(n,N,m,p,k,T,Ymat,Xmat,Units,endo,exo,const,beta_gibbs,B_median,beta_median,beta_std,beta_lbound,beta_ubound,sigma_gibbs,...
                sigma_median,D_estimates,gamma_estimates,ar,lambda1,lambda3,lambda4,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,...
                stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names,0);
            
            % else, if the model is the random effect model (Zellner and Hong)
        elseif panel==3
            bear.panel3disp(n,N,m,p,k,T,Yi,Xi,Units,endo,exo,const,beta_gibbs,beta_median,beta_std,beta_lbound,beta_ubound,sigma_gibbs,...
                sigma_median,D_estimates,gamma_estimates,lambda1,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,stringdates3,...
                Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names);
            
            % else, if the model is the random effect model (hierarchical)
        elseif panel==4
            bear.panel4disp(n,N,m,p,k,T,Yi,Xi,Units,endo,exo,const,beta_gibbs,beta_median,beta_std,beta_lbound,beta_ubound,sigma_gibbs,...
                sigma_median,D_estimates,gamma_estimates,lambda2,lambda3,lambda4,s0,v0,startdate,enddate,forecast_record,forecast_estimates,...
                Fcperiods,stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names);
            
            % else, if the model is the factor model (static)
        elseif panel==5
            bear.panel5disp(n,N,m,p,k,T,d1,d2,d3,d4,d5,Ymat,Xdot,Units,endo,exo,const,Xi,theta_gibbs,theta_median,theta_std,theta_lbound,theta_ubound,sigma_gibbs,...
                sigma_median,D_estimates,gamma_estimates,alpha0,delta0,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,...
                stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names);
            
            % else, if the model is the factor model (dynamic)
        elseif panel==6
            bear.panel6disp(n,N,m,p,k,T,d1,d2,d3,d4,d5,d,Ymat,Xtilde,Units,endo,exo,const,Xi,theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,...
                D_estimates,gamma_estimates,alpha0,delta0,gama,a0,b0,rho,psi,acceptrate,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,...
                stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,IRF,IRFt,pref,names);
            
        end
        
    end
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Grand loop 5: Stochastic volatility BVAR model
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % if the selected model is the stochastic volatility BVAR, run this part
    if VARtype==5
        
        
        
        %% BLOCK 1: OLS ESTIMATES AND PRELIMINARY ELEMENTS
        if stvol==4
            const=0; %set const to 0 if the model is a local mean model
        end
        % preliminary OLS VAR and univariate AR estimates
        [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
        [arvar]=bear.arloop(data_endo,const,p,n);
        [yt, Xt, Xbart]=bear.stvoltmat(Y,X,n,T);
        
        
        
        %% BLOCK 2: POSTERIOR DERIVATION
        
        % if the model is the standard model
        if stvol==1
            % obtain prior elements
            [beta0, omega0, G, I_o, omega, f0, upsilon0]=bear.stvol1prior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,T,k,q,bex,blockexo,gamma,priorexo);
            % run the Gibbs sampling algorithm to recover the posterior distributions
            if favar.FAVAR==0
                [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, sbar]=...
                    bear.stvol1gibbs(Xbart,yt,beta0,omega0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,q,It,Bu,pick,pickf);
            elseif favar.FAVAR==1
                [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs,sbar,favar,It,Bu]=...
                    bear.favar_stvol1gibbs(Xbart,yt,beta0,omega0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,q,It,Bu,pick,pickf,favar,data_endo,lags);
            end
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound]=bear.stvol1estimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T,cband);
            
            
            % if the model is the random inertia model
        elseif stvol==2
            % obtain prior elements
            [beta0, omega0, I_o, omega, f0, upsilon0]=bear.stvol2prior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,T,k,q,bex,blockexo,priorexo);
            % run the Gibbs sampling algorithm to recover the posterior distributions
            if favar.FAVAR==0
                [beta_gibbs, F_gibbs, gamma_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, sbar]=...
                    bear.stvol2gibbs(Xbart,yt,beta0,omega0,alpha0,delta0,gamma0,zeta0,f0,upsilon0,betahat,sigmahat,I_o,omega,T,n,q,It,Bu,pick,pickf);
            elseif favar.FAVAR==1
                [beta_gibbs, F_gibbs, gamma_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs,sbar,favar,It,Bu]=...
                    bear.favar_stvol2gibbs(Xbart,yt,beta0,omega0,alpha0,delta0,gamma0,zeta0,f0,upsilon0,betahat,sigmahat,I_o,omega,T,n,q,It,Bu,pick,pickf,favar,data_endo,lags);
            end
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound, gamma_median]=...
                bear.stvol2estimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,gamma_gibbs,n,T,cband);
            
            
            % if the model is the stochastic volatility model for large BVARs
        elseif stvol==3
            % obtain prior elements
            [B0, phi0, G, I_o, omega, f0, upsilon0]=bear.stvol3prior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,T,k,q,gamma,priorexo);
            % run the Gibbs sampling algorithm to recover the posterior distributions
            if favar.FAVAR==0
                [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, sbar]=...
                    bear.stvol3gibbs(Xbart,Xt,yt,B0,phi0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,k,It,Bu,pick,pickf);
            elseif favar.FAVAR==1
                [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs,sbar,favar,It,Bu]=...
                    bear.favar_stvol3gibbs(Xbart,Xt,yt,B0,phi0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,k,It,Bu,pick,pickf,favar,data_endo,lags);
            end
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound]=...
                bear.stvol3estimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T,cband);
            
            % if the Survey Local Mean VAR with stochastic volatility
        elseif stvol==4
            % load Survey local mean data
            [dataSLM,datesSLM,namesSLM]=bear.loadSLM(names,data_endo,lags,pref);
            % set priors and preliminaries for local mean model
            [Ys, Yt, YincLags, data_post_training, const, priorValues, dataValues, sizetraining]=...
                bear.TVESLM_prior(data_endo, data_exo, names, endo, lags, lambda1, lambda2, lambda3, lambda5, ar, bex, dataSLM, namesSLM, datesSLM, const, priorexo, gamma);
            % preliminary OLS VAR to get some important quantities
            [Bhat, ~, ~, ~, ~, ~, ~, ~, ~, n, ~, p, T, k, q]=bear.olsvar(data_post_training,data_exo,const,lags);
            % run Gibbs sampler for estimation
            [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, phi_G_gibbs, phi_V_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, Psi_gibbs, V_gibbs]=...
                bear.TVESLM_gibbs(priorValues, dataValues, It, Bu, Ys, Yt, YincLags, p, Bhat,q,k,pickf);
            % compute posterior estimates (Psi as the local mean and Ycycle(p+1:end,:) as the cyclical component)
            [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound, Psi_median, Psi_lbound, Psi_ubound, Ycycle_median, Ycycle_lbound, Ycycle_ubound, sbar, L_median]=...
                bear.TVESLMestimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T+p,cband, Psi_gibbs, YincLags,p, L_gibbs);
            % Estimate OLS var on the median cyclical component to get matrices X, Y
            % for the VAR on the cyclical component
            [Bhatcycle, betahatcycle, sigmahatcycle, Xcycle, Xbar, Ycycle, y, EPScycle, epscycle, n, m, p, T, k, q]=bear.olsvar(Ycycle_median,data_exo,0,lags);
            % plot and print
            bear.TVESLMdisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,sigma_t_median,sigma_t_lbound,sigma_t_ubound,Xcycle,Ycycle,n,m,p,k,T,bex,ar,lambda1,lambda2,lambda3,lambda4,lambda5,1,IRFt,0,endo,exo,startdate,enddate,stringdates1(sizetraining+1:end,1),decimaldates1(sizetraining+1:end,1),pref, YincLags(p+1:end,:), Psi_median, Psi_lbound, Psi_ubound, sizetraining,PriorExcel)
        end
        
        
        
        %% BLOCK 3: MODEL EVALUATION
        if stvol~=4
            % display the VAR results
            bear.stvoldisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,sigma_t_median,sigma_t_lbound,sigma_t_ubound,gamma_median,X,Y,n,m,p,k,T,stvol,bex,ar,lambda1,lambda2,lambda3,lambda4,lambda5,gamma,alpha0,delta0,gamma0,zeta0,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref,PriorExcel);
            
            % compute and display the steady state results
            [ss_record]=bear.ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu,favar);
            [ss_estimates]=bear.ssestimates(ss_record,n,T,cband);
            bear.ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref);
        end
        
        
        %% BLOCK 4: IRFs
        
        % run the Gibbs sampler to obtain posterior draws
        [irf_record]=bear.irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k);
        
        % If IRFs have been set to an unrestricted VAR (IRFt=1):
        if IRFt==1
            % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
            [D_record, gamma_record]=bear.irfunres(n,It,Bu,sigma_gibbs);
            
            % If IRFs have been set to an SVAR with Choleski identification (IRFt=2):
        elseif IRFt==2
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.irfcholstvol(F_gibbs,sbar,irf_record,It,Bu,IRFperiods,n,favar);
            
            % If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
        elseif IRFt==3
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.irftrigstvol(F_gibbs,sbar,irf_record,It,Bu,IRFperiods,n,favar);
            
            % If IRFs have been set to an SVAR with sign restrictions (IRFt=4):
        elseif IRFt==4
            if stvol==4
                [struct_irf_record,D_record,gamma_record,hd_record,ETA_record]...
                    =bear.irfres_stvol4(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,HD,0,exo,strctident,pref,favar,IRFt,It,Bu,YincLags, Psi_gibbs, sizetraining);
            else
                % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
%                [struct_irf_record,D_record,gamma_record,hd_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                    =bear.irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);
                %    [struct_irf_record, D_record, gamma_record,hd_record,ETA_record]=bear.irfres(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods);
            end
        end
        
        if IRF==1 || favar.IRF.plot==1
            % compute posterior estimates
            if IRFt==1 || IRFt==2 || IRFt==3
                [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
            elseif IRFt==4||IRFt==5||IRFt==6
                [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates_set_identified(struct_irf_record,n,IRFperiods,IRFband,D_record,strctident,favar);
            end
            
            if IRF==1
                % display the results
                bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
            end
            %display IRFs for information variables, output in excel
            if favar.IRF.plot==1
                [favar]=bear.favar_irfdisp(favar,IRFperiods,endo,IRFt,strctident,pref);
            end
        end
        
        
        % If an SVAR was selected, also compute the structural shock series
        if stvol == 4
            if IRFt==2|| IRFt==3
                % compute first the empirical posterior distribution of the structural shocks
                [strshocks_record]=bear.strshocks_stvolt4(beta_gibbs,D_record,YincLags,n,k,It,Bu, Psi_gibbs,p );
                % compute posterior estimates
                [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
                bear.strsdisp(decimaldates1(sizetraining+1:end,1),stringdates1(sizetraining+1:end,1),strshocks_estimates,endo,pref,IRFt,strctident);
            elseif IRFt==4
                [strshocks_estimates]=bear.strsestimates(ETA_record,n,T,IRFband);
                % display the results
                bear.strsdisp(decimaldates1(sizetraining+1:end,1),stringdates1(sizetraining+1:end,1),strshocks_estimates,endo,pref,IRFt,strctident);
            end
        else
            if IRFt==2||IRFt==3
                % compute first the empirical posterior distribution of the structural shocks
                [strshocks_record]=bear.strshocks(beta_gibbs,D_record,Y,X,n,k,It,Bu,favar);
                % compute posterior estimates
                [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
                % display the results
                bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
            elseif IRFt==4
                [strshocks_estimates]=bear.strsestimates(ETA_record,n,T,IRFband);
                % display the results
                bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
            end
        end
        
        
        %% BLOCK 5: FORECASTS
        % compute forecasts if the option has been retained
        if F==1
            % run the Gibbs sampler to obtain draws from the posterior predictive distribution
            % if the model is the standard model
            if stvol==1
                [forecast_record]=bear.forecaststvol1(data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma,sbar,Fstartlocation,Fperiods,n,p,k,const);
                % if the model is the random inertia model
            elseif stvol==2
                [forecast_record]=bear.forecaststvol2(data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma_gibbs,sbar,Fstartlocation,Fperiods,n,p,k,const);
                % if the model is the large BVAR model
            elseif stvol==3
                [forecast_record]=bear.forecaststvol3(data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma,sbar,Fstartlocation,Fperiods,n,p,k,const);
            elseif stvol==4
                [forecast_record]=bear.forecaststvol4(dataValues, data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,phi_V_gibbs,V_gibbs, Psi_gibbs, L_gibbs,gamma,Fstartlocation,Fperiods,n,p,k,sizetraining, Fendsmpl);
            end
            % compute posterior estimates
            [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
            % display the results for the forecasts
            if stvol==1 || stvol==2 || stvol==3
                bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
            elseif stvol==4
                bear.fdisp(YincLags,n,T+2*p,endo,stringdates2(sizetraining-2*p+1:end), decimaldates2(sizetraining-2*p+1:end),Fstartlocation-sizetraining+2*p,Fendlocation-sizetraining+2*p,forecast_estimates,pref);
                % finally, compute forecast evaluation if the option was selected
                if Feval==1
                    if stvol==4
                        [Forecasteval]=bear.bvarfeval_stvol4(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref, dataValues, Psi_gibbs,sizetraining,data_exo_p, Fstartlocation,Fperiods, data_endo_a);
                    else
                        [Forecasteval]=bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
                    end
                end
            end
            
        end
        
        
        
        
        %% BLOCK 6: FEVD
        
        % compute FEVD if the option has been retained
        if FEVD==1 || favar.FEVD.plot==1
            % warning if the model is not fully identified as the results can be misleading
            if IRFt==4 && size(strctident.signreslabels_shocks,1)~=n
                message='Model is not fully identified. FEVD results can be misleading.';
                msgbox(message,'FEVD warning','warn','warning');
            end
            
            % run the Gibbs sampler to compute posterior draws
            [fevd_estimates]=bear.fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
            % compute approximate favar fevd estimates
            if favar.FEVD.plot==1
                [favar]=bear.favar_fevd(gamma_record,It,Bu,n,IRFperiods,FEVDband,favar,IRFt);
            end
            % display the results
            bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
        end
        
        
        
        %% BLOCK 7: historical decomposition
        if HD==1
            if stvol==4
                if IRFt==1||IRFt==2||IRFt==3
                    [hd_record]=bear.hdecomp_stvol4(beta_gibbs,D_record,It,Bu,YincLags,n,m,p,k,T, data_exo, exo, Psi_gibbs,strctident, IRFt);
                    [hd_estimates]=bear.hdestimates_inc_exo_stvol4(hd_record,n,T,HDband);
                elseif IRFt==4
                    %[hd_estimates]=bear.hdestimates_set_identified(hd_record,n,T,const,exo,HDband,IRFband,struct_irf_record, IRFperiods,YincLags(2*p+1:end,:),Xcycle,p,k,strctident);
                    [hd_estimates]=bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
                end
                [identified] = bear.hddisp_stvol4(hd_estimates, n, exo, T,const,strctident.signreslabels_shocks, IRFt,pref,decimaldates1(sizetraining+1:end), decimaldates2(sizetraining+1:end),endo,stringdates1(sizetraining+1:end),m,HDall,YincLags,p,strctident);
            else % if the VAR model is a stochastic volatility VAR without trend
                % run the Gibbs sampler to compute posterior draws
                [hd_record,favar]=bear.hdecomp_inc_exo(beta_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar);
                % compute posterior estimates
                if IRFt==1||IRFt==2||IRFt==3
                    [hd_estimates,favar]=bear.hdestimates_inc_exo(hd_record,n,T,HDband,favar); % output is here named hd_record fit the naming conventions of HDestdisp
                elseif IRFt==4
                    [hd_estimates,favar]=bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
                end
                % display the HDs
                bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
            end
        end
        
        %% BLOCK 8: conditional forecasts
        
        % compute conditional forecasts if the option has been retained
        if CF==1
            % if the type of conditional forecasts corresponds to the standard methodology
            
            if CFt==1||CFt==2
                % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
                if stvol == 4
                    [cforecast_record,cfstrshocks_record]=bear.cforecast12_stvol4(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record, n,m,p,k,q, Psi_gibbs, sizetraining, dataValues, Fstartlocation, Fendsmpl, Psi_median);
                else
                    [cforecast_record,cfstrshocks_record]=bear.cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
                end
                % if the type of conditional forecasts corresponds to the tilting methodology
            elseif CFt==3||CFt==4
                [cforecast_record]=bear.tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,It,Bu);
            end
            % compute posterior estimates
            [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
            % display the results for the forecasts
            if stvol==4
                bear.cfdisp(YincLags,n,T+2*p,endo,stringdates2(sizetraining-2*p+1:end),decimaldates2(sizetraining-2*p+1:end),Fstartlocation-sizetraining+2*p,Fendlocation-sizetraining+2*p,cforecast_estimates,pref);
            else
                bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
            end
        end
        
        
        % here finishes grand loop 5
        % if the model selected is not a stochastic volatility BVAR, this part will not be run
    end
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Grand loop 6: Time-varying BVAR model
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % if the selected model is the time-varying BVAR, run this part
    if VARtype==6
        
        
        
        %% BLOCK 1: OLS ESTIMATES AND PRELIMINARY ELEMENTS
        
        % preliminary OLS VAR and univariate AR estimates
        [Bhat, betahat, sigmahat, X, ~, Y, ~, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
        [arvar]=bear.arloop(data_endo,const,p,n);
        [yt, y, Xt, Xbart, Xbar]=bear.tvbvarmat(Y,X,n,q,T);
        
        
        %% BLOCK 2: POSTERIOR DERIVATION
        % if the model is the time-varying coefficients only
        if tvbvar==1
            % obtain prior elements
            [chi, psi, kappa, S, H, I_tau]=bear.tvbvar1prior(arvar,n,q,T);
            % run the Gibbs sampling algorithm to recover the posterior distributions
            if favar.FAVAR==0
                [beta_gibbs, omega_gibbs, sigma_gibbs]=...
                    bear.tvbvar1gibbs(S,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,H,Xbar,y);
            elseif favar.FAVAR==1 % FAVAR two-step estimation (static factors)
                [beta_gibbs, omega_gibbs, sigma_gibbs, favar]=...
                    bear.favar_tvbvar1gibbs(S,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,H,Xbar,y,data_endo,lags,favar);
            end
            % compute posterior estimates
            [beta_t_median, beta_t_std, beta_t_lbound, beta_t_ubound, omega_median, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound]=...
                bear.tvbvar1estimates(beta_gibbs,omega_gibbs,sigma_gibbs,q,T,cband);
            
            
            % if the model is the general time-varying
        elseif tvbvar==2
            % obtain prior elements
            [chi, psi, kappa, S, H, I_tau, G, I_om, f0, upsilon0]=bear.tvbvar2prior(arvar,n,q,T,gamma);
            % run the Gibbs sampling algorithm to recover the posterior distributions
            if favar.FAVAR==0
                [beta_gibbs, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs ,sigma_t_gibbs, sbar]...
                    =bear.tvbvar2gibbs(G,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,I_om,H,Xbar,y,alpha0,yt,Xbart,upsilon0,f0,delta0,gamma,pick,pickf);
            elseif favar.FAVAR==1 % FAVAR two-step estimation (static factors)
                [beta_gibbs, omega_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs ,sigma_t_gibbs, sbar, favar]...
                    =bear.favar_tvbvar2gibbs(G,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,I_om,H,Xbar,y,alpha0,yt,Xbart,upsilon0,f0,delta0,gamma,pick,pickf,data_endo,lags,favar);
            end
            % compute posterior estimates
            [beta_t_median, beta_t_std, beta_t_lbound, beta_t_ubound, omega_median, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound]=bear.tvbvar2estimates(beta_gibbs,omega_gibbs,F_gibbs,L_gibbs,phi_gibbs,sigma_gibbs,lambda_t_gibbs,sigma_t_gibbs,n,q,T,cband);
        end
        
        
        %% BLOCK 3: MODEL EVALUATION
        
        % display the VAR results
        bear.tvbvardisp(beta_t_median,beta_t_std,beta_t_lbound,beta_t_ubound,sigma_median,sigma_t_lbound,sigma_t_median,sigma_t_ubound,Xbart,Y,yt,n,m,p,k,q,T,tvbvar,gamma,alpha0,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref)
        
        
        %% BLOCK 4: IRFs
        
        % compute IRFs if the option has been retained
        
        % run the Gibbs sampler to obtain posterior draws
        [irf_record]=bear.tvbvarirf(beta_gibbs,omega_gibbs,It,Bu,IRFperiods,n,m,p,k,q,T);
        
        % If IRFs have been set to an unrestricted VAR (IRFt=1):
        if IRFt==1
            % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
            [D_record, gamma_record]=bear.irfunres(n,It,Bu,sigma_gibbs);
            
            % If IRFs have been set to an SVAR with Choleski identification (IRFt=2):
        elseif IRFt==2
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.irfchol(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
            
            % If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
        elseif IRFt==3
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
            
            % If IRFs have been set to an SVAR with sign restrictions (IRFt=4):
        elseif IRFt==4
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record, D_record, gamma_record,favar]=bear.tvirfres(beta_gibbs,omega_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,q,T,signrestable,signresperiods,favar);
        end
        
        % If an SVAR was selected, also compute the structural shock series
        if IRFt==2||IRFt==3||IRFt==4
            % compute first the empirical posterior distribution of the structural shocks
            [strshocks_record]=bear.tvstrshocks(beta_gibbs,D_record,y,Xbar,n,T,It,Bu);
            % compute posterior estimates
            [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
            % display the results
            bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
        end
        
        
        if IRF==1 || favar.IRF.plot==1
            % compute posterior estimates
            if IRFt==1 || IRFt==2 || IRFt==3 || IRFt==4
                [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
                % % %             elseif IRFt==4
                % % %                 [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates_set_identified(struct_irf_record,n,IRFperiods,IRFband,D_record,strctident,favar);
            end
            
            if IRF==1
                % display the results
                bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
            end
            %display IRFs for information variables, output in excel
            if favar.IRF.plot==1
                [favar]=bear.favar_irfdisp(favar,IRFperiods,endo,IRFt,strctident,pref);
            end
            
            
            % if the option IRFs for all period is selected
            if alltirf==1
                % if no stochastic volatility
                if tvbvar==1
                    % gibbs sampling
                    [irf_record_allt,favar]=bear.tvbvarirf2(beta_gibbs,D_record,It,Bu,IRFperiods,n,m,p,k,T,favar);
                    % if stochastic volatility, and the model is not defined by sign restrictions
                elseif tvbvar==2 && IRFt~=4
                    % recover the structural decomposition matrix for each period
                    [irf_record_allt,favar]=bear.tvbvarirf3(beta_gibbs,sigma_t_gibbs,IRFt,It,Bu,IRFperiods,n,m,p,k,T,favar);
                    % if stochastic volatility, and the model is defined by sign restrictions
                elseif tvbvar==2 && IRFt==4
                    % recover the structural decomposition matrix for each period
                    [irf_record_allt]=bear.tvbvarirf4(beta_gibbs,sigma_t_gibbs,It,Bu,IRFperiods,n,m,p,k,T,signresperiods,signrestable);
                end
                % point estimates
                [irf_estimates_allt,favar]=bear.irfestimates2(irf_record_allt,n,T,IRFperiods,IRFband,endo,stringdates1,pref,favar);
                % plot
                bear.irfdisp2(n,T,decimaldates1,endo,IRFperiods,IRFt,irf_estimates_allt,pref,signreslabels);
                
                %display IRFs for information variables, output in excel
                if favar.IRF.plot==1
                    bear.favar_irfdisp2(n,T,decimaldates1,stringdates1,endo,IRFperiods,IRFt,pref,strctident,favar);
                end
            end
            
        end
        
        
        %% BLOCK 5: FORECASTS
        
        % compute forecasts if the option has been retained
        if F==1
            % run the Gibbs sampler to obtain draws from the posterior predictive distribution
            % if the model is the VAR coefficients only model
            if tvbvar==1
                [forecast_record]=bear.forecasttv1(data_endo_a,data_exo_p,It,Bu,beta_gibbs,omega_gibbs,sigma_gibbs,Fstartlocation,Fperiods,n,p,k,q,const);
                % if the model is the general model
            elseif tvbvar==2
                [forecast_record]=bear.forecasttv2(data_endo_a,data_exo_p,It,Bu,beta_gibbs,omega_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma,sbar,Fstartlocation,Fperiods,n,p,k,q,const);
            end
            % compute posterior estimates
            [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
            % display the results for the forecasts
            bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
            % finally, compute forecast evaluation if the option was selected
            if Feval==1
                [Forecasteval]=bear.tvbvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
            end
        end
        
        
        %% BLOCK 6: FEVD
        
        % compute FEVD if the option has been retained
        if FEVD==1 || favar.FEVD.plot==1
            % warning if the model is not fully identified as the results can be misleading
            if (IRFt==4 && size(strctident.signreslabels_shocks,1)~=n) || (IRFt==6 && size(strctident.signreslabels_shocks,1)~=n) || IRFt==5
                message='Model is not fully identified. FEVD results can be misleading.';
                msgbox(message,'FEVD warning','warn','warning');
            end
            % run the Gibbs sampler to compute posterior draws
            [fevd_estimates]=bear.fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
            % compute approximate favar fevd estimates
            if favar.FEVD.plot==1
                [favar]=bear.favar_fevd(gamma_record,It,Bu,n,IRFperiods,FEVDband,favar,IRFt);
            end
            % display the results
            bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
        end
        
        
        %% BLOCK 7: historical decomposition
        
        % compute historical decomposition if the option has been retained
        if HD==1
            % run the Gibbs sampler to compute posterior draws
            [hd_record]=bear.tvhdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Y,n,m,p,k,T);
            % compute posterior estimates
            [hd_estimates]=bear.hdestimates(hd_record,n,T,HDband);
            % display the results
            bear.hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels);
        end
        
        
        
        %% BLOCK 8: conditional forecasts
        
        % compute conditional forecasts if the option has been retained
        if CF==1
            % if the type of conditional forecasts corresponds to the standard methodology
            if CFt==1||CFt==2
                % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
                [cforecast_record]=bear.tvcforecast(n,m,p,k,q,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,data_exo_p,beta_gibbs,omega_gibbs,sigma_gibbs,D_record,gamma_record,Fstartlocation,Y,CFt);
                % if the type of conditional forecasts corresponds to the tilting methodology
            elseif CFt==3||CFt==4
                [cforecast_record]=bear.tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,It,Bu);
            end
            % compute posterior estimates
            [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
            % display the results for the forecasts
            bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
        end
        
        
        % here finishes grand loop 6
        % if the model selected is not a time-varying BVAR, this part will not be run
    end
    
%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grand loop 7: Mixed frequency BVAR model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if the selected model is the Mixed frequency BVAR, run this part

% This code has been adapted by Boris Blagov from code for the Federal reserve Bank of Philadelphia, which is in turn
% based on the original code by Schorfheide and Song. The original code has been modified at some parts to speed up the computation.
% All errors are our own

if VARtype == 7
    mf_setup.H = Input.H;
    mf_setup.data = data_endo;
    mf_setup.It     = It;
    mf_setup.Bu     = Bu;
    mf_setup.hyp    = [lambda1; lambda2; lambda3; lambda4; lambda5];
    mf_setup.lags   = lags;
    mf_setup.YMC_orig    = YMC_orig;
    mf_setup.nex    = const;
    Output = bear.MF_BVAR_BEAR(mf_setup);
    Y           = Output.Y;
    X           = Output.X;
    data_endo_a = [data_endo_a(1:mf_setup.lags,:); Y];
    beta_gibbs = Output.beta_gibbs;
    sigma_gibbs = Output.sigma_gibbs;
    n = mf_setup.Nm + mf_setup.Nq;
    p = mf_setup.lags;
    m = 1;
    k = n*p+m;
    T = size(Y,1);
    q=n*k;
    YY_past_forfcast = Output.YY_past_forfcast;
    [Bcap,betacap,Scap,alphacap,phicap,alphatop]=bear.dopost(X,Y,T,k,n);
    % compute posterior estimates   
    [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.doestimates(betacap,phicap,Scap,alphacap,alphatop,n,k,cband);
    log10ml=NaN;
    dic=NaN;
    q=NaN;
    lambda6=NaN;
    lambda7=NaN;
    lambda8=NaN;
    PriorExcel=0;
   % merged the disp files, but we need some to provide some extra variables in the case we do not have prior 61
    theta_median=NaN; TVEH=NaN; indH=NaN;
    
    % display the VAR results
    bear.bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,dic,X,Y,n,m,p,k,q,T,prior,bex,hogs,lrp,H,ar,lambda1,lambda2,lambda3,lambda4,lambda5,lambda6,lambda7,lambda8,IRFt,const,beta_gibbs,endo,data_endo,exo,startdate,enddate,decimaldates1,stringdates1,pref,scoeff,iobs,PriorExcel,strctident,favar,theta_median,TVEH,indH);
     
    
    %% BLOCK 5: IRFs

    % compute IRFs if the option has been retained

    if IRF==1
    % run the Gibbs sampler to obtain posterior draws
    [irf_record]=bear.irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k);

       % If IRFs have been set to an unrestricted VAR (IRFt=1):
       if IRFt==1
       % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
       [D_record gamma_record]=bear.irfunres(n,It,Bu,sigma_gibbs);
       % compute posterior estimates
       [irf_estimates,D_estimates,gamma_estimates]=bear.irfestimates(irf_record,n,IRFperiods,IRFband,IRFt,[],[]);
       % display the results
       bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,[],[],pref,[]);

       % If IRFs have been set to an SVAR with Choleski identification (IRFt=2):
       elseif IRFt==2
       % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
       [struct_irf_record D_record gamma_record]=bear.irfchol(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,favar);
       % compute posterior estimates
       [irfchol_estimates,D_estimates,gamma_estimates]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
       % display the results
       bear.irfdisp(n,endo,IRFperiods,IRFt,irfchol_estimates,D_estimates,gamma_estimates,pref,[]);

       % If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
       elseif IRFt==3
       % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
       [struct_irf_record D_record gamma_record]=bear.irftrig(sigma_gibbs,irf_record,It,Bu,IRFperiods,n);
       % compute posterior estimates
       [irftrig_estimates,D_estimates,gamma_estimates]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record);
       % display the results
       bear.irfdisp(n,endo,IRFperiods,IRFt,irftrig_estimates,D_estimates,gamma_estimates,pref,[]);

       % If IRFs have been set to an SVAR with sign restrictions (IRFt=4):
       elseif IRFt==4
       % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
       [struct_irf_record D_record gamma_record]=bear.irfres(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods);
       % compute posterior estimates
       [irfres_estimates,D_estimates,gamma_estimates]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record);
       % display the results
       bear.irfdisp(n,endo,IRFperiods,IRFt,irfres_estimates,D_estimates,gamma_estimates,pref,signreslabels);
       end

       % If an SVAR was selected, also compute the structural shock series
       if IRFt==2||IRFt==3||IRFt==4
       % compute first the empirical posterior distribution of the structural shocks
       [strshocks_record]=bear.strshocks(beta_gibbs,D_record,Y,X,n,k,It,Bu,favar);
       % compute posterior estimates
       [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
       % display the results
       bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
       end

    end


    % estimate IRFs for exogenous variables
    [exo_irf_record exo_irf_estimates]=bear.irfexo(beta_gibbs,It,Bu,IRFperiods,IRFband,n,m,p,k);
    % estimate IRFs for exogenous variables
    bear.irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref);


%% BLOCK 6: FORECASTS

% compute forecasts if the option has been retained
if F==1
% run the Gibbs sampler to obtain draws form the posterior predictive distribution
% [forecast_record]=bear.forecast(data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const);
% [forecast_record]=bear.forecast([data_endo_a(1:p,:); Y],[],It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const);
[forecast_record]=bear.forecast_mf(YY_past_forfcast,[],It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const);
% compute posterior estimates
% [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
[forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
    % Transform the variables
   Y_trans = Y; forecast_estimates_trans = forecast_estimates;
   for ii = 1:size(forecast_estimates,1)
       if mf_setup.select(1,ii) == 0
            forecast_estimates_trans{ii,1} = exp(forecast_estimates{ii,1});
            Y_trans(:,ii) = exp(Y(:,ii));
       else           
            forecast_estimates_trans{ii,1} = 100*(forecast_estimates{ii,1});
            Y_trans(:,ii) = 100*(Y(:,ii));
       end
   end
%   Y_trans = Y; forecast_estimates_trans = forecast_estimates_mf;
%    for ii = 1:size(forecast_estimates,1)
%        if mf_setup.select(1,ii) == 0
%             forecast_estimates_trans{ii,1} = exp(forecast_estimates_mf{ii,1});
%             Y_trans(:,ii) = exp(Y(:,ii));
%        else           
%             forecast_estimates_trans{ii,1} = 100*(forecast_estimates{ii,1});
%             Y_trans(:,ii) = 100*(Y(:,ii));
%        end
%    end
% display the results for the forecasts
bear.fdisp(Y_trans,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates_trans,pref);
% finally, compute forecast evaluation if the option was selected
   if Feval==1 
       %OLS single variable with BIC lag selection VAR for Rossi test
      [OLS_Bhat, OLS_betahat, OLS_sigmahat, OLS_forecast_estimates, biclag]=bear.arbicloop(data_endo,data_endo_a,const,p,n,m,Fperiods,Fband);
      [Forecasteval]=bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
   end
end






%% BLOCK 7: FEVD                THIS PART HAS NOT BEEN CHECKED IF IT WORKS AS IT REQUIRES MATLAB2016b

% compute FEVD if the option has been retained
if FEVD==1
% run the Gibbs sampler to compute posterior draws
[fevd_record]=bear.fevd(struct_irf_record,gamma_record,It,Bu,IRFperiods,n);
% compute posterior estimates
[fevd_estimates]=bear.fevdestimates(fevd_record,n,IRFperiods,FEVDband);
% display the results
bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,signreslabels);
end




%% BLOCK 8: historical decomposition  - coded to be done at the median of the monthly gdp estimates

% compute historical decomposition if the option has been retained
if HD==1
% run the Gibbs sampler to compute posterior draws 
[hd_record]=bear.hdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Y,X,n,m,p,k,T);
% compute posterior estimates
[hd_estimates]=bear.hdestimates(hd_record,n,T,HDband);
% display the results
bear.hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels);
end





%% BLOCK 9: conditional forecasts

% compute conditional forecasts if the option has been retained
if CF==1
   % if the type of conditional forecasts corresponds to the standard methodology
   if CFt==1||CFt==2
   % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
%    [cforecast_record]=bear.cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,k*n);
   [cforecast_record]=cforecast_mf(YY_past_forfcast,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,k*n);
   % if the type of conditional forecasts corresponds to the tilting methodology
   elseif CFt==3||CFt==4
   [cforecast_record]=bear.tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,It,Bu);
   end
   % compute posterior estimates
   [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
   Y_trans = Y; cforecast_estimates_trans = cforecast_estimates;
   for ii = 1:size(cforecast_estimates,1)
       if mf_setup.select(1,ii) == 0
            cforecast_estimates_trans{ii,1} = exp(cforecast_estimates{ii,1});
            Y_trans(:,ii) = exp(Y(:,ii));
       else           
            cforecast_estimates_trans{ii,1} = 100*(cforecast_estimates{ii,1});
            Y_trans(:,ii) = 100*(Y(:,ii));
       end
   end
   % display the results for the forecasts
   bear.cfdisp(Y_trans,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates_trans,pref);
end

if numt>1
    save(fullfile(pref.results_path,[pref.results_sub Fstartdate '.mat'])); % Save Workspace
end

Fstartdate_rolling=[Fstartdate_rolling; Fstartdate];

% here finishes grand loop 7
% if the model selected is not a mixed frequency BVAR, this part will not be run
end

    
    
    % End of forecasting loop
end %iteration


% forecast evaluation
if numt>1
    rolling_evaluation;
    % output: Rolling
end

% option to save matlab workspace
if pref.workspace==1
    save( fullfile(pref.results_path, [pref.results_sub '.mat']) );
end
