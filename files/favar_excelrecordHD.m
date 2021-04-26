% create the cell that will be saved on excel
hdcell_plotX={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+2,1);
% loop over variables (vertical dimension)
for jj=1:favar.npltX
tempcell={};
   % loop over shocks (horizontal dimension)
   for ii=1:size(contributions2_all{jj,1},2)
   % create cell of hd record for the contribution of shock jj in variable ii fluctuation
   temp=['contribution of ' labelsfavar_all{ii,1} ' shocks in ' favar.pltX{jj,1} ' fluctuation'];
   hd_ij=[temp {''} ;{''} {''};stringdates1 num2cell((contributions2_all{jj}(:,ii)))];
   tempcell=[tempcell hd_ij vertspace];
   end
count=size(contributions2_all{jj},2);
horzspace=repmat({''},2,3*(count));
hdcell_plotX=[hdcell_plotX; horzspace; tempcell];
end
% trim
hdcell_plotX=hdcell_plotX(1:end,1:end-1);
% write in excel
    xlswritegeneral([pref.datapath '\results\' pref.results_sub '.xlsx'],hdcell_plotX,'favar_hist decomp','B2');