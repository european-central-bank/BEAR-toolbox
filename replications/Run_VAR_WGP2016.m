%% extended replication of Wieladek & Garcia Pascual (2016): The European Central Bank's QE: A New Hope
% who lend the approach from Weale & Wieladek (2016): What are the macroeconomic effects of asset purchases?
% extended sample from 2014m5 to 2018m12, identification schemes I, II, III
% data set additionally includes several series to assess potential transmission channels and country specific effects (DE, FR, IT)
% extended by Marius Schulte (mail@mbschulte.com)

%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder
clear all
close all
warning off;
clc
%% specify data file name:
dataxlsx='data_WGP2016.xlsx';
%% and the settings file name:
settingsm='bear_settings_WGP2016.m';
%(and copy both to the replications\data folder)
% then run other preliminaries
runprelim;
