function [XY]=favar_standardise(XX)
% function for standardizing the series in the columns of the centered factor data
%XY=XX/(diag(std(XX)));
XY=XX./repmat(std(XX,1),size(XX,1),1);