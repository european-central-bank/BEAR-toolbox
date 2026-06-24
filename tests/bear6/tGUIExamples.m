classdef tGUIExamples < matlab.unittest.TestCase
    % run_gui_examples — Smoke-test every BEARX-GUI-Examples/<example>/master.m
    % against a local BEARX Toolbox.
    %
    % Usage (from BEARX-GUI-Examples/):
    %   results = run_gui_examples                                          % uses ../BEARX-Toolbox
    %   results = run_gui_examples('../BEARX-Toolbox-PATCHED')              % custom path
    %
    % Layout assumption:
    %   parent/
    %   ├── BEARX-GUI-Examples/      (this folder, cwd when calling)
    %   │   ├── Threshold/master.m
    %   │   ├── MixedFrequency/master.m
    %   │   └── SeparablePanel/master.m
    %   └── BEARX-Toolbox/           (or BEARX-Toolbox-PATCHED/)
    %       └── tbx/bear/bearing/
    %
    % Returns a table with one row per example: Folder, Status (PASS / FAIL),
    % Duration (s), and Identifier / Message on failure.

    properties (TestParameter)
        folder
    end

    properties
        RootDir
    end

    methods (TestClassSetup)
        function storeRoot(tc)
        tc.RootDir = pwd;
        end
    end

    methods (TestMethodTeardown)
        function restoreState(tc)
            close all force
            cd(tc.RootDir);
        end
    end

    methods (Test)
        function tGUIresults(tc, folder)
            cd(fullfile(tc.RootDir, "BEARX-GUI-Examples", folder));
            runMaster();
        end
    end

    methods (TestParameterDefinition,Static)
        function folder = initializeProperty()
            rootDir = fullfile(currentProject().RootFolder, 'BEARX-GUI-Examples');
            entries = dir(fullfile(rootDir, "*", "master.m"));
            [~,folder] = fileparts({entries.folder});
        end
    end

end

function outputDisplay = runMaster()
% Run the GUI-generated master.m in an isolated function workspace so that
% its leading `clear` does not wipe the caller's loop variables.
if isMATLABReleaseOlderThan('R2025a')
    master
else
    ws = matlab.lang.Workspace.currentWorkspace;
    outputDisplay = evaluateAndCapture(ws, "master");
end

end