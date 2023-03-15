classdef ExcelDAL

    properties
        file
    end

    properties (Dependent, Hidden)
        factor_data        
    end

    methods 

        function obj = ExcelDAL(ExcelFile)
            obj.file = ExcelFile;
        end

        function data = readFactorData(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="factor data", Range = 'A3');
        end

        function data = readData(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="data", Range = 'A1');
        end

        function data = readARPriors(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="AR priors");
        end

        function data = readExoMeanPriors(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="exo mean priors");
        end

        function data = readExoTightPriors(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="exo tight priors");
        end

        function data = readPredExo(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="pred exo");
        end

        function data = readMfavarMonthly(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="mfavar_monthly");
        end

        function data = readMfavarQuarterly(obj)
            data = readtable(obj.file, FileType = "spreadsheet", Sheet="mfavar_quarterly");
        end

    end
end
