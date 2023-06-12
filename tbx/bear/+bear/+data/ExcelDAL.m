classdef ExcelDAL < bear.data.BEARDAL

    properties
        File
    end
    
    properties (Hidden, SetAccess = private)
        Sheets
    end

    methods

        function obj = ExcelDAL(fileName, varargin)

            obj@bear.data.BEARDAL(varargin{:});
            obj.File = fileName;
            obj.Sheets = sheetnames(fileName);

        end

    end

    methods (Access = protected) % Read functions

        function data = readARPriors(obj)
            data = obj.doRead("AR Priors", "C3");
        end

        function data = readBlockExo(obj)
            data = obj.doRead("block exo", "B2", ExpectedNumVariables = obj.NumEndo + 1);
        end

        function data = readBlocks(obj)
            data = obj.doRead("blocks", "B2");
        end

        function data = readConditions(obj)
            data = obj.doRead("conditions", "B2", ExpectedNumVariables = obj.NumEndo + 1);
        end

        function data = readData(obj)
            data = obj.doRead("data", "A1");
        end

        function data = readExoMeanPriors(obj)
            data = obj.doRead("exo mean priors", "B3", ExpectedNumVariables = obj.NumExo + 2);
        end

        function data = readExoTightPriors(obj)
            data = obj.doRead("exo tight priors", "B3", ExpectedNumVariables = obj.NumExo + 2);
        end

        function data = readFactorData(obj)
            data = obj.doRead("factor data", "A3");
        end

        function data = readFEVDResValues(obj)
            data = obj.doRead("FEVD res values", "B3");
        end

        function data = readFEVDResPeriods(obj)
            data = obj.doRead("FEVD res periods", "B3");
        end

        function data = readGrid(obj)
            data = obj.doRead("grid", "B2", ExpectedNumVariables = 4);
        end

        function data = readIntervals(obj)
            data = obj.doRead("intervals", "B2", ExpectedNumVariables = obj.NumEndo + 1);
        end

        function data = readIV(obj)
            data = obj.doRead("IV", "A1");
        end

        function data = readLongRunPrior(obj)
            data = obj.doRead("Long run prior", "B2", ExpectedNumVariables = obj.NumEndo + 1);
        end

        function data = readMeanAdjPrior(obj)
            data = obj.doRead("mean adj prior", "B2");
        end

        function data = readMFvarMonthly(obj)
            data = obj.doRead("mfvar_monthly", "A1");
        end

        function data = readMFvarQuarterly(obj)
            data = obj.doRead("mfvar_quarterly", "A1");
        end

        function data = readMFvarTrans(obj)
            data = obj.doRead("mf_var_trans", "B2");
        end

        function data = readPanelPredExo(obj)
            data = obj.doRead("pan pred exo", "B2", ExpectedNumVariables = obj.NumExo + 2);
        end

        function data = readPanelConditions(obj)
            data = obj.doRead("pan conditions", "B2");
        end

        function data = readPanelShocks(obj)
            data = obj.doRead("pan shocks", "B2");
        end

        function data = readPanelBlocks(obj)
            data = obj.doRead("pan blocks", "B2");
        end

        function data = readPredExo(obj)
            data = obj.doRead("pred exo", "B2", ExpectedNumVariables = obj.NumExo + obj.NumEndo);
        end

        function data = readRelMagnResPeriods(obj)
            data = obj.doRead("relmagn res periods", "B3");
        end

        function data = readRelMagnResValues(obj)
            data = obj.doRead("relmagn res values", "B3");
        end

        function data = readShocks(obj)
            data = obj.doRead("shocks", "B2",  ExpectedNumVariables = obj.NumExo);
        end

        function data = readSignResValues(obj)
            data = obj.doRead("sign res values", "B3");
        end

        function data = readSignResPeriods(obj)
            data = obj.doRead("sign res periods", "B3");
        end

        function data = readSurveyLocalMean(obj)
            data = obj.doRead("Survey Local Mean", "A1");
        end

    end

    methods (Access = private)

        function data = doRead(obj, sheetname, range, varargin)
            if ismember(sheetname, obj.Sheets)
                data = readtable(obj.File, varargin{:} ,FileType = "spreadsheet", Sheet=sheetname, Range = range, VariableNamingRule='preserve', TextType = 'string');
            else
                error('bear:data:ExcelDataAccessLayer', 'The excel file: \n  "%s" \nis missing the sheet %s', obj.File, sheetname)
            end
        end

    end
end
