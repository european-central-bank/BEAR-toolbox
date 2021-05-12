%% replication of Caldara & Herbst (2019): Monetary Policy, Real Activity, and Credit Spreads: Evidence from Bayesian Proxy SVARs

%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder
clear all
close all
warning off;
clc
%% specify data file name:
dataxlsx='data_CH2019.xlsx';
%% and the settings file name:
settingsm='bear_settings_CH2019.m';
%(and copy both to the replications\data folder)
% then run other preliminaries
runprelim;
