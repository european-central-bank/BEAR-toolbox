function [colmn]=excelclmn(n)


% function [colmn]=excelclmn(n)
% reports the Excel file column name corresponding to a column number
% for instance, column 3  corresponds to column D in Excel (the first column, column A, is omitted since it is never read by Matlab)
% inputs:  - integer 'n': the considered column (nth column)
% outputs: - string 'colmn': the string giving the Excel name of the column corresponding to n




% divide n by 26 and round to the closest lowest integer
series=floor(n/26);

% obtain the remainder of the division
element=rem(n,26);

% define the alphabet
alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';

% finally, define the correspondance in terms of Excel columns
if series==0
colmn=alphabet(element+1);
elseif series>=1
colmn=[alphabet(series) alphabet(element+1)];
end












