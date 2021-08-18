function [fixedstring]=fixstring(string)
%FIXSTRING utility function with several purposes:
% - clear possible initial spaces
% - turn possible multiple spaces into single spaces
% - replace irregular spaces (e.g. tab space) with regular spaces
% - suppress possible final spaces
% this guarantees good behaviour of the code

fixedstring = regexprep(strtrim(string), '[ ]{2,}',' ');