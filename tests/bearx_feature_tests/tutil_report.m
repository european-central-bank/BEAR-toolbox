function summary = tutil_report(records, outDir)
%TUTIL_REPORT  Print summary table and write results.json + results.log.

    if nargin < 2 || isempty(outDir)
        outDir = pwd;
    end

    if isempty(records)
        summary = struct("nPass", 0, "nFail", 0, "nSkip", 0, "bySuite", struct(), "failures", []);
        fprintf("\n=== TUTIL_REPORT: no records ===\n");
        return
    end

    statuses = arrayfun(@(r) r.status, records);
    nPass = sum(statuses == "PASS");
    nFail = sum(statuses == "FAIL");
    nSkip = sum(statuses == "SKIP");

    suites = unique(arrayfun(@(r) r.suite, records));
    bySuite = struct();
    for s = suites(:)'
        mask = arrayfun(@(r) r.suite, records) == s;
        bySuite.(matlab.lang.makeValidName(s)).nPass = sum(statuses(mask) == "PASS");
        bySuite.(matlab.lang.makeValidName(s)).nFail = sum(statuses(mask) == "FAIL");
        bySuite.(matlab.lang.makeValidName(s)).nSkip = sum(statuses(mask) == "SKIP");
        bySuite.(matlab.lang.makeValidName(s)).elapsed_s = sum(arrayfun(@(r) r.elapsed_s, records(mask)));
    end

    failures = records(statuses == "FAIL");

    summary = struct( ...
        "nPass", nPass, "nFail", nFail, "nSkip", nSkip, ...
        "bySuite", bySuite, "failures", failures, "all", records);

    fprintf("\n========================================================\n");
    fprintf("  BEARX feature test summary\n");
    fprintf("========================================================\n");
    fprintf("  total: %d   PASS: %d   FAIL: %d   SKIP: %d\n", numel(records), nPass, nFail, nSkip);
    fprintf("--------------------------------------------------------\n");
    for s = suites(:)'
        f = bySuite.(matlab.lang.makeValidName(s));
        fprintf("  %-32s P:%3d  F:%3d  S:%3d   (%.1fs)\n", s, f.nPass, f.nFail, f.nSkip, f.elapsed_s);
    end
    if nFail > 0
        fprintf("--------------------------------------------------------\n");
        fprintf("  Failures:\n");
        for k = 1 : numel(failures)
            r = failures(k);
            fprintf("    %s / %s  [%s]\n      %s\n", r.suite, r.case, r.identifier, r.message);
        end
    end
    fprintf("========================================================\n\n");

    % JSON
    try
        jsonPath = fullfile(outDir, "results.json");
        fid = fopen(jsonPath, "w");
        fwrite(fid, jsonencode(records, "PrettyPrint", true));
        fclose(fid);
        fprintf("  Wrote %s\n", jsonPath);
    catch err
        warning("tutil_report:jsonFailed", "Could not write JSON: %s", err.message);
    end

    % Log
    try
        logPath = fullfile(outDir, "results.log");
        fid = fopen(logPath, "w");
        for k = 1 : numel(records)
            r = records(k);
            if isfield(r, "tag") && r.tag ~= ""
                tagStr = "<" + r.tag + ">";
            else
                tagStr = "";
            end
            fprintf(fid, "%s  %-18s  %-44s  %-4s  %7.2fs  %-16s  %s\n", ...
                r.timestamp, r.suite, r.case, r.status, r.elapsed_s, tagStr, r.identifier);
        end
        fclose(fid);
        fprintf("  Wrote %s\n", logPath);
    catch err
        warning("tutil_report:logFailed", "Could not write log: %s", err.message);
    end
end
