classdef ExcelDAL < bear.data.BEARDAL

    properties
        InputFile
    end
    
    properties (Hidden, SetAccess = private)
        Sheets
    end

    methods

        function obj = ExcelDAL(fileName)

            obj.InputFile = fileName;
            obj.Sheets = sheetnames(fileName);

        end

        function set.InputFile(obj, value)
            obj.InputFile = value;
            obj.Sheets = sheetnames(value); %#ok<MCSUP>
            obj.reload();
        end

    end

    methods (Access = protected) % Read functions

        function data = readARPriors(obj)
            data = obj.detectAndRead("AR Priors", VariableNamesRange = "B3", DataRange = "B4");
        end

        function data = readBlockExo(obj)
            data = obj.detectAndReadDoubleOnly("block exo", false, RowNamesRange = "B3", VariableNamesRange = "C2", DataRange = "C3");
        end

        function data = readBlocks(obj)
            data = obj.detectAndReadDoubleOnly("blocks", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readConditions(obj)
            data = obj.detectAndReadDoubleOnly("conditions", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readData(obj)
            data = obj.detectAndRead("data", VariableNamesRange = "A1", DataRange = "A2");
            data = makeTimeTable(data);
        end

        function data = readExoMeanPriors(obj)
            data = obj.detectAndRead("exo mean priors", VariableNamesRange = "B3", DataRange = "B4");
        end

        function data = readExoTightPriors(obj)
            data = obj.detectAndRead("exo tight priors", VariableNamesRange = "B3", DataRange = "B4");
        end

        function data = readFactorData(obj)
            data = obj.detectAndRead("factor data", VariableNamesRange = "A3", DataRange = "A4");
            data = makeTimeTable(data);
        end

        function data = readFactorDataTransform(obj)
            data = obj.detectAndRead("factor data", VariableNamesRange = "A3", DataRange = "1:1");
            data = data(:,2:end);
        end

        function data = readFactorDataBlocks(obj)
            data = obj.detectAndRead("factor data", VariableNamesRange = "A3", DataRange = "2:2");
            data = data(:,2:end);
        end

        function data = readFEVDResValues(obj)
            data = obj.detectAndRead("FEVD res values", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4", VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readFEVDResPeriods(obj)
            data = obj.detectAndRead("FEVD res periods", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4", VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readGrid(obj)
            data = obj.detectAndRead("grid", VariableNamesRange = "B2", DataRange = "B3", ExpectedNumVariables = 4);
            data.Properties.VariableNames = ["Hyperparameter", "Lower Bound", "Upper Bound", "Step"];
        end

        function data = readIntervals(obj)
            data = obj.detectAndRead("intervals", VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readIV(obj)
            data = obj.detectAndRead("IV", VariableNamesRange = "A1", DataRange = "A2");
            data = makeTimeTable(data);
        end

        function data = readLongRunPrior(obj)
            data = obj.detectAndRead("Long run prior", VariableNamesRange = "C2", DataRange = "C3", RowNamesRange = "B3");
        end

        function data = readMeanAdjPrior(obj)
            data = obj.detectAndRead("mean adj prior", VariableNamesRange = "C2", DataRange = "C3", RowNamesRange = "B3");
        end

        function data = readMFvarMonthly(obj)
            data = obj.detectAndRead("mfvar_monthly", VariableNamesRange = "A1", DataRange = "A2");
            data = makeTimeTable(data);
        end

        function data = readMFvarQuarterly(obj)
            data = obj.detectAndRead("mfvar_quarterly", VariableNamesRange = "A1", DataRange = "A2");
            data = makeTimeTable(data);
        end

        function data = readMFvarTrans(obj)
            data = obj.detectAndRead("mf_var_trans", VariableNamesRange = "B2", DataRange = "B3");
        end

        function data = readPanelPredExo(obj)
            data = obj.detectAndRead("pan pred exo", VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readPanelConditions(obj)
            data = obj.detectAndReadDoubleOnly("pan conditions", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readPanelShocks(obj)
            data = obj.detectAndReadDoubleOnly("pan shocks", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readPanelBlocks(obj)
            data = obj.detectAndReadDoubleOnly("pan blocks", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readPredExo(obj)
            data = obj.detectAndRead("pred exo", VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readRelMagnResPeriods(obj)
            data = obj.detectAndRead("relmagn res periods", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4", VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readRelMagnResValues(obj)
            data = obj.detectAndRead("relmagn res values", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4", VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readShocks(obj)
            data = obj.detectAndReadDoubleOnly("shocks", true, VariableNamesRange = "B2", DataRange = "B3");
            data = makeTimeTable(data);
        end

        function data = readSignResValues(obj)
            data = obj.detectAndReadStringOnly("sign res values", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4", VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readSignResPeriods(obj)
            data = obj.detectAndReadStringOnly("sign res periods", RowNamesRange = "B4", VariableNamesRange = "C3", DataRange = "C4",  VariableDescriptionsRange = "C2");
            data.Properties.DimensionNames = {'Row', 'Variables'};
        end

        function data = readSurveyLocalMean(obj)
            data = obj.detectAndRead("Survey Local Mean", VariableNamesRange = "A1", DataRange = "A2");
            data = makeTimeTable(data);
        end

    end

    methods (Access = private)

        function data = detectAndRead(obj, sheetname, varargin)
            if ismember(sheetname, obj.Sheets)
                opts = detectImportOptions(obj.InputFile, varargin{:}, FileType = "spreadsheet", Sheet=sheetname, TextType = 'string', VariableNamingRule='preserve');
                data = obj.doRead(opts);
                % data = readtable(obj.InputFile, varargin{:} ,, Range = range, , TextType = 'string');
            else
                error('bear:data:ExcelDataAccessLayer', 'The excel file: \n  "%s" \nis missing the sheet %s', obj.InputFile, sheetname)
            end
        end

        function data= detectAndReadStringOnly(obj, sheetname, varargin)

            if ismember(sheetname, obj.Sheets)
                opts = detectImportOptions(obj.InputFile, varargin{:}, FileType = "spreadsheet", Sheet=sheetname, TextType = 'string', VariableNamingRule='preserve');
                opts.VariableTypes = repmat({'string'}, size(opts.VariableTypes));
                data = obj.doRead(opts);
            else
                error('bear:data:ExcelDataAccessLayer', 'The excel file: \n  "%s" \nis missing the sheet %s', obj.InputFile, sheetname)
            end

        end

        function data= detectAndReadDoubleOnly(obj, sheetname, isTT, varargin)

            if ismember(sheetname, obj.Sheets)
                opts = detectImportOptions(obj.InputFile, varargin{:}, FileType = "spreadsheet", Sheet=sheetname, TextType = 'string', VariableNamingRule='preserve');
                if isTT %if is timetable only set double to the 2 end.
                    opts.VariableTypes(:,2:end) =  repmat({'double'}, [1, numel(opts.VariableTypes) - 1]);
                else
                    opts.VariableTypes = repmat({'double'}, size(opts.VariableTypes));
                end
                data = obj.doRead(opts);
            else
                error('bear:data:ExcelDataAccessLayer', 'The excel file: \n  "%s" \nis missing the sheet %s', obj.InputFile, sheetname)
            end

        end

        function data = doRead(obj, opts)

            try
                data = readtable(obj.InputFile, opts);
            catch e
                warning('bear:data:ExcelDal:UnableToRead', 'Unable to read %s with error %s.\nPlease check the Excel file', opts.Sheet, e.message)
                data = table.empty();
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
