
classdef Indexes < handle

    properties
        EndogenousNames (1, 1) struct = struct()
        EndogenousConcepts (1, 1) struct = struct()
        SeparableEndogenousNames (1, 1) struct = struct()
        ExogenousNames (1, 1) struct = struct()
        Units (1, 1) struct = struct()
        ShockNames (1, 1) struct = struct()
        ShockConcepts (1, 1) struct = struct()
        SeparableShockNames (1, 1) struct = struct()
        HistoryPeriods (1, 1) struct = struct()
    end


    methods
        function this = Indexes(meta)
            this.EndogenousNames = textual.createDictionary(meta.EndogenousNames);
            this.EndogenousConcepts = textual.createDictionary(meta.EndogenousConcepts);
            this.SeparableEndogenousNames = textual.createDictionary(meta.SeparableEndogenousNames);
            this.ExogenousNames = textual.createDictionary(meta.ExogenousNames);
            this.Units = textual.createDictionary(meta.Units);
            this.ShockNames = textual.createDictionary(meta.ShockNames);
            this.ShockConcepts = textual.createDictionary(meta.ShockConcepts);
            this.SeparableShockNames = textual.createDictionary(meta.SeparableShockNames);
            this.HistoryPeriods = textual.createDictionary(datex.toFieldable(meta.ShortSpan));
        end%
    end

end

