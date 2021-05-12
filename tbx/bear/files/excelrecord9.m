
% script excelrecord9
% records the information contained in the worksheet 'shocks' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
shockcell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates1,1)+3,1);

% loop over variables (horizontal dimension)
for ii=1:identified
% create cell of shock record for variable ii
   % if a sign restriction identification scheme has been used, use the structural shock labels
   temp=['structural shock: ' labels{ii,1}];
sshock_i=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell(strshocks_estimates{ii,1}')];
shockcell=[shockcell sshock_i vertspace];
end

% trim
shockcell=shockcell(:,1:end-1);

% write in excel
    xlswritegeneral([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'],shockcell,'struct shocks','B2');











