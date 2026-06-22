function initexcel(pref)

resultsFile = fullfile(pref.results_path, [pref.results_sub '.xlsx'] );
if exist(resultsFile, 'file') == 2
    delete(resultsFile);
end

% then copy the blank excel file from the files to the data folder
sourcefile = [fileparts(mfilename('fullpath')) filesep 'results.xlsx'];
destinationfile = fullfile(pref.results_path, [pref.results_sub '.xlsx']);
if exist(pref.results_path, 'dir') == 0
    mkdir(pref.results_path)
end
copyfile(sourcefile,destinationfile);