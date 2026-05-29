function results = run_gui_examples(toolboxPath)
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

    arguments
        toolboxPath (1,1) string = "../BEARX-Toolbox"
    end

    rootDir = pwd;

    % 1) Put the toolbox on the MATLAB path
    tbxBear     = fullfile(toolboxPath, "tbx", "bear");
    tbxBearing  = fullfile(toolboxPath, "tbx", "bear", "bearing");
    assert(isfolder(tbxBear), "Toolbox not found at: %s", tbxBear);
    addpath(tbxBear,    "-end");
    addpath(tbxBearing, "-end");
    % Also expose this folder so the no-op +gui/ shim is visible to the
    % GUI-generated master.m scripts (they end with gui.returnFromCommandWindow).
    addpath(rootDir, "-end");

    % 2) Discover every <example>/master.m
    entries = dir(fullfile(rootDir, "*", "master.m"));
    n = numel(entries);
    fprintf("Found %d GUI examples to run.\n\n", n);

    folder     = strings(n, 1);
    status     = strings(n, 1);
    duration   = zeros(n, 1);
    identifier = strings(n, 1);
    message    = strings(n, 1);

    for k = 1 : n
        ex = entries(k);
        folder(k) = string(ex.folder);
        [~, relName] = fileparts(ex.folder);   % just the example folder name
        relName = string(relName);
        fprintf("[%d/%d] %s ... ", k, n, relName);

        t0 = tic;
        try
            cd(ex.folder);
            runMaster();                     % isolated workspace (master.m calls `clear`)
            status(k)   = "PASS";
            fprintf("PASS (%.1fs)\n", toc(t0));
        catch err
            status(k)     = "FAIL";
            identifier(k) = string(err.identifier);
            message(k)    = string(err.message);
            fprintf("FAIL — %s\n  %s\n", err.identifier, err.message);
        end
        duration(k) = toc(t0);
        cd(rootDir);
        close all;
    end

    results = table(folder, status, duration, identifier, message);

    fprintf("\n=== Summary ===\n");
    fprintf("PASS: %d / %d\n", sum(status == "PASS"), n);
    fprintf("FAIL: %d / %d\n", sum(status == "FAIL"), n);
end

function runMaster()
% Run the GUI-generated master.m in an isolated function workspace so that
% its leading `clear` does not wipe the caller's loop variables.
    evalc("master");
end
