function[H]=loadH(pref)
% load the data from Excel
[H txt]=xlsread(pref.excelFile,'Long run prior');
end