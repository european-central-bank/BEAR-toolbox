% script excelrecord8
% records the information contained in the worksheet 'cond forecasts' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
cforecastcell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates2,1)+3,1);

% loop over variables (horizontal dimension)
for ii=1:n
   % create cell of forecast record for variable ii
   temp=['conditional forecasts: ' endo{ii,1}];
   cforecast_i=[temp {''} {''} {''} {''};{''} {''} {''} {''} {''};{''} {'sample'} {'lw. bound'} {'median'} {'up. bound'};stringdates2 num2cell((cplotdata{ii,1})')];
   
   % switch NaN entries to empty
   cforecast_i(~cellfun(@any,cforecast_i))={[]};
cforecastcell=[cforecastcell cforecast_i vertspace];
end

% trim
cforecastcell=cforecastcell(:,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],cforecastcell,'cond forecasts','B2');
end










