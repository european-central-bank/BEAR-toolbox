%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX           %
%                                                                          %
%    Authors:                                                              %
%    Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                       %
%    Björn van Roye  (bvanroye@bloomberg.net)                              %
%                                                                          %
%    Version 5.0                                                           %
%                                                                          %
%    The updated version 5 of BEAR has benefitted from contributions from  %
%    Boris Blagov, Marius Schulte and Ben Schumann.                        %
%                                                                          %
%    This version builds-upon previous versions where Romain Legrand was   %
%    instrumental in developing BEAR.                                      %
%                                                                          %
%    The authors are grateful to the following people for valuable input   %
%    and advice which contributed to improve the quality of the toolbox:   %
%    Paolo Bonomolo, Mirco Balatti, Marta Banbura, Niccolo Battistini,     %
%	 Gabriel Bobeica, Martin Bruns, Fabio Canova, Matteo Ciccarelli,       %
%    Marek Jarocinski, Michele Lenza, Francesca Loria, Mirela Miescu,      %
%    Michal Rubaszek, Barbara Rossi, Fabian Schupp, Peter Welz and         % 
%    Hugo Vega de la Cruz.                                                 %
%                                                                          %
%    These programmes are the responsibilities of the authors and not of   %
%    the ECB and all errors and ommissions remain those of the authors.    %
%                                                                          %
%    Using the BEAR toolbox implies acceptance of the End User Licence     %
%    Agreement and appropriate acknowledgement should be made.             %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
warning off;
clc

%% Run:
Run='BvV2018'; 
%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder

% List of replications:
% ##                if Run is emtpy, i.e.  '' , a test sample will be run
% #AAU2009#         Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction
% #BvV2018#         Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean
% #BBE2005#         Bernanke, Boivin, Eliasz (2005): Measuring the effects of Monetary Policy: A Factor-Augmented Vector Autoregressive (FAVAR) Approach
% #CH2019#          Caldara & Herbst (2019): Monetary Policy, Real Activity, and Credit Spreads: Evidence from Bayesian Proxy SVARs
% #WGP2016#         Wieladek & Garcia Pascual (2016): The European Central Bank's QE: A New Hope - (extended)





% naming conventions
% data_Run
% bear_settings_Run
%and copy both to the replications folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data and settings
%BEAR path
BEARpath=pwd;
filespath=[BEARpath filesep 'files' filesep];
% save them
checkRun.BEARpath=BEARpath;
checkRun.filespath=filespath;

% data file name
dataxlsx=['data_',Run,'.xlsx'];
% settings file name
settingsm=['bear_settings_',Run,'.m'];

% the data file path and the settings file path
replicationpath=[BEARpath filesep 'replications' filesep];
datapath=[replicationpath filesep dataxlsx];
settingspath=[replicationpath filesep settingsm];

% load the settings directly
bear_settings
% run main code
bear_toolbox_main_code