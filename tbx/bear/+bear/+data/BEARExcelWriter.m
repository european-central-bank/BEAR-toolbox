classdef BEARExcelWriter < bear.data.BEARFileExporter

    properties
        FileName
    end

    properties (Access = protected)
        IsDirty (1,1) logical = true
    end

    methods 

        function obj = BEARExcelWriter(fname)
            
            arguments
                fname string = fullfile(pwd, "results.xlsx")
            end

            obj.FileName = fname;                     
        end

        function set.FileName(obj,fname)

            arguments
                obj
                fname (1,1) string
            end

            [fpath, name, ext] = fileparts(fname);

            if fpath == ""
                fpath = pwd();
            end

            if ext == ""
                ext = ".xlsx";             
            end

            obj.FileName = fullfile(fpath, name + ext);
            obj.IsDirty = true; %#ok<MCSUP>

        end

        function  writeEstimationInfo(obj, data)
            obj.doWriteData(data, Sheet = 'estimation info', Range = 'C2')
        end

        function  writeActualFitted(obj, data)
            obj.doWriteData(data, Sheet = 'actual fitted', Range = 'B2')
        end

        function  writeResids(obj, data)
            obj.doWriteData(data, Sheet = 'resids', Range = 'B2')
        end

        function  writeSteadyState(obj, data)
            obj.doWriteData(data, Sheet = 'steady state', Range = 'B2')
        end

        function  writeIRF(obj, data)
            obj.doWriteData(data, Sheet = 'IRF', Range = 'B2')
        end

        function  writeForecasts(obj, data)
            obj.doWriteData(data, Sheet = 'forecasts', Range = 'B2')
        end

        function  writeFEVD(obj, data)
            obj.doWriteData(data, Sheet = 'FEVD', Range = 'B2')
        end

        function  writeHistDecomposition(obj, data)
            obj.doWriteData(data, Sheet = 'hist decomposition', Range = 'B2')
        end

        function  writeCondForecasts(obj, data)
            obj.doWriteData(data, Sheet = 'cond forecasts', Range = 'B2')
        end

        function  writeStruct_Shocks(obj, data)
            obj.doWriteData(data, Sheet = 'struct shocks', Range = 'B2')
        end

        function  writeHistDecomp(obj, data)
            obj.doWriteData(data, Sheet = 'hist decomp', Range = 'B2')
        end

        function  writeFavarIRF(obj, data)
            obj.doWriteData(data, Sheet = 'favar_IRF', Range = 'B2')
        end

        function  writeFavarFEVD(obj, data)
            obj.doWriteData(data, Sheet = 'favar_FEVD', Range = 'B2')
        end

        function  writeFavarHistDecomp(obj, data)
            obj.doWriteData(data, Sheet = 'favar_hist decomp', Range = 'B2')
        end

        function writeTimeVariation(obj, data)
            obj.doWriteData(data, Sheet = 'time variation', Range = 'B2')
        end

        function writeLocalMeanEstimates(obj, data)
            obj.doWriteData(data, Sheet = 'Local Mean Estimates', Range = 'B2')
        end

        function writeFavarIRFTimeVariation(obj, data)
            obj.doWriteData(data, Sheet = 'favar_IRF time variation', Range = 'B2')
        end

        function writePredExo(obj, data)
            obj.doWriteData(data, Sheet = 'pred exo', Range = 'A1')
        end

        function writeIRFTimeVariation(obj, data)
            obj.doWriteData(data, Sheet = 'IRF time variation', Range = 'B2')
        end

        function writeFEVDResValues(obj, data)
            obj.doWriteData(data, Sheet = 'FEVD res values', Range = 'B2')
        end

        function writeFEVDResPeriods(obj, data)
            obj.doWriteData(data, Sheet = 'FEVD res periods', Range = 'B2')
        end

        function writeBlockExogneity(obj, data)
            obj.doWriteData(data, Sheet = 'block exogeneity', Range = 'B2')
        end

        function writeCfConditions(obj, data)
            obj.doWriteData(data, Sheet = 'cf conditions', Range = 'B2')
        end

        function writeCfShocks(obj, data)
            obj.doWriteData(data, Sheet = 'cf shocks', Range = 'B2')
        end

        function writeCfBlocks(obj, data)
            obj.doWriteData(data, Sheet = 'cf blocks', Range = 'B2')
        end

        function writeCfIntervals(obj, data)
            obj.doWriteData(data, Sheet = 'cf intervals', Range = 'B2')
        end

        function writeGridSearch(obj, data)
            obj.doWriteData(data, Sheet = 'grid search', Range = 'C3')
        end

        function writeMeanAdjPrior(obj, data)
            obj.doWriteData(data, Sheet = 'mean-adj prior', Range = 'B2')
        end

        function writeRelmagnResValues(obj, data)
            obj.doWriteData(data, Sheet = 'relmagn res values', Range = 'B2')
        end

        function writeRelmagnResperiods(obj, data)
            obj.doWriteData(data, Sheet = 'relmagn res periods', Range = 'B2')
        end

        function writeSignResValues(obj, data)
            obj.doWriteData(data, Sheet = 'sign res values', Range = 'B2')
        end

        function writeSignResPeriods(obj, data)
            obj.doWriteData(data, Sheet = 'sign res periods', Range = 'B2')
        end

        function writeStrctshocks(obj, data)
            obj.doWriteData(data, Sheet = 'strctshocks', Range = 'B2')
        end

        function writeShocks(obj, data)
            obj.doWriteData(data, Sheet = 'shocks', Range = 'B2')
        end

        function writeStructShocks(obj, data)
            obj.doWriteData(data, Sheet = 'structshocks', Range = 'B2')
        end

        function writeCoeffsTimeVariation(obj, data)
            obj.doWriteData(data, Sheet = 'coeffs time variation', Range = 'B2')
        end

    end

    methods (Access = private)

        function doWriteData(obj, data, nvp)

            arguments
                obj
                data
                nvp.Sheet (1,1) string = []
                nvp.Range (1,1) string = []
            end

            if obj.IsDirty
                obj.initexcel();
                obj.IsDirty = false;
            end

            args = {};
            if ~isempty(nvp.Sheet)
                args = [args, 'Sheet', nvp.Sheet];
            end

            if ~isempty(nvp.Range)
                args = [args, 'Range', nvp.Range];
            end
            
            if istable(data)
                writetable(data, obj.FileName, args{:})
            elseif istimetable(data)
                writetimetable(data, obj.FileName, args{:})
            elseif iscell(data)
                writecell(data, obj.FileName, args{:})
            end

        end

        function initexcel(obj)

            resultsFile = obj.FileName;
            [results_path, ~, ~] = fileparts(obj.FileName);

            if exist(resultsFile, 'file') == 2
                delete(resultsFile);
            end

            % then copy the blank excel file from the files to the data folder
            sourcefile = fullfile(bearroot, 'bear','+bear','+data','results.xlsx');
            destinationfile = resultsFile;
            if exist(results_path, 'dir') == 0
                mkdir(results_path)
            end
            copyfile(sourcefile,destinationfile);

            obj.IsDirty = false;

        end

    end

end