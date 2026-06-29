classdef tIRFexo < matlab.unittest.TestCase
    %TIRFEXO Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Test, TestTags = {'Git'})

        function tPanelIRFforExo(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
            
            opts = BEARsettings('PANEL', 'ExcelFile', fullfile(fullfile(bearroot(),'default_bear_data.xlsx')), ...
                'panel', 'Random_hierarchical', 'FEVD', 0, 'HD', 0, 'F', 0);
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            opts.plot = false;
            opts.varexo = 'Oil';
            BEARmain(opts);
            
            d = load(fullfile(tempFixture.Folder, resultsFile + ".mat"));
            tc.verifyTrue(isfield(d, 'exo_irf_estimates'))

            tc.verifyEqual(size(d.exo_irf_estimates), [d.numendo d.m d.N])

        end

        function tBVARIRFforExo(tc)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFixture = tc.applyFixture(TemporaryFolderFixture);
            
            resultsFile = "newTest";
            
            opts = BEARsettings('BVAR', 'ExcelFile', fullfile(fullfile(bearroot(),'default_bear_data.xlsx')), 'FEVD', 0, 'HD', 0, 'F', 0);
            opts.results_path = tempFixture.Folder;
            opts.results_sub = 'newTest';
            opts.plot = false;
            opts.varexo = 'Oil';
            BEARmain(opts);
            
            d = load(fullfile(tempFixture.Folder, resultsFile + ".mat"));
            tc.verifyTrue(isfield(d, 'exo_irf_estimates'))

            tc.verifyEqual(size(d.exo_irf_estimates), [d.numendo d.m])

        end

    end

    methods (TestClassTeardown)

        function closeFigs(~)
            close(findobj('Tag','BEARresults'))
        end

    end

end

