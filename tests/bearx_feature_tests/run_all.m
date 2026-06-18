function summary = run_all(varargin)
%RUN_ALL  Run every BEARX feature test suite and report results.
%
%   summary = run_all()
%       Runs all 9 suites with default settings.
%
%   summary = run_all('only', "suite06")
%       Runs only the named suite (string or string array).
%
%   summary = run_all('numSamples', 100)
%       Overrides the number of posterior draws used in every suite.
%
%   summary = run_all('skip', ["suite04", "suite05"])
%       Skips the named suites (useful for FAVAR or specialised models that
%       are slow or known to require additional setup).

    p = inputParser;
    addParameter(p, "only", string([]));
    addParameter(p, "skip", string([]));
    addParameter(p, "numSamples", 50);
    parse(p, varargin{:});
    o = p.Results;

    suites = [
        "suite01_plainEstimators";
        "suite02_tvSvEstimators";
        "suite03_panelEstimators";
        "suite04_favarEstimators";
        "suite05_specialEstimators";
        "suite06_dummies";
        "suite07_identification";
        "suite08_tasks";
        "suite09_options";
    ];

    if ~isempty(o.only)
        keep = false(size(suites));
        for k = 1 : numel(o.only)
            keep = keep | startsWith(suites, o.only(k));
        end
        suites = suites(keep);
    end
    if ~isempty(o.skip)
        for k = 1 : numel(o.skip)
            suites(startsWith(suites, o.skip(k))) = [];
        end
    end

    fprintf("\n=== BEARX feature test run ===\n");
    fprintf("  numSamples: %d\n", o.numSamples);
    fprintf("  suites: %s\n\n", strjoin(suites, ", "));

    addpath(fileparts(mfilename("fullpath")));
    % Force MATLAB to drop cached function definitions so freshly-edited
    % suite files are picked up without restarting MATLAB.
    rehash path
    clear functions %#ok<CLFUNC>

    allRecords = struct([]);
    tStart = tic;
    for k = 1 : numel(suites)
        fprintf("--- %s ---\n", suites(k));
        try
            fn = str2func(suites(k));
            recs = fn("numSamples", o.numSamples);
            allRecords = [allRecords, recs]; %#ok<AGROW>
        catch err
            fprintf("  !! suite crashed: [%s] %s\n", err.identifier, err.message);
            crashRec = struct( ...
                "suite", suites(k), "case", "<suite_crashed>", ...
                "status", "FAIL", "identifier", string(err.identifier), ...
                "message", string(err.message), "elapsed_s", 0, ...
                "timestamp", string(datetime("now", "Format", "uuuu-MM-dd HH:mm:ss")));
            allRecords = [allRecords, crashRec]; %#ok<AGROW>
        end
    end
    fprintf("\nTotal elapsed: %.1f s\n", toc(tStart));

    summary = tutil_report(allRecords, fileparts(mfilename("fullpath")));
end
