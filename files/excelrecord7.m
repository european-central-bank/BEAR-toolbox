% script excelrecord7
% records the information contained in the worksheet 'hist decomposition' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
hdcell={};

% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*(n+1));
vertspace=repmat({''},T+3,1);

% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:n
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
      % if a sign restriction identification scheme has been used, use the structural shock labels
      if IRFt==4 || IRFt==6 || IRFt==5
      temp=['contribution of ' signreslabels{jj,1} ' shocks in ' endo{ii,1} ' fluctuation'];
      % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
      else
      temp=['contribution of ' endo{jj,1} ' shocks in ' endo{ii,1} ' fluctuation'];
      end
   hd_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell((hd_estimates{ii,jj})')];
   tempcell=[tempcell hd_ij vertspace];
   end
% consider the contribution of exogenous
temp=['contribution of exogenous in ' endo{ii,1} ' fluctuation'];

hd_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell((hd_estimates{ii,n+1})')];
tempcell=[tempcell hd_ij vertspace];

hdcell=[hdcell;horzspace;tempcell];
end

% trim
hdcell=hdcell(3:end,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],hdcell,'hist decomposition','B2');
end
