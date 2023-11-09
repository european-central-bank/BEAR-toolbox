classdef tGridSearch < matlab.unittest.TestCase
    
    methods (Test, TestTags = {'Git', 'Unit'})
        function tGSunUsed(tc)
            s = BEARsettings(2, 'prior', 31);
            tc.verifyEqual(s.hogs,false);
            s.prior = 41;
            tc.verifyEqual(s.hogs,false);
            s.prior = 51;
            tc.verifyEqual(s.hogs,false);
            s.prior = 61;
            tc.verifyEqual(s.hogs,false);
            
            s.prior = 11;
            tc.verifyEqual(s.hogs, false);
            s.prior = 22;
            s.hogs = 1;
            tc.verifyEqual(s.hogs, true);
        end
        
        function tGSinMinnesota(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
                        
            s = BEARsettings(2, 'prior', 11, 'hogs',true);
            s.results_path = tempFixture.Folder;
            s.results_sub = 'newTest';
            s.plot = false;
            
            BEARmain(s)
            file = exist(fullfile(tempFixture.Folder, resultsFile + ".mat"), 'file');
            tc.verifyEqual(file, 2)
        end
        
        function tGSinNormalWishard(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
                        
            s = BEARsettings(2, 'prior', 22, 'hogs',true);
            s.results_path = tempFixture.Folder;
            s.results_sub = 'newTest';
            s.plot = false;
            
            BEARmain(s)
            file = exist(fullfile(tempFixture.Folder, resultsFile + ".mat"), 'file');
            tc.verifyEqual(file, 2)
        end
        
    end
    
end