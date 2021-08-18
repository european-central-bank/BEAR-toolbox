% the data file path and the settings file path
replicationpath = pwd;
excelPath    = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
settingspath = fullfile(replicationpath, settingsm);

% load the settings directly
[~,bear_settings] = fileparts(settingspath);
eval(bear_settings);

%BEAR path
BEARpath = bearroot();
filespath = fullfile(BEARpath, 'files');

% run main code
bear_toolbox_main_code