classdef tXtutorials < matlab.unittest.TestCase

    properties (TestParameter)
        tutorials = { ...
            'XDummies', ...
            'XConditionalForecasts', ...
            'XConditionalForecastsPanel', ...
            'XInstantZeroRestrictions', ...
            'XModelsPanel', ...
            'XPanelCrossSections', ...
            'XPanelNoCrossSections', ...
            'XPanelNoCrossSectionsOneCountry', ...
            'XThresholdTest', ...
            'XTVModels', ...
            };
    end

    properties
        WorkingFolder
    end

    methods (TestClassSetup)
        
        function enterTutorialDir(~)
            fld = fullfile(fileparts(bearroot), 'BEARX-tutorials-master');
            cd(fld)
        end

    end

    methods (TestClassTeardown)

        function exitTutorialDir(~)            
            cd(currentProject().RootFolder)
        end

    end

    methods (TestMethodSetup)

        function tCloseFigures(~)
            close all force
        end

    end

    methods (Test)

        function tTutorial(~, tutorials)
            
            cws = matlab.lang.Workspace.currentWorkspace;
            expression = sprintf("run(""%s"")", tutorials);
            outputDisplay = evaluateAndCapture(cws,expression);
            out = stripProgress(outputDisplay);
            disp(out)

        end

    end
end

function out = stripProgress(s)
% Remove BEAR progress-bar lines (long Unicode lines with NN%).
if isempty(s); out = ''; return; end
lines = regexp(s, '\r?\n', 'split');
keep = true(size(lines));
for k = 1:numel(lines)
    L = lines{k};
    if contains(L, char(9632)) || contains(L, char(9472)) || ...
            ~isempty(regexp(L, '\s+\d{1,3}%\s+', 'once'))
        keep(k) = false;
    end
end
out = strjoin(lines(keep), newline);
out = regexprep(out, '(\n\s*){3,}', sprintf('\n\n'));
end