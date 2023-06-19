function excelrecord2fcn(T, n, endo, stringdates1, Y, Ytilde, pref, EPStilde)
% script excelrecord2
% records the information contained in the worksheets 'actual fitted' and 'resids' of the excel spreadsheet 'results.xls'



% first compute the cell for actual/ fitted

% create the cell that will be saved on excel
afcell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);

% loop over variables (horizontal dimension)
for ii=1:n
% create cell of actual/fitted for variable ii
temp=['actual and fitted: ' endo{ii,1}];
af_i=[temp {''} {''};{''} {''} {''};{''} {'sample'} {'fitted'};stringdates1 num2cell(Y(:,ii)) num2cell(Ytilde(:,ii))];
afcell=[afcell af_i vertspace];
end

% trim
afcell=afcell(:,1:end-1);

% write in excel
if pref.results==1
    pref.exporter.writeActualFitted(afcell);
end



% then compute the cell for the residuals

% create the cell that will be saved on excel
horzspace=repmat({''},1,n);
rescell=[{'residuals'} horzspace;{''} horzspace;{''} endo';stringdates1 num2cell(EPStilde)];

% write in excel
if pref.results==1
    pref.exporter.writeResids(rescell);
end


