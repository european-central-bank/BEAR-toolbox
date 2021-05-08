% the data file path and the settings file path
replicationpath=pwd;
datapath=[replicationpath filesep dataxlsx];
settingspath=[replicationpath filesep settingsm];

%BEAR path
cd ..\
BEARpath=pwd;
filespath=[BEARpath filesep 'files' filesep];

% replace the previous datafile with the one for the replication
copyfile(datapath,[BEARpath filesep 'data.xlsx']);

% replace the previous BEAR settings file with the one for the replication
copyfile(settingspath,[filespath 'bear_settings.m']);

% load the settings directly
run(fullfile([filespath 'bear_settings']));
% run main code
run(fullfile([filespath 'bear_toolbox_main_code']));