
classdef Master < handle

    properties
        Config (1, 1) struct
        Logbook (1, 1) struct

        InputData (:, :) timetable
        EstimationSpan (1, :) datetime
        ReducedForm (1, :) model.ReducedForm = model.ReducedForm.empty(1, 0)
        Structural (1, :) model.Structural = model.Structural.empty(1, 0)
    end

    properties (Constant, Hidden)
    end

    methods
        function this = Master(config)
            arguments
                config (1, 1) struct
            end
            this.Config = config;
        end%

        function readInputData(this)
            this.InputData = bear6.readInputData(this.Config);
        end%

        function setDates(this)
            this.EstimationSpan = tablex.span(this.InputData);
        end%

        function createReducedForm(this)
        end%
    end

end
