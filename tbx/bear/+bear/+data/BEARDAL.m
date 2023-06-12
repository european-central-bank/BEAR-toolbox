classdef (Abstract) BEARDAL < matlab.mixin.SetGet
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = private)
        NumEndo (1,1) double
        NumExo (1,1) double
    end

    methods
        function obj = BEARDAL(nvp)
            arguments
                nvp.NumEndo 
                nvp.NumExo
            end

            obj.NumEndo = nvp.NumEndo;
            obj.NumExo = nvp.NumExo;
        end
    end

    properties (Dependent, SetAccess = private)

        ARPriors
        BlockExo
        Blocks
        Conditions
        Data
        ExoMeanPriors
        ExoTightPriors
        FactorData
        FEVDResValues
        FEVDResPeriods
        Grid
        Intervals
        IV
        LongRunPrior
        MeanAdjPrior
        MFvarMonthly
        MFvarQuarterly
        MFvarTrans
        PanelPredExo
        PanelConditions
        PanelShocks
        PanelBlocks
        PredExo
        RelMagnResPeriods
        RelMagnResValues
        Shocks
        SignResValues
        SignResPeriods
        SurveyLocalMean

    end

    properties (Access = private)

        ARPriors_internal
        BlockExo_internal
        Blocks_internal
        Conditions_internal
        Data_internal
        ExoMeanPriors_internal
        ExoTightPriors_internal
        FactorData_internal
        FEVDResValues_internal
        FEVDResPeriods_internal
        Grid_internal
        Intervals_internal
        IV_internal
        LongRunPrior_internal
        MeanAdjPrior_internal
        MFvarMonthly_internal
        MFvarQuarterly_internal
        MFvarTrans_internal
        PanelPredExo_internal
        PanelConditions_internal
        PanelShocks_internal
        PanelBlocks_internal
        PredExo_internal
        RelMagnResPeriods_internal
        RelMagnResValues_internal
        Shocks_internal
        SignResValues_internal
        SignResPeriods_internal
        SurveyLocalMean_internal

    end

    methods (Abstract, Access = protected)
        data = readARPriors(obj)
        data = readBlockExo(obj)
        data = readBlocks(obj)
        data = readConditions(obj)
        data = readData(obj)
        data = readExoMeanPriors(obj)
        data = readExoTightPriors(obj)
        data = readFactorData(obj)
        data = readFEVDResValues(obj)
        data = readFEVDResPeriods(obj)
        data = readGrid(obj)
        data = readIntervals(obj)
        data = readIV(obj)
        data = readLongRunPrior(obj)
        data = readMeanAdjPrior(obj)
        data = readMFvarMonthly(obj)
        data = readMFvarQuarterly(obj)
        data = readMFvarTrans(obj)
        data = readPanelPredExo(obj)
        data = readPanelConditions(obj)
        data = readPanelShocks(obj)
        data = readPanelBlocks(obj)
        data = readPredExo(obj)
        data = readRelMagnResPeriods(obj)
        data = readRelMagnResValues(obj)
        data = readShocks(obj)
        data = readSignResValues(obj)
        data = readSignResPeriods(obj)
        data = readSurveyLocalMean(obj)
    end

    methods % Getters

        function value = get.ARPriors(obj)
            value = getData(obj, "ARPriors", @(x) readARPriors(x));
        end

        function value = get.BlockExo(obj)
            value = getData(obj, "BlockExo", @(x) readBlockExo(x));
        end

        function value = get.Blocks(obj)
            value = getData(obj, "Blocks", @(x) readBlocks(x));
        end

        function value = get.Conditions(obj)
            value = getData(obj, "Conditions", @(x) readConditions(x));
        end

        function value = get.Data(obj)
            value = getData(obj, "Data", @(x) readData(x));
        end

        function value = get.ExoMeanPriors(obj)
            value = getData(obj, "ExoMeanPriors", @(x) readExoMeanPriors(x));
        end

        function value = get.ExoTightPriors(obj)
            value = getData(obj, "ExoTightPriors", @(x) readExoTightPriors(x));
        end

        function value = get.FactorData(obj)
            value = getData(obj, "FactorData", @(x) readFactorData(x));
        end

        function value = get.FEVDResValues(obj)
            value = getData(obj, "FEVDResValues", @(x) readFEVDResValues(x));
        end

        function value = get.FEVDResPeriods(obj)
            value = getData(obj, "FEVDResPeriods", @(x) readFEVDResPeriods(x));
        end

        function value = get.Grid(obj)
            value = getData(obj, "Grid", @(x) readGrid(x));
        end

        function value = get.Intervals(obj)
            value = getData(obj, "Intervals", @(x) readIntervals(x));
        end

        function value = get.IV(obj)
            value = getData(obj, "IV", @(x) readIV(x));
        end

        function value = get.LongRunPrior(obj)
            value = getData(obj, "LongRunPrior", @(x) readLongRunPrior(x));
        end

        function value = get.MeanAdjPrior(obj)
            value = getData(obj, "MeanAdjPrior", @(x) readMeanAdjPrior(x));
        end

        function value = get.MFvarMonthly(obj)
            value = getData(obj, "MFvarMonthly", @(x) readMFvarMonthly(x));
        end
        function value = get.MFvarQuarterly(obj)
            value = getData(obj, "MFvarQuarterly", @(x) readMFvarQuarterly(x));
        end

        function value = get.MFvarTrans(obj)
            value = getData(obj, "MFvarTrans", @(x) readMFvarTrans(x));
        end

        function value = get.PanelPredExo(obj)
            value = getData(obj, "PanelPredExo", @(x) readPanelPredExo(x));
        end

        function value = get.PanelConditions(obj)
            value = getData(obj, "PanelConditions", @(x) readPanelConditions(x));
        end

        function value = get.PanelShocks(obj)
            value = getData(obj, "PanelShocks", @(x) readPanelShocks(x));
        end

        function value = get.PanelBlocks(obj)
            value = getData(obj, "PanelBlocks", @(x) readPanelBlocks(x));
        end

        function value = get.PredExo(obj)
            value = getData(obj, "PredExo", @(x) readPredExo(x));
        end

        function value = get.RelMagnResPeriods(obj)
            value = getData(obj, "RelMagnResPeriods", @(x) readRelMagnResPeriods(x));
        end

        function value = get.RelMagnResValues(obj)
            value = getData(obj, "RelMagnResValues", @(x) readRelMagnResValues(x));
        end

        function value = get.Shocks(obj)
            value = getData(obj, "Shocks", @(x) readShocks(x));
        end

        function value = get.SignResValues(obj)
            value = getData(obj, "SignResValues", @(x) readSignResValues(x));
        end

        function value = get.SignResPeriods(obj)
            value = getData(obj, "SignResPeriods", @(x) readSignResPeriods(x));
        end

        function value = get.SurveyLocalMean(obj)
            value = getData(obj, "SurveyLocalMean", @(x) readSurveyLocalMean(x));
        end

    end

    methods (Access = private)

        function value = getData(obj, prop, fcn)

            int_prop = prop + "_internal";

            value = obj.(int_prop);

            if isempty(value)

                value = fcn(obj);
                obj.(int_prop) = value;

            end

        end

    end

end

