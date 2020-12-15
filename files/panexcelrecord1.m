



% start by deleting the previous excel save
delete([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx']);

% then copy the blank excel file from the files to the data folder
sourcefile=[pwd filesep 'results panel.xlsx'];
destinationfile=[pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'];
copyfile(sourcefile,destinationfile);



% then start copying the general info on the first excel worksheet

% create the cell storing the information
generalinfo=cell(59,max([size(endo,1) size(exo,1)+1 size(Units,1)]));


% then fill all the categories, one by one:

% estimation date
generalinfo{1,1}=datestr(clock);

% panel type
if panel==1
generalinfo{6,1}='Mean group estimator';
elseif panel==2
generalinfo{6,1}='Pooled estimator';
elseif panel==3
generalinfo{6,1}='Random effect (Zellner-Hong)';
elseif panel==4
generalinfo{6,1}='Random effect (hierarchical)';
elseif panel==5
generalinfo{6,1}='Static structural factor';
elseif panel==3
generalinfo{6,1}='Dynamic structural factor';
end

% structural identification
if IRF==1
   if IRFt==1
   generalinfo{7,1}='none';
   elseif IRFt==2
   generalinfo{7,1}='Choleski factorisation';
   end
end

% units
for ii=1:size(Units,1)
generalinfo{8,ii}=Units{ii,1};
end

% endogenous variables
for ii=1:size(endo,1)
generalinfo{9,ii}=endo{ii,1};
end

% exogenous variables
if const==1
generalinfo{10,1}='constant';
   for ii=1:size(exo,1)
   generalinfo{10,ii+1}=exo{ii,1};
   end
elseif const==0
   for ii=1:size(exo,1)
   generalinfo{10,ii}=exo{ii,1};
   end
end

% sample start date
generalinfo{11,1}=startdate;

% sample end date
generalinfo{12,1}=enddate;

% lag number
generalinfo{13,1}=lags;

% ar coefficient
if panel==2
generalinfo{18,1}=num2str(ar);
end

% lambda 1
if panel==2 || panel==3
generalinfo{19,1}=num2str(lambda1);
end

% lambda 2
if panel==4
generalinfo{20,1}=num2str(lambda2);
end

% lambda 3
if panel==2 || panel==4
generalinfo{21,1}=num2str(lambda3);
end

% lambda 4
if panel==2 || panel==4
generalinfo{22,1}=num2str(lambda4);
end

% s0
if panel==4
generalinfo{23,1}=num2str(s0);
end

% v0
if panel==4
generalinfo{24,1}=num2str(v0);
end

% alpha0
if panel==5 || panel==6
generalinfo{25,1}=num2str(alpha0);
end

% delta0
if panel==5 || panel==6
generalinfo{26,1}=num2str(delta0);
end

% gamma
if panel==6
generalinfo{27,1}=num2str(gama);
end

% a0
if panel==6
generalinfo{28,1}=num2str(a0);
end

% b0
if panel==6
generalinfo{29,1}=num2str(b0);
end

% rho
if panel==6
generalinfo{30,1}=num2str(rho);
end

% psi
if panel==6
generalinfo{31,1}=num2str(psi);
end

% total iterations
if panel~=1
generalinfo{32,1}=num2str(It);
end

% burn-in iterations
if panel~=1
generalinfo{33,1}=num2str(Bu);
end

% post burn selection
if (panel==4 || panel==5 || panel==6) && pick==0
generalinfo{34,1}='no';
elseif (panel==4 || panel==5 || panel==6) && pick==1
generalinfo{34,1}='yes';
end

% selection frequency
if pick==1
generalinfo{35,1}=num2str(pickf);
end
   
% IRF
if IRF==1
generalinfo{40,1}='yes';
elseif IRF==0
generalinfo{40,1}='no';
end

% IRF periods
if IRF==1
generalinfo{41,1}=IRFperiods;
end

% unconditional forecasts
if F==1
generalinfo{42,1}='yes';
elseif F==0
generalinfo{42,1}='no';
end

% conditional forecasts
if CF==1
generalinfo{43,1}='yes';
elseif CF==0
generalinfo{43,1}='no';
end

% type of conditional forecasts
if CF==1
   if CFt==1
   generalinfo{44,1}='Standard (all shocks)';  
   elseif CFt==2
   generalinfo{44,1}='Standard (shock-specific)';    
   end
end

% forecast start date
if (F==1 || CF==1)
generalinfo{45,1}=Fstartdate;
end

% forecast end date
if (F==1 || CF==1)
generalinfo{46,1}=Fenddate;
end
       
% user-supplied predicted exogenous
if (F==1 || CF==1)
   if (ptype==1 || ptype==2 || ptype==3)
   generalinfo{47,1}='yes';
   else
   generalinfo{47,1}='no';
   end
end

% forecast evaluation
if F==1 && Feval==1
generalinfo{48,1}='yes';
elseif F==1 && Feval==0
generalinfo{48,1}='no';
end

% FEVD
if FEVD==1
generalinfo{49,1}='yes';
elseif FEVD==0
generalinfo{49,1}='no';
end

% historical decomposition
if HD==1
generalinfo{50,1}='yes';
elseif HD==0
generalinfo{50,1}='no';
end

% confidence level: VAR estimates
generalinfo{55,1}=cband;

% confidence level: IRF
if IRF==1
generalinfo{56,1}=IRFband;
end

% confidence level: forecasts
if (F==1 || CF==1)
generalinfo{57,1}=Fband;
end

% confidence level: FEVD
if FEVD==1
generalinfo{58,1}=FEVDband;
end

% confidence level: HD
if HD==1
generalinfo{59,1}=HDband;
end

% write on excel file
if pref.results==1
        xlswritegeneral([pref.datapath filesep 'results' pref.results_sub '.xlsx'],generalinfo,'estimation info','C2');
end


% if conditional forecast has been chosen, record the values

if CF==1
   % read first the conditions sheet
   [~,~,condtable]=xlsread('data panel.xls','conditions');
   % convert the NaN entries into empty matrices
   condtable(cellfun(@(x) any(isnan(x)),condtable))={[]};
   % create an horizontal space for formatting
   [row clmn]=size(condtable);
   horzspace=repmat({''},1,clmn-1);
   % then initiate the cell for conditional forecast
   cfcell=[{'table 1: conditions'} horzspace;{''} horzspace; condtable];
      if CFt==2
      % read the other two excel sheets: shocks and blocks
      % add horizontal spaces between the two tables
      cfcell=[cfcell;{''} horzspace;{''} horzspace;{''} horzspace];
      %load the table of shocks on Excel
      [~,~,shocktable]=xlsread('data panel.xls','shocks');
      % convert the NaN entries into empty matrices
      shocktable(cellfun(@(x) any(isnan(x)),shocktable))={[]};
      % concatenate
      cfcell=[cfcell;{'table 2: shocks'} horzspace;{''} horzspace; shocktable];
      % add horizontal spaces between the two tables
      cfcell=[cfcell;{''} horzspace;{''} horzspace;{''} horzspace];
      % load the table of blocks on Excel
      [~,~,blocktable]=xlsread('data panel.xls','blocks');
      % convert the NaN entries into 0 entries
      blocktable(cellfun(@(x) any(isnan(x)),blocktable))={[]};
      % concatenate
      cfcell=[cfcell;{'table 3: blocks'} horzspace;{''} horzspace; blocktable];
      end
   % write on excel file
   if pref.results==1
       xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],cfcell,'cond forecasts prior','B2');
   end
end





% record the predicted values for exogenous, if there is any other than the constant

if (F==1 || CF==1)
   if size(exo,1)>0
   % first line of text explaining whether predicted exogenous had to be created or was fully provided by the data set
      if ptype==1
      label={'prediction type: user-specified'};
      elseif ptype==2
      label={'prediction type: replication of last known value'};
      elseif ptype==3
      label={'prediction type: forecast from individual AR model'};
      else
      label={'predicted values entirely obtained from the data set'};
      end
   horzspace=repmat({''},1,size(exo,1));
   pexocell=[label horzspace;{' '} horzspace;{' '} exo';Fstrings num2cell(data_exo_p)];
   % write on excel file
   if pref.results==1
       xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],pexocell,'predicted exo','B2');
   end
   end
end


