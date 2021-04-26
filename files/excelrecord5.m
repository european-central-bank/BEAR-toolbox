% script excelrecord5
% records the information contained in the worksheet 'forecasts' of the excel spreadsheet 'results.xls'




% create the cell that will be saved on excel
forecastcell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates2,1)+3,1);

% loop over variables (horizontal dimension)
for ii=1:n
   % create cell of forecast record for variable ii
   temp=['forecasts: ' endo{ii,1}];
   forecast_i=[temp {''} {''} {''} {''};{''} {''} {''} {''} {''};{''} {'sample'} {'lw. bound'} {'median'} {'up. bound'};stringdates2 num2cell((plotdata{ii,1})')];
   
   % switch NaN entries to empty
   forecast_i(~cellfun(@any,forecast_i))={[]};
forecastcell=[forecastcell forecast_i vertspace];
end

% trim
forecastcell=forecastcell(:,1:end-1);

% write in excel
if pref.results==1
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],forecastcell,'forecasts','B2');
end










