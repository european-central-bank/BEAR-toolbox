classdef ExcelDAL < bear.data.BEARDAL

    properties
        InputFile
    end
    
    properties (Hidden, SetAccess = private)
        Sheets
    end

    methods

        function obj = ExcelDAL(fileName, varargin)

            obj@bear.data.BEARDAL(varargin{:});
            obj.InputFile = fileName;
            obj.Sheets = sheetnames(fileName);

        end

    end

    methods (Access = protected) % Read functions

        function data = readARPriors(obj)
            data = obj.doRead("AR Priors", "C3");
        end

        function data = readBlockExo(obj)
            data = obj.doRead("block exo", "B2", ExpectedNumVariables = obj.NumEndo + 1, VariableNamesRange = 'B2');
            data = rmmissing(data, 'MinNumMissing', width(data));
        end

        function data = readBlocks(obj)
            data = obj.doRead("blocks", "B2");
            data = makeTimeTable(data);
        end

        function data = readConditions(obj)
            data = obj.doRead("conditions", "B2", ExpectedNumVariables = obj.NumEndo + 1);
            data = makeTimeTable(data);
        end

        function data = readData(obj)
            data = obj.doRead("data", "A1");
            data = makeTimeTable(data);
        end

        function data = readExoMeanPriors(obj)
            data = obj.doRead("exo mean priors", "B3", ExpectedNumVariables = obj.NumExo + 2);
        end

        function data = readExoTightPriors(obj)
            data = obj.doRead("exo tight priors", "B3", ExpectedNumVariables = obj.NumExo + 2);
        end

        function data = readFactorData(obj)
            data = obj.doRead("factor data", "A3");
            data = makeTimeTable(data);
        end

        function data = readFEVDResValues(obj)
            data = obj.doRead("FEVD res values", "B3", ExpectedNumVariables = 1 + obj.NumEndo, VariableDescriptionsRange = 2);
        end

        function data = readFEVDResPeriods(obj)
            data = obj.doRead("FEVD res periods", "B3", ExpectedNumVariables = 1 + obj.NumEndo, VariableDescriptionsRange = 2);
        end

        function data = readGrid(obj)
            data = obj.doRead("grid", "B2", ExpectedNumVariables = 4);
            data.Properties.VariableNames = ["Hyperparameter", "Lower Bound", "Upper Bound", "Step"];
        end

        function data = readIntervals(obj)
            data = obj.doRead("intervals", "B2", ExpectedNumVariables = obj.NumEndo + 1);
            data = makeTimeTable(data);
        end

        function data = readIV(obj)
            data = obj.doRead("IV", "A1");
            data = makeTimeTable(data);
        end

        function data = readLongRunPrior(obj)
            data = obj.doRead("Long run prior", "B2", ExpectedNumVariables = obj.NumEndo + 1);
        end

        function data = readMeanAdjPrior(obj)
            data = obj.doRead("mean adj prior", "B2");
        end

        function data = readMFvarMonthly(obj)
            data = obj.doRead("mfvar_monthly", "A1");
            data = makeTimeTable(data);
        end

        function data = readMFvarQuarterly(obj)
            data = obj.doRead("mfvar_quarterly", "A1");
            data = makeTimeTable(data);
        end

        function data = readMFvarTrans(obj)
            data = obj.doRead("mf_var_trans", "B2");
        end

        function data = readPanelPredExo(obj)
            data = obj.doRead("pan pred exo", "B2", ExpectedNumVariables = obj.NumExo + 1);
            data = makeTimeTable(data);
        end

        function data = readPanelConditions(obj)
            data = obj.doRead("pan conditions", "B2");
            data = makeTimeTable(data);
        end

        function data = readPanelShocks(obj)
            data = obj.doRead("pan shocks", "B2");
            data = makeTimeTable(data);
        end

        function data = readPanelBlocks(obj)
            data = obj.doRead("pan blocks", "B2");
            data = makeTimeTable(data);
        end

        function data = readPredExo(obj)
            data = obj.doRead("pred exo", "B2", ExpectedNumVariables = 1 + obj.NumExo + obj.NumEndo);
            data = makeTimeTable(data);
        end

        function data = readRelMagnResPeriods(obj)
            data = obj.doRead("relmagn res periods", "B3", ExpectedNumVariables = 1+obj.NumEndo, VariableDescriptionsRange = 2);
        end

        function data = readRelMagnResValues(obj)
            data = obj.doRead("relmagn res values", "B3", ExpectedNumVariables = 1+obj.NumEndo, VariableDescriptionsRange = 2);
        end

        function data = readShocks(obj)
            data = obj.doRead("shocks", "B2",  ExpectedNumVariables = obj.NumEndo + 1);
            data = makeTimeTable(data);
        end

        function data = readSignResValues(obj)
            data = obj.doRead("sign res values", "B3", VariableDescriptionsRange = 2);
        end

        function data = readSignResPeriods(obj)
            data = obj.doRead("sign res periods", "B3",  VariableDescriptionsRange = 2);
        end

        function data = readSurveyLocalMean(obj)
            data = obj.doRead("Survey Local Mean", "A1");
            data = makeTimeTable(data);
        end

    end

    methods (Access = private)

        function data = doRead(obj, sheetname, range, varargin)
            if ismember(sheetname, obj.Sheets)
                data = readtable(obj.InputFile, varargin{:} ,FileType = "spreadsheet", Sheet=sheetname, Range = range, VariableNamingRule='preserve', TextType = 'string');
            else
                error('bear:data:ExcelDataAccessLayer', 'The excel file: \n  "%s" \nis missing the sheet %s', obj.InputFile, sheetname)
            end
        end

    end

end

function tt = makeTimeTable(tb)

    dates = tb{:,1};
    dates = bear.data.dateParser(dates);
    if isdatetime(dates)
        tt = table2timetable(tb(:,2:end), "RowTimes",  dates);
    else
        tb.Properties.VariableNames{1} = 'Time';
        tt = tb;
    end

end
