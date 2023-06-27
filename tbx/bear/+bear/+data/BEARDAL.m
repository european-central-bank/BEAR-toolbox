classdef (Abstract) BEARDAL < matlab.mixin.SetGet
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        NumEndo (1,1) double
        NumExo (1,1) double
    end

    methods
        function obj = BEARDAL(nvp)
            arguments
                nvp.NumEndo = 0
                nvp.NumExo  = 0
            end

            obj.NumEndo = nvp.NumEndo;
            obj.NumExo = nvp.NumExo;
        end
    end

    properties (Dependent)

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

    properties (Access = protected)

        ARPriors_internal          tabular = table.empty()
        BlockExo_internal          tabular = table.empty()
        Blocks_internal            tabular = table.empty()
        Conditions_internal        tabular = table.empty()
        Data_internal              tabular = table.empty()
        ExoMeanPriors_internal     tabular = table.empty()
        ExoTightPriors_internal    tabular = table.empty()
        FactorData_internal        tabular = table.empty()
        FEVDResValues_internal     tabular = table.empty()
        FEVDResPeriods_internal    tabular = table.empty()
        Grid_internal              tabular = table.empty()
        Intervals_internal         tabular = table.empty()
        IV_internal                tabular = table.empty()
        LongRunPrior_internal      tabular = table.empty()
        MeanAdjPrior_internal      tabular = table.empty()
        MFvarMonthly_internal      tabular = table.empty()
        MFvarQuarterly_internal    tabular = table.empty()
        MFvarTrans_internal        tabular = table.empty()
        PanelPredExo_internal      tabular = table.empty()
        PanelConditions_internal   tabular = table.empty()
        PanelShocks_internal       tabular = table.empty()
        PanelBlocks_internal       tabular = table.empty()
        PredExo_internal           tabular = table.empty()
        RelMagnResPeriods_internal tabular = table.empty()
        RelMagnResValues_internal  tabular = table.empty()
        Shocks_internal            tabular = table.empty()
        SignResValues_internal     tabular = table.empty()
        SignResPeriods_internal    tabular = table.empty()
        SurveyLocalMean_internal   tabular = table.empty()

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

    methods 
        function reload(obj)
            obj.ARPriors = table.empty();
            obj.BlockExo = table.empty();
            obj.Blocks = table.empty();
            obj.Conditions = table.empty();
            obj.Data = table.empty();
            obj.ExoMeanPriors = table.empty();
            obj.ExoTightPriors = table.empty();
            obj.FactorData = table.empty();
            obj.FEVDResValues = table.empty();
            obj.FEVDResPeriods = table.empty();
            obj.Grid = table.empty();
            obj.Intervals = table.empty();
            obj.IV = table.empty();
            obj.LongRunPrior = table.empty();
            obj.MeanAdjPrior = table.empty();
            obj.MFvarMonthly = table.empty();
            obj.MFvarQuarterly = table.empty();
            obj.MFvarTrans = table.empty();
            obj.PanelPredExo = table.empty();
            obj.PanelConditions = table.empty();
            obj.PanelShocks = table.empty();
            obj.PanelBlocks = table.empty();
            obj.PredExo = table.empty();
            obj.RelMagnResPeriods = table.empty();
            obj.RelMagnResValues = table.empty();
            obj.Shocks = table.empty();
            obj.SignResValues = table.empty();
            obj.SignResPeriods = table.empty();
            obj.SurveyLocalMean = table.empty();
        end
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

    methods % Getters

        function set.ARPriors(obj, value)
            set(obj, "ARPriors_internal", value);
        end

        function set.BlockExo(obj, value)
            set(obj,  "BlockExo_internal",value);
        end

        function set.Blocks(obj, value)
            set(obj,  "Blocks_internal", value);
        end

        function set.Conditions(obj, value)
            set(obj,  "Conditions_internal", value);
        end

        function set.Data(obj, value)
            set(obj,  "Data_internal", value);
        end

        function set.ExoMeanPriors(obj, value)
            set(obj,  "ExoMeanPriors_internal", value);
        end

        function set.ExoTightPriors(obj, value)
            set(obj,  "ExoTightPriors_internal", value);
        end

        function set.FactorData(obj, value)
            set(obj,  "FactorData_internal", value);
        end

        function set.FEVDResValues(obj, value)
            set(obj,  "FEVDResValues_internal", value);
        end

        function set.FEVDResPeriods(obj, value)
            set(obj,  "FEVDResPeriods_internal", value);
        end

        function set.Grid(obj, value)
            set(obj,  "Grid_internal",value);
        end

        function set.Intervals(obj, value)
            set(obj,  "Intervals_internal", value);
        end

        function set.IV(obj, value)
            set(obj,  "IV_internal", value);
        end

        function set.LongRunPrior(obj, value)
            set(obj,  "LongRunPrior_internal", value);
        end

        function set.MeanAdjPrior(obj, value)
            set(obj,  "MeanAdjPrior_internal", value);
        end

        function set.MFvarMonthly(obj, value)
            set(obj,  "MFvarMonthly_internal", value);
        end
        function set.MFvarQuarterly(obj, value)
            set(obj,  "MFvarQuarterly_internal", value);
        end

        function set.MFvarTrans(obj, value)
            set(obj,  "MFvarTrans_internal", value);
        end

        function set.PanelPredExo(obj, value)
            set(obj,  "PanelPredExo_internal", value);
        end

        function set.PanelConditions(obj, value)
            set(obj,  "PanelConditions_internal", value);
        end

        function set.PanelShocks(obj, value)
            set(obj,  "PanelShocks_internal", value);
        end

        function set.PanelBlocks(obj, value)
            set(obj,  "PanelBlocks_internal", value);
        end

        function set.PredExo(obj, value)
            set(obj,  "PredExo_internal", value);
        end

        function set.RelMagnResPeriods(obj, value)
            set(obj,  "RelMagnResPeriods_internal", value);
        end

        function set.RelMagnResValues(obj, value)
            set(obj,  "RelMagnResValues_internal", value);
        end

        function set.Shocks(obj, value)
            set(obj,  "Shocks_internal", value);
        end

        function set.SignResValues(obj, value)
            set(obj,  "SignResValues_internal", value);
        end

        function set.SignResPeriods(obj, value)
            set(obj,  "SignResPeriods_internal", value);
        end

        function set.SurveyLocalMean(obj, value)
            set(obj,  "SurveyLocalMean_internal", value);
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

