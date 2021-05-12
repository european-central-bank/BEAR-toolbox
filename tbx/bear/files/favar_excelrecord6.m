% create the cell that will be saved on excel
fevdcell={};

% build preliminary elements: space between the tables
horzspace=repmat({''},2,5*(identified+1));
vertspace=repmat({''},IRFperiods+3,1);

%subsample
informationvariablestrings=favar.informationvariablestrings(1,favar.plotX_index);

% loop over variables (vertical dimension)
for ii=1:favar.npltX
tempcell={};
   % loop over shocks (horizontal dimension)
   for jj=1:identified+1
   % create cell of fevd record for variable ii in response to shock jj
       temp=['part of ' informationvariablestrings{1,ii} ' fluctuation due to ' labels{jj,1} ' shocks'];   
   fevd_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};[num2cell((1:IRFperiods)') num2cell((favar_fevd_estimates{ii,jj})')]];
   tempcell=[tempcell fevd_ij vertspace];
   end
fevdcell=[fevdcell;horzspace;tempcell];
end
% trim
fevdcell=fevdcell(3:end,1:end-1);
% write in excel
    xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],fevdcell,'favar_FEVD','B2');