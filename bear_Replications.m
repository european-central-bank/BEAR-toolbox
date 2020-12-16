%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX           %
%                                                                          %
%    This statistical package has been developed by the external           %
%    developments division of the European Central Bank.                   %
%                                                                          %
%    Authors:                                                              %
%    Romain Legrand  									                   %
%    Alistair Dieppe (adieppe@worldbank.org)                               %
%    Björn van Roye  (Bjorn.van_Roye@ecb.europa.eu)                        %
%                                                                          %
%    Version 5.0                                                           %
%                                                                          %
%    The authors are grateful to the following people for valuable input   %
%    and advice which contributed to improve the quality of the toolbox:   %
%    Paolo Bonomolo, Mirco Balatti, Marta Banbura, Niccolo Battistini,     %
%	 Gabriel Bobeica, Martin Bruns, Fabio Canova, Matteo Ciccarelli,       %
%    Marek Jarocinski, Michele Lenza, Francesca Loria, Mirela Miescu,      %
%    Gary Koop, Chiara Osbat, Giorgio Primiceri, Martino Ricci,            %
%    Michal Rubaszek, Barbara Rossi, Ben Schumann, Marius Schulte,         %
%    Peter Welz and Hugo Vega de la Cruz. 						           %
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
Run='5y5y'; 
%% this will replace the data.xlsx file in BEAR folder and the
%% bear_settings.m file in the BEAR\files folder

% List of replications:
% ##                if Run is emtpy, i.e.  '' , a test sample will be run
% #AAU2009#         Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction
% #BvV2018#         Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean
% #BBE2005#         Bernanke, Boivin, Eliasz (2005): MEASURING THE EFFECTS OF MONETARY POLICY: A FACTOR-AUGMENTED VECTOR AUTOREGRESSIVE (FAVAR) APPROACH
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

% replace the previous datafile with the one for the replication
% but first save the previous one
copyfile([BEARpath filesep 'data.xlsx'],[filespath 'data_previous.xlsx']);
copyfile(datapath,[BEARpath filesep 'data.xlsx']);

% replace the previous BEAR settings file with the one for the replication
% but first save the previous one
copyfile([filespath 'bear_settings.m'],[filespath  'bear_settings_previous.m']);
copyfile(settingspath,[filespath 'bear_settings.m']);

% create this one to let BEAR check if we started it via this Run file
checkRun.checkRun1=datetime;
save([filespath 'checkRun'],'checkRun');

% load the settings directly
run([filespath 'bear_settings']);
% run main code
run([filespath 'bear_toolbox_main_code'])