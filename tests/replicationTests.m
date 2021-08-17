classdef replicationTests < matlab.unittest.TestCase
    
    properties
        testLoc
        RelTol = 1e-5
        AbsTol = 1e-6
        ToAvoid = [...
            "checkRun", "destinationfile", "estimationinfo", ...
            "BEARpath","datapath","filespath","pref", ...
            "replicationpath","settingspath","sourcefile","settingsm", ...
            "const", "VARtype", "OLS_Bhat", ...
            "IRFt", "IRF", "HD", "Feval", "Fendsmpl", "FEVD", ...
            "F", "CFt", "CF", "ii"]
    end
    
    methods (TestClassSetup)
        
        function setup(tc)
            
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
            s = rng;
            addTeardown(tc, @() rng(s))
        end
        
    end
    
    methods (Test, TestTags = {'QuickReplications'})
        
        function Run_Var(tc)
            % The default data set
            
            % specify data file name:
            dataxlsx='data_.xlsx';            
            excelPath    = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
            
            % and the settings:
            s = bear_settings_test(excelPath);
            
            % run BEAR
            BEARmain(s);
            
            compareResults(tc, 'results_test_data', s.pref)
        end
        
    end
    
    methods (Test, TestTags = {'MediumReplications'})
        
        function Run_VAR_61(tc)
            
            % testing prior 61
            
            % specify data file name:
            dataxlsx='data_61.xlsx';
            excelPath    = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
            
            % and the settings
            s = bear_settings_61_test(excelPath);
            
            % run BEAR
            BEARmain(s);
            
            compareResults(tc, 'results_test_data_61', s.pref)
        end
        
        function Run_VAR_CH2019(tc)
            ws = warning('off');
            tc.addTeardown(@() warning(ws));
            % replication of Caldara & Herbst (2019): Monetary Policy, Real Activity, and Credit Spreads: Evidence from Bayesian Proxy SVARs

            % specify data file name:
            dataxlsx='data_CH2019.xlsx';
            excelPath    = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
            
            % and the settings file 
            s = bear_settings_CH2019_test(excelPath);
            
            % run BEAR
            BEARmain(s);
            
            compareResults(tc, 'results_test_data_CH2019', s.pref)
        end
        
    end
    
    methods (Test, TestTags = {'LongReplications'})
        
        function Run_VAR_WGP20016(tc)
            
            % extended replication of Wieladek & Garcia Pascual (2016): The European Central Bank's QE: A New Hope
            % who lend the approach from Weale & Wieladek (2016): What are the macroeconomic effects of asset purchases?
            % extended sample from 2014m5 to 2018m12, identification schemes I, II, III
            % data set additionally includes several series to assess potential transmission channels and country specific effects (DE, FR, IT)
            % extended by Marius Schulte (mail@mbschulte.com)            
            
            % specify data file name:
            dataxlsx='data_WGP2016.xlsx';            
            excelPath    = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
            
            % and the settings
            s = bear_settings_WGP2016_test(excelPath);
                        
            % run BEAR
            BEARmain(s);
            
            compareResults(tc, 'results_test_data_WGP2016', s.pref)
        end
        
        function Run_VAR_BvV2018(tc)
            
            % replication of Banbura & van Vlodrop (2018): Forecasting with Bayesian Vector Autoregressions with Time Variation in the Mean

            % specify data file name:
            dataxlsx ='data_BvV2018.xlsx';
            excelPath = fullfile(fullfile(bearroot(),'replications'), dataxlsx);
            
            % and the settings
            s = bear_settings_BvV2018_test(excelPath);
            
            % run BEAR
            BEARmain(s);
            
            compareResults(tc, 'results_test_data_BvV2018', s.pref)
            
        end
        
    end
    
    methods (Access = private)
        
        function compareResults(tc, name, pref)
            
            previousResults = load( name + ".mat");
            resultsFile = fullfile(pref.results_path, name + "_temp" + ".mat");
            currentResults = load(resultsFile);
            for f = fields(previousResults)'
                fld = f{1};
                if ~ismember(fld, tc.ToAvoid)
                    if isfield(currentResults, fld)
                        tc.verifyEqual(currentResults.(fld), previousResults.(fld),'RelTol',tc.RelTol,'AbsTol',tc.AbsTol);
                    end
                end
            end
            delete(resultsFile);
            
        end
        
    end
% This replications take extremely long, they will be not part of the tests for now.
%     methods (Test)
%
%         function Run_VAR_AAU2009(tc)
%
%             %% replication of Amir Ahmadi & Uhlig (2009): Measuring the Dynamic Effects
%             % of Monetary Policy Shocks: A Bayesian FAVAR Approach with Sign Restriction
%             % One-Step Bayesian estimation (Gibbs Sampling) with four factors, CPI and FFR
%             % baseline sign-restriciton scheme
%
%             %% this will replace the data.xlsx file in BEAR folder and the
%             %% bear_settings.m file in the BEAR\files folder
%             %% specify data file name:
%             dataxlsx='data_AAU2009.xlsx';
%             %% and the settings file name:
%             settingsm='bear_settings_AAU2009.m';
%             %(and copy both to the replications\data folder)
%             % then run other preliminaries
%             runprelim;
%
%         end
%
%         function Run_VAR_BBE2005(tc)
%             % replication of Bernanke, Boivin, Eliasz (2005): MEASURING THE EFFECTS OF
%             % MONETARY POLICY: A FACTOR-AUGMENTED VECTOR AUTOREGRESSIVE (FAVAR) APPROACH
%             % One-Step Bayesian estimation (Gibbs Sampling) with three factors and FFR
%
%             % this will replace the data.xlsx file in BEAR folder and the
%             % bear_settings.m file in the BEAR\files folder
%             % specify data file name:
%             dataxlsx='data_BBE2005.xlsx';
%             %% and the settings file name:
%             settingsm='bear_settings_BBE2005.m';
%             %(and copy both to the replications\data folder)
%             % then run other preliminaries
%             runprelim;
%
%         end
%
%     end
    
end