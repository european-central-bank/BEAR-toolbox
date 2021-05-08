delete([pref.datapath filesep 'results' filesep pref.results_sub '.xlsx']);


% then copy the blank excel file from the files to the data folder
sourcefile=[pwd filesep 'results.xlsx'];
destinationfile=[pref.datapath filesep 'results' filesep pref.results_sub '.xlsx'];
copyfile(sourcefile,destinationfile);