
classdef (CaseInsensitiveProperties=true) Config < handle

    properties
        DataSource_Format (1, 1) string
        DataSource_FilePath (1, 1) string

        Tasks_Percentiles (1, :) cell
        Tasks_ParameterTables (1, :) cell
        Tasks_AsymptoticMeanTables (1, :) cell
        Tasks_ResidualEstimates (1, :) cell
        Tasks_UnconditionalForecast (1, :) cell
        Tasks_ShockEstimates (1, :) cell
        Tasks_ShockResponses (1, :) cell
        Tasks_ConditionalForecast (1, :) cell
        Tasks_SaveResults (1, :) cell
        Tasks_SaveConfig (1, :) cell

        Meta_Units (1, :) string {mustBeNonempty} = ""
        Meta_EndogenousConcepts (1, :) string {mustBeNonempty} = ""
        Meta_ExogenousNames (1, :) string
        Meta_HasIntercept (1, 1) logical
        Meta_Order (1, 1) double {mustBeInteger, mustBePositive} = 1
        Meta_EstimationStart (1, 1) string
        Meta_EstimationEnd (1, 1) string
        Meta_NumDraws (1, 1) double {mustBeInteger, mustBePositive} = 1000

        Meta_ShockConcepts (1, :) string
        Meta_IdentificationHorizon (1, 1) double {mustBeInteger, mustBeNonnegative} = 1

        Estimator_Name (1, 1) string
        Estimator_Settings (1, :) cell
    end


    properties (Dependent)
        Meta_EstimationSpan
    end


    methods
        function this = Config(varargin)
            if nargin == 1 && isstruct(varargin{1})
                names = fieldnames(varargin{1});
                values = struct2cell(varargin{1});
            else
                names = varargin(1:2:end);
                values = varargin(2:2:end);
            end
            for i = 1 : numel(names)
                this.(names{i}) = values{i};
            end
        end%


        function out = get.Meta_EstimationSpan(this)
            startPeriod = datex.fromSdmx(this.Meta_EstimationStart);
            endPeriod = datex.fromSdmx(this.Meta_EstimationEnd);
            out = datex.span(startPeriod, endPeriod);
        end%
    end

end

