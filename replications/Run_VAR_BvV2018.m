%% replication of Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean

%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder
clear all
close all
warning off;
clc
%% specify data file name:
dataxlsx='data_BvV2018.xlsx';
%% and the settings file name:
settingsm='bear_settings_BvV2018.m';
%(and copy both to the replications\data folder)
% then run other preliminaries
runprelim;