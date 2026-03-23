
classdef IneqRestrict ...
    < identifier.Verifiables

    methods
        function this = IneqRestrict(options)
            arguments
                options.FileName (1, :) string = ""
                options.MaxCandidates (1, 1) double {mustBePositive} = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.TryFlipSigns (1, 1) logical = identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
            end
            table = tablex.readIneqRestrict(options.FileName);
            this@identifier.Verifiables( ...
                IneqRestrictTable=table ...
                , MaxCandidates=options.MaxCandidates ...
                , TryFlipSigns=options.TryFlipSigns ...
            );
        end%
    end

end

