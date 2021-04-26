%% replication of Bernanke, Boivin, Eliasz (2005): MEASURING THE EFFECTS OF
% MONETARY POLICY: A FACTOR-AUGMENTED VECTOR AUTOREGRESSIVE (FAVAR) APPROACH
% One-Step Bayesian estimation (Gibbs Sampling) with three factors and FFR

%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder
clear all
close all
warning off;
clc
%% specify data file name:
dataxlsx='data_BBE2005.xlsx';
%% and the settings file name:
settingsm='bear_settings_BBE2005.m';
%(and copy both to the replications\data folder)
% then run other preliminaries
runprelim;
