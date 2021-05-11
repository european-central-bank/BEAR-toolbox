function [status,message]=xlswritegeneral(file,data,varargin)
% General function for writing to Excel on PC or Mac
% In the case of PC it is assumed that Excel is installed
% Use function xlwrite by Alec de Zegher
% Requries
% Note
%     * This function requires the POI library to be in your javapath.
%       To add the Apache POI Library execute commands: 
%       (This assumes the POI lib files are in folder 'poi_library')
%         javaaddpath('poi_library/poi-3.8-20120326.jar');
%         javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
%         javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
%         javaaddpath('poi_library/xmlbeans-2.3.0.jar');
%         javaaddpath('poi_library/dom4j-1.6.1.jar');
%     * Excel converts Inf values to 65535. xlwrite converts NaN values to
%       empty cells.
% Peter Welz, ECB
% 12 August 2018

if nargin <3
    sheet = [];
    range = [];
elseif nargin == 3
    sheet = varargin{1};
    range = [];
elseif nargin == 4
    sheet = varargin{1};
    range = varargin{2};
end

if ispc
    [status,message]=xlswrite(file,data,sheet,range);
elseif ismac
    status=xlwrite(replace(file,'\',filesep),data,sheet,range);
    if status==1
        message='Output successfully written using xlwrite';
    else
        message='An error occured using xlwrite';
    end
end
end