
classdef (CaseInsensitiveProperties=true) LargeShockSV ...
    < base.estimator.settings.GenLargeShockSV

    properties
        Solver = @defaultSolver
    end

end


function y = defaultSolver(targetFunc, init)
    optimopts = optimset( ...
        optimset("fminsearch"), ...
        "display", "iter", ...
        "tolX", 1e-16, ...
        "tolFun", 1e-16 ...
    );
    y = fminsearch(targetFunc, init, optimopts);
end%

