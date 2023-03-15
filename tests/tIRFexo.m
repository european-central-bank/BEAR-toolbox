classdef tIRFexo < matlab.unittest.TestCase
    %TIRFEXO Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Test, TestTags = {'Git'})

        function tIRFforExo(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
            
            opts = BEARsettings('PANEL', 'ExcelFile', fullfile(fullfile(bearroot(),'default_bear_data.xlsx')), ...
                'panel', 'Random_hierarchical');
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            opts.plot = false;
            opts.varexo = 'Oil';
            BEARmain(opts);
            
            d = load(fullfile(tempFixture.Folder, resultsFile + ".mat"));
            tc.verifyTrue(isfield(d, 'exo_irf_estimates'))

        end

    end

end

