% script excelrecord4
% records the information contained in the worksheet 'IRF' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
irfcell={};

% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*identified);
vertspace=repmat({''},IRFperiods+3,1);

% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:identified
   % create cell of IRF record for variable ii in response to shock jj
      % if a sign restriction identification scheme has been used, use the structural shock labels
      if IRFt==4||IRFt==5||IRFt==6
      temp=['response of ' endo{ii,1} ' to ' strctident.signreslabels_shocks{jj,1} ' shocks'];
      else
      temp=['response of ' endo{ii,1} ' to ' endo{jj,1} ' shocks'];
      end
   irf_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};num2cell((1:IRFperiods)') num2cell((irf_estimates{ii,jj})')];
   tempcell=[tempcell irf_ij vertspace];
   end
irfcell=[irfcell;horzspace;tempcell];
end

% trim
irfcell=irfcell(3:end,1:end-1);

% write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],irfcell,'IRF','B2');
