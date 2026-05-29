function run_tutorials_debug()
% Run all X*.m tutorials with verbose error reporting.
% Output is captured per tutorial, progress bars are stripped, and the
% cleaned-up log is written to:
%   test_Xtutorials_results.log  (in the tutorials folder)

    here = fileparts(mfilename('fullpath'));
    cd(here);

    logFile = fullfile(here, 'test_Xtutorials_results.log');
    if exist(logFile, 'file'); delete(logFile); end
    fid = fopen(logFile, 'w', 'n', 'UTF-8');
    assert(fid > 0, 'Cannot open log file %s', logFile);
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

    logf = @(s) localLog(fid, s);

    % ---------- BEAR path check ----------
    logf(sprintf('\n==================== BEAR PATH CHECK ====================\n'));
    logf(sprintf('Tutorials dir : %s\n', here));
    bearAppPath = which('BEARapp');
    if isempty(bearAppPath)
        bearAppPath = which('BEAR6');
    end
    allCopies = which('BEARapp', '-all');
    if isempty(allCopies); allCopies = which('BEAR6', '-all'); end
    logf(sprintf('which BEAR app : %s\n', bearAppPath));
    logf(sprintf('All copies on path :\n'));
    for k = 1:numel(allCopies)
        logf(sprintf('  %s\n', allCopies{k}));
    end
    if isempty(bearAppPath)
        logf(sprintf('!! BEAR app introuvable : ouvre BEARX-Toolbox.prj avant.\n'));
    elseif contains(bearAppPath, 'AppData', 'IgnoreCase', true)
        logf(sprintf('!! ATTENTION : BEAR utilise vient d''AppData (add-on), pas du source.\n'));
    else
        logf(sprintf('OK : BEAR source utilise = %s\n', fileparts(bearAppPath)));
    end
    logf(sprintf('=========================================================\n'));

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

    results = strings(numel(tutorials), 2);

    for i = 1:numel(tutorials)
        name = tutorials{i};
        header = sprintf('\n==================== [%d/%d] %s ====================\n', ...
            i, numel(tutorials), name);
        logf(header);

        cd(here);
        close all force;

        tStart = tic;
        captured = '';
        try
            captured = evalin('base', sprintf( ...
                'evalc(''clear; clear classes; run(''''%s'''')'')', ...
                fullfile(here, [name '.m'])));
            elapsed = toc(tStart);
            results(i,1) = name;
            results(i,2) = "OK";
            logf(stripProgress(captured));
            logf(sprintf('\n---- %s : OK (%.1fs) ----\n', name, elapsed));
        catch ME
            elapsed = toc(tStart);
            results(i,1) = name;
            results(i,2) = "FAIL: " + string(ME.message);
            if ~isempty(captured)
                logf(stripProgress(captured));
            end
            logf(sprintf('\n---- %s : FAIL (%.1fs) ----\n', name, elapsed));
            logf(sprintf('Identifier: %s\n', ME.identifier));
            logf(sprintf('Message   : %s\n', ME.message));
            logf(sprintf('Stack:\n'));
            for k = 1:numel(ME.stack)
                logf(sprintf('  %s (line %d) in %s\n', ...
                    ME.stack(k).name, ME.stack(k).line, ME.stack(k).file));
            end
        end
    end

    cd(here);
    logf(sprintf('\n\n==================== SUMMARY ====================\n'));
    for i = 1:size(results,1)
        logf(sprintf('%-40s : %s\n', results(i,1), results(i,2)));
    end
    nOK = sum(results(:,2) == "OK");
    logf(sprintf('\nTotal: %d OK / %d FAIL\n', nOK, numel(tutorials) - nOK));
    logf(sprintf('\nFull log saved to: %s\n', logFile));
end


function localLog(fid, s)
% Write to both console and log file.
    fprintf('%s', s);
    fprintf(fid, '%s', s);
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
