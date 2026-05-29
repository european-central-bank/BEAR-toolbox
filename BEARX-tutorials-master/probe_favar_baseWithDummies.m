% probe_favar_baseWithDummies.m
% Diagnostic: does the current (unpatched) BEAR toolbox allow any
% instantiation of favar.Meta or baseWithDummies-dependent packages?
%
% Run from BEARX-tutorials-master with the BEAR toolbox on the path.
% No data file required.

clear
close all
rehash path

fprintf("\n========== PROBE: favar.Meta forwarding ==========\n");
try
    m = favar.Meta( ...
        endogenousConcepts=["A","B"], ...
        estimationSpan=datex.span(datex.m(2000,1), datex.m(2005,12)), ...
        order=2, ...
        intercept=true, ...
        reducibleNames=["X1","X2","X3"]);
    fprintf("  PASS: favar.Meta constructed. class = %s\n", class(m));
catch ME
    fprintf("  FAIL: %s\n", ME.message);
    if ~isempty(ME.stack)
        fprintf("    at %s (line %d)\n", ME.stack(1).name, ME.stack(1).line);
    end
end

fprintf("\n========== PROBE: minnesotaFAVARTwostep.Meta (real subclass) ==========\n");
try
    m = minnesotaFAVARTwostep.Meta( ...
        endogenousConcepts=["A","B"], ...
        estimationSpan=datex.span(datex.m(2000,1), datex.m(2005,12)), ...
        order=2, ...
        intercept=true, ...
        reducibleNames=["X1","X2","X3"]);
    fprintf("  PASS: minnesotaFAVARTwostep.Meta constructed. class = %s\n", class(m));
catch ME
    fprintf("  FAIL: %s\n", ME.message);
end

fprintf("\n========== PROBE: baseWithDummies package visibility ==========\n");
try
    w = what('+baseWithDummies');
    if isempty(w)
        fprintf("  baseWithDummies package: NOT visible to MATLAB\n");
    else
        fprintf("  baseWithDummies package: visible at %s\n", w(1).path);
    end
catch ME
    fprintf("  ERROR querying package: %s\n", ME.message);
end

fprintf("\n========== PROBE: minnesota.Meta (depends on baseWithDummies) ==========\n");
try
    m = minnesota.Meta( ...
        endogenousNames=["A","B"], ...
        estimationSpan=datex.span(datex.m(2000,1), datex.m(2005,12)), ...
        order=2, ...
        intercept=true);
    fprintf("  PASS: minnesota.Meta constructed. class = %s\n", class(m));
catch ME
    fprintf("  FAIL: %s\n", ME.message);
end

fprintf("\n========== PROBE: other baseWithDummies-dependent packages ==========\n");
for pkg = ["flat", "indNormalWishart", "ordinary"]
    try
        cls = meta.class.fromName(pkg + ".Meta");
        if isempty(cls)
            fprintf("  %-22s : Meta class NOT FOUND\n", pkg);
        else
            fprintf("  %-22s : Meta class found, superclass = %s\n", ...
                pkg, strjoin(string({cls.SuperclassList.Name}), ","));
        end
    catch ME
        fprintf("  %-22s : ERROR %s\n", pkg, ME.message);
    end
end

fprintf("\n========== DONE ==========\n");
