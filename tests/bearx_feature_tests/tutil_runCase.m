function rec = tutil_runCase(suiteName, caseName, fn, tag)
%TUTIL_RUNCASE  Run a single test case with try/catch + timing.
%
%   rec = tutil_runCase(suiteName, caseName, fn)
%   rec = tutil_runCase(suiteName, caseName, fn, tag)
%
%   fn is a function handle taking no args. Any error is caught and stored
%   with its MATLAB identifier; the case is marked FAIL. If fn returns
%   without error, the case is PASS.
%
%   tag (optional string) is a free-form annotation shown next to the
%   status, written to results.log, and stored in results.json.
%   Conventional tags:
%       "NOT IN GUI"       feature exists in the toolbox but is not exposed
%                          by the BEARX GUI
%       "BEAR BUG"         genuine upstream BEAR-build bug
%       "DATA-SPECIFIC"    test skipped because synthetic data does not
%                          match the estimator's requirements
%
%   To explicitly SKIP a case from inside fn, throw an MException with
%   identifier "bearx:test:skip".
%
%   The struct returned has fields:
%       suite, case, status ("PASS"|"FAIL"|"SKIP"), tag, identifier,
%       message, elapsed_s, timestamp

    if nargin < 4 || isempty(tag)
        tag = "";
    end

    t0 = tic;
    rec = struct();
    rec.suite      = string(suiteName);
    rec.case       = string(caseName);
    rec.status     = "FAIL";
    rec.tag        = string(tag);
    rec.identifier = "";
    rec.message    = "";
    rec.elapsed_s  = 0;
    rec.timestamp  = string(datetime("now", "Format", "uuuu-MM-dd HH:mm:ss"));

    fprintf("  [%-18s] %-44s ", suiteName, caseName);
    try
        fn();
        rec.status = "PASS";
    catch err
        rec.identifier = string(err.identifier);
        rec.message    = string(err.message);
        if rec.identifier == "bearx:test:skip"
            rec.status = "SKIP";
        end
    end
    rec.elapsed_s = toc(t0);

    switch rec.status
        case "PASS", statusTag = "PASS";
        case "SKIP", statusTag = "SKIP";
        otherwise,   statusTag = "FAIL";
    end
    fprintf("%s  (%.2fs)", statusTag, rec.elapsed_s);
    if rec.tag ~= ""
        fprintf("  <%s>", rec.tag);
    end
    if rec.status == "FAIL"
        fprintf("  [%s] %s", rec.identifier, rec.message);
    elseif rec.status == "SKIP"
        fprintf("  -- %s", rec.message);
    end
    fprintf("\n");
end
