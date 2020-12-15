% script excelrecord4
% records the information contained in the worksheet 'IRF' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
irfcell={};

% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*favar.IRF.npltXshck);
vertspace=repmat({''},IRFperiods+3,1);

%subsample
endo2={endo{favar.IRF.plotXshock_index,1}};
informationvariablestrings=favar.informationvariablestrings(1,favar.plotX_index);

% loop over variables (vertical dimension)
for ii=1:favar.npltX
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:favar.IRF.npltXshck %:nfactorshocks, insert again when all dimensions are considered in the irf favar estimation
   % create cell of IRF record for variable ii in response to shock jj
      % if a sign restriction identification scheme has been used, use the structural shock labels
      if IRFt==4
      temp=['response of ' informationvariablestrings{1,ii} ' to ' strctident.signreslabels{jj,1} ' shocks'];
      else
      temp=['response of ' informationvariablestrings{1,ii} ' to ' endo2{1,jj} ' shocks'];
      end
   irf_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};num2cell((1:IRFperiods)') num2cell((favar.IRF.favar_irf_estimates{ii,jj})')];
   tempcell=[tempcell irf_ij vertspace];
   end
irfcell=[irfcell;horzspace;tempcell];
end

% trim
irfcell=irfcell(3:end,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],irfcell,'IRF FAVAR','B2');
end
