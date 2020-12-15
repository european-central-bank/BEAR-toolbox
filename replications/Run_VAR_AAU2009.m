%% replication of Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects 
% of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction
% One-Step Bayesian estimation (Gibbs Sampling) with four factors, CPI and FFR
% baseline sign-restriciton scheme

%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder
clear all
close all
warning off;
clc
%% specify data file name:
dataxlsx='data_AAU2009.xlsx';
%% and the settings file name:
settingsm='bear_settings_AAU2009.m';
%(and copy both to the replications\data folder)
% then run other preliminaries
runprelim;
