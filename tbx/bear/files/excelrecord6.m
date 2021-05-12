% script excelrecord6
% records the information contained in the worksheet 'FEVD' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
fevdcell={};

% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*identified);
vertspace=repmat({''},IRFperiods+3,1);

% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:identified
   % create cell of fevd record for variable ii in response to shock jj
      temp=['part of ' endo{ii,1} ' fluctuation due to ' endo{jj,1} ' shocks'];
   fevd_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};num2cell((1:IRFperiods)') num2cell((fevd_estimates{ii,jj})')];
   tempcell=[tempcell fevd_ij vertspace];
   end
fevdcell=[fevdcell;horzspace;tempcell];
end

% trim
fevdcell=fevdcell(3:end,1:end-1);

% write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],fevdcell,'FEVD','B2');
