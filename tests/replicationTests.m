classdef replicationTests < matlab.unittest.TestCase
    
    properties
        testLoc
    end
    
    methods (TestClassSetup)
        
        function saveTestLocation(tc)
            
            tc.testLoc = fileparts(mfilename('fullpath'));
            % Need to run single threaded to get all the rng defaults
            % correct.
            ps = parallel.Settings;
            if ps.Pool.AutoCreate
                ps.Pool.AutoCreate=false;
                tc.addTeardown(@() set(ps.Pool,'AutoCreate',true))
            end
            
        end
        
    end
    
    methods (TestMethodSetup)
        
        function prepareTest(tc)
            close all
            cd(tc.testLoc)
            rng('default');
        end
        
    end
    
    methods (Test, TestTags = {'QuickReplications'})
        
        function Run_Var(tc)            
            % The default data set
            
            % this will replace the data.xlsx file in BEAR folder and the
            % bear_settings.m file in the BEAR\files folder
            
            % specify data file name:
            dataxlsx='data_.xlsx';
            % and the settings file name:
            settingsm='bear_settings_.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
            previousResults = load('results_test_data.mat');
            testFolder = fileparts(fileparts(mfilename('fullpath')));
            resultsFile = fullfile(testFolder,'results','results_test_data_temp.mat');
            currentResults = load(resultsFile);
            for f = fields(previousResults)'
                fld = f{1};
                if ~ismember(fld, ["checkRun","destinationfile","estimationinfo"])
                    tc.verifyEqual(currentResults.(fld), previousResults.(fld));
                end
            end
            delete(resultsFile);
            
        end
        
        function Run_VAR_61(tc)
            
            % testing prior 61
            
            % this will replace the data.xlsx file in BEAR folder and the
            % bear_settings.m file in the BEAR\files folder
            
            % specify data file name:
            dataxlsx='data_61.xlsx';
            %% and the settings file name:
            settingsm='bear_settings_61.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
            previousResults = load('results_test_data_61.mat');
            testFolder = fileparts(fileparts(mfilename('fullpath')));
            resultsFile = fullfile(testFolder,'results','results_test_data_61_temp.mat');
            currentResults = load(resultsFile);
            for f = fields(previousResults)'
                fld = f{1};
                if ~ismember(fld, ["checkRun","destinationfile","estimationinfo"])
                    tc.verifyEqual(currentResults.(fld), previousResults.(fld));
                end
            end
            delete(resultsFile);
            
        end
        
    end
    
    methods (Test, TestTags = {'MediumReplications'})
        
        function Run_VAR_CH2019(tc)
            
            % replication of Caldara & Herbst (2019): Monetary Policy, Real Activity, and Credit Spreads: Evidence from Bayesian Proxy SVARs
            
            % this will replace the data.xlsx file in BEAR folder and the
            % bear_settings.m file in the BEAR\files folder
            % specify data file name:
            dataxlsx='data_CH2019.xlsx';
            % and the settings file name:
            settingsm='bear_settings_CH2019.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
            previousResults = load('results_test_data_CH2019.mat');
            testFolder = fileparts(fileparts(mfilename('fullpath')));
            resultsFile = fullfile(testFolder,'results','results_test_data_CH2019_temp.mat');
            currentResults = load(resultsFile);
            for f = fields(previousResults)'
                fld = f{1};
                if ~ismember(fld, ["checkRun","destinationfile","estimationinfo"])
                    tc.verifyEqual(currentResults.(fld), previousResults.(fld));
                end
            end
            delete(resultsFile);
            
        end
        
    end
    
    methods (Test)
        
        function Run_VAR_AAU2009(tc)
            
            %% replication of Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects
            % of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction
            % One-Step Bayesian estimation (Gibbs Sampling) with four factors, CPI and FFR
            % baseline sign-restriciton scheme
            
            %% this will replace the data.xlsx file in BEAR folder and the
            %% bear_settings.m file in the BEAR\files folder
            %% specify data file name:
            dataxlsx='data_AAU2009.xlsx';
            %% and the settings file name:
            settingsm='bear_settings_AAU2009.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
        end
        
        function Run_VAR_BBE2005(tc)
            % replication of Bernanke, Boivin, Eliasz (2005): MEASURING THE EFFECTS OF
            % MONETARY POLICY: A FACTOR-AUGMENTED VECTOR AUTOREGRESSIVE (FAVAR) APPROACH
            % One-Step Bayesian estimation (Gibbs Sampling) with three factors and FFR
            
            % this will replace the data.xlsx file in BEAR folder and the
            % bear_settings.m file in the BEAR\files folder
            % specify data file name:
            dataxlsx='data_BBE2005.xlsx';
            %% and the settings file name:
            settingsm='bear_settings_BBE2005.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
        end
        
        function Run_VAR_BvV2018(tc)
            
            %% replication of Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean
            
            %% this will replace the data.xlsx file in BEAR folder and the
            %% bear_settings.m file in the BEAR\files folder
            %% specify data file name:
            dataxlsx='data_BvV2018.xlsx';
            %% and the settings file name:
            settingsm='bear_settings_BvV2018.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
        end             
        
        function Run_VAR_WGP20016(tc)
            
            %% extended replication of Wieladek & Garcia Pascual (2016): The European Central Bank's QE: A New Hope
            % who lend the approach from Weale & Wieladek (2016): What are the macroeconomic effects of asset purchases?
            % extended sample from 2014m5 to 2018m12, identification schemes I, II, III
            % data set additionally includes several series to assess potential transmission channels and country specific effects (DE, FR, IT)
            % extended by Marius Schulte (mail@mbschulte.com)
            
            %% this will replace the data.xlsx file in BEAR folder and the
            %% bear_settings.m file in the BEAR\files folder
            %% specify data file name:
            dataxlsx='data_WGP2016.xlsx';
            %% and the settings file name:
            settingsm='bear_settings_WGP2016.m';
            %(and copy both to the replications\data folder)
            % then run other preliminaries
            runprelim;
            
        end
        
    end
    
end