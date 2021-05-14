% the data file path and the settings file path
replicationpath=pwd;
datapath=fullfile(replicationpath, dataxlsx);
settingspath=fullfile(replicationpath, settingsm);

% load the settings directly
[~,bear_settings] = fileparts(settingspath);
eval(bear_settings);

%BEAR path
BEARpath  = bearroot();
filespath = fullfile(BEARpath, 'files');

% replace the previous datafile with the one for the replication
system( sprintf('copy %s %s',datapath, fullfile(BEARpath, 'data.xlsx') ) )

% run main code
bear_toolbox_main_code