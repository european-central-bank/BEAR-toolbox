
hd_estimates = hd_estimates'; 
% create the cell that will be saved on excel
hdcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);

% loop over variables (vertical dimension)
for ii=1:n
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:identified
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' labels1{jj,1} ' shocks in ' endo{ii,1} ' fluctuation'];
   hd_ij=[temp {''} ;{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,jj})')];
   tempcell=[tempcell hd_ij vertspace];
   end
count = identified;
% consider the contribution of initial conditions
temp=['contribution of initial conditions in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+1})')];
tempcell=[tempcell hd_ij vertspace];
%hdcell=[hdcell; horzspace; tempcell];
count = count+1;
% consider the contribution of the constant
if const==1
temp=['contribution of constant in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+2})')];
tempcell=[tempcell hd_ij vertspace];
count = count+1;
end


if m>1
    % consider the contribution of initial conditions
temp=['contribution of exogenous variables in ' endo{ii,1} ' fluctuation'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,n+3})')];
tempcell=[tempcell hd_ij vertspace];
count = count+1;
end

% unexplained 
if identified<n
temp=['Unexplained part ' endo{ii,1} ' fluctuation (due to missing identification)'];
hd_ij=[temp {''};{''} {''};{''} {''};stringdates1 num2cell((hd_estimates{ii,contributors+1})')];
tempcell=[tempcell hd_ij vertspace];
count = count+1;
end

horzspace=repmat({''},2,3*(count));

hdcell=[hdcell; horzspace; tempcell];

end
% trim
hdcell=hdcell(1:end,1:end-1);
% write in excel
    xlswritegeneral([pref.datapath '\results\' pref.results_sub '.xlsx'],hdcell,'hist decomp','B2');