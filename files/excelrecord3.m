% script excelrecord3
% records the information contained in the worksheet 'steady state' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
sscell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates1,1)+3,1);

% loop over variables (horizontal dimension)
for ii=1:n
   % create cell of steady-state record for variable ii
   temp=['steady-state and actual: ' endo{ii,1}];
   ss_i=[temp {''} {''} {''} {''};{''} {''} {''} {''} {''};{''} {'sample'} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell(Y(:,ii)) num2cell(ss_estimates{ii,1}')];
sscell=[sscell ss_i vertspace];
end

% trim
sscell=sscell(:,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],sscell,'steady state','B2');
end










