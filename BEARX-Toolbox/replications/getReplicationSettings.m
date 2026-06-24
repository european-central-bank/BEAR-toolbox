function [s, h] = getReplicationSettings(repName)
% GETREPLICATIONSETTINGS Get settings object corresponding to previous
% replication classes. Additionally, return a second output with the help
% text of the replication containing the information of the authors of that
% study.

arguments
    repName (1,1) string {mustBeMember(repName, ["AAU2009", "BBE2005", "BvV2018", "CH2019", "WGP2016", "bear_settings_", "61"])}
end

switch repName
    
    case "bear_settings_"
        s = bear_settings_;
        fn = 'bear_settings_';
    case "61"
        s = bear_settings_61;
        fn = 'bear_settings_61';
    case "AAU2009"
        s = bear_settings_AAU2009;
        fn = 'bear_settings_AAU2009';
    case "BBE2005"
        s = bear_settings_BBE2005;
        fn = 'bear_settings_BBE2005';
    case "BvV2018"
        s = bear_settings_BvV2018;
        fn = 'bear_settings_BvV2018';
    case "CH2019"
        s = bear_settings_CH2019;
        fn = 'bear_settings_CH2019';
    case "WGP2016"
        s = bear_settings_WGP2016;
        fn = 'bear_settings_WGP2016';
    otherwise
        error('getReplicationSettings:ReplicationNotFound','Unable to find the specified replication')
        
end
% Change results folder to current folder
s.results_path = pwd();

% Get model definition on non-deployed setups
if ~isdeployed
    h = help(fn);
else
    h = '';
end

end