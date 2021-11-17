classdef tNewInterface < matlab.unittest.TestCase
    
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
            rng('default');
            s = rng;            
            addTeardown(tc, @() rng(s))
        end
        
    end
    
    methods (Test, TestTags = {'Git'})
        
        function tOLSVAR(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
                        
            resultsFile = "newTest";
            
            opts= BEARsettings('OLS', 'ExcelFile', fullfile(fullfile(bearroot(),'replications', 'data_.xlsx')));
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            
            BEARmain(opts);
            
            file = exist(fullfile(tempFixture.Folder, resultsFile + ".mat"), 'file');
            tc.verifyEqual(file, 2)
        end
        
        function tOLSVAR_IRFt2(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
            
            opts= BEARsettings('OLS', 'ExcelFile', fullfile(fullfile(bearroot(),'replications', 'data_.xlsx')));
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            opts.IRFt = 2;
            
            BEARmain(opts);
            
            file = exist(fullfile(tempFixture.Folder, resultsFile + ".mat"), 'file');
            tc.verifyEqual(file, 2)
        end
        
        function tBVAR_IRFt2(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
            
            opts = BEARsettings('BVAR', 'ExcelFile', fullfile(fullfile(bearroot(),'replications', 'data_.xlsx')), ...
                'prior', 'minnesota_univariate', 'IRFt', 4);
            opts.prior=11;
            opts.IRFt=2;
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            BEARmain(opts);
            
            file = exist(fullfile(tempFixture.Folder, resultsFile + ".mat"), 'file');
            tc.verifyEqual(file, 2)
        end
        
    end
    
end