classdef BEARExcelWriter < bear.data.BEARExporter

    properties
        FileName
    end

    methods 

        function obj = BEARExcelWriter(fname)
            
            arguments
                fname (1,1) string
            end

            obj.FileName = fname;                     
        end

        function  writeEstimationInfo(obj, data)
            obj.doWriteData(data, sheet = 'estimation info', range = 'C2')
        end

        function  writeActualFitted(obj, data)
            obj.doWriteData(data, sheet = 'actual fitted', range = 'B2')
        end

        function  writeResids(obj, data)
            obj.doWriteData(data, sheet = 'resids', range = 'B2')
        end

        function  writeSteadyState(obj, data)
            obj.doWriteData(data, sheet = 'steady state', range = 'B2')
        end

        function  writeIRF(obj, data)
            obj.doWriteData(data, sheet = 'IRF', range = 'B2')
        end

        function  writeForecasts(obj, data)
            obj.doWriteData(data, sheet = 'forecasts', range = 'B2')
        end

        function  writeFEVD(obj, data)
            obj.doWriteData(data, sheet = 'FEVD', range = 'B2')
        end

        function  writeHistDecomposition(obj, data)
            obj.doWriteData(data, sheet = 'hist decomposition', range = 'B2')
        end

        function  writeCondForecasts(obj, data)
            obj.doWriteData(data, sheet = 'cond forecasts', range = 'B2')
        end

        function  writeStruct_Shocks(obj, data)
            obj.doWriteData(data, sheet = 'struct shocks', range = 'B2')
        end

        function  writeHistDecomp(obj, data)
            obj.doWriteData(data, sheet = 'hist decomp', range = 'B2')
        end

        function  writeFavarIRF(obj, data)
            obj.doWriteData(data, sheet = 'favar_IRF', range = 'B2')
        end

        function  writeFavarFEVD(obj, data)
            obj.doWriteData(data, sheet = 'favar_FEVD', range = 'B2')
        end

        function  writeFavarHistDecomp(obj, data)
            obj.doWriteData(data, sheet = 'favar_hist decomp', range = 'B2')
        end

        function writeTimeVariation(obj, data)
            obj.doWriteData(data, sheet = 'time variation', range = 'B2')
        end

        function writeLocalMeanEstimates(obj, data)
            obj.doWriteData(data, sheet = 'Local Mean Estimates', range = 'B2')
        end

        function writeFavarIRFTimeVariation(obj, data)
            obj.doWriteData(data, sheet = 'favar_IRF time variation', range = 'B2')
        end

        function writePredExo(obj, data)
            obj.doWriteData(data, sheet = 'pred exo', range = 'A1')
        end

        function writeIRFTimeVariation(obj, data)
            obj.doWriteData(data, sheet = 'IRF time variation', range = 'B2')
        end

        function writeFEVDResValues(obj, data)
            obj.doWriteData(data, sheet = 'FEVD res values', range = 'B2')
        end

        function writeFEVDResPeriods(obj, data)
            obj.doWriteData(data, sheet = 'FEVD res periods', range = 'B2')
        end

        function writeBlockExogneity(obj, data)
            obj.doWriteData(data, sheet = 'block exogeneity', range = 'B2')
        end

        function writeCfConditions(obj, data)
            obj.doWriteData(data, sheet = 'cf conditions', range = 'B2')
        end

        function writeCfShocks(obj, data)
            obj.doWriteData(data, sheet = 'cf shocks', range = 'B2')
        end

        function writeCfBlocks(obj, data)
            obj.doWriteData(data, sheet = 'cf blocks', range = 'B2')
        end

        function writeCfIntervals(obj, data)
            obj.doWriteData(data, sheet = 'cf intervals', range = 'B2')
        end

        function writeGridSearch(obj, data)
            obj.doWriteData(data, sheet = 'grid search', range = 'C3')
        end

        function writeMeanAdjPrior(obj, data)
            obj.doWriteData(data, sheet = 'mean-adj prior', range = 'B2')
        end

        function writeRelmagnResValues(obj, data)
            obj.doWriteData(data, sheet = 'relmagn res values', range = 'B2')
        end

        function writeRelmagnResperiods(obj, data)
            obj.doWriteData(data, sheet = 'relmagn res periods', range = 'B2')
        end

        function writeSignResValues(obj, data)
            obj.doWriteData(data, sheet = 'sign res values', range = 'B2')
        end

        function writeSignResPeriods(obj, data)
            obj.doWriteData(data, sheet = 'sign res periods', range = 'B2')
        end

        function writeStrctshocks(obj, data)
            obj.doWriteData(data, sheet = 'strctshocks', range = 'B2')
        end

        function writeShocks(obj, data)
            obj.doWriteData(data, sheet = 'shocks', range = 'B2')
        end

        function writeStructShocks(obj, data)
            obj.doWriteData(data, sheet = 'structshocks', range = 'B2')
        end

        function writeCoeffsTimeVariation(obj, data)
            obj.doWriteData(data, sheet = 'coeffs time variation', range = 'B2')
        end

    end

    methods (Access = private)

        function doWriteData(obj, data, nvp)

            arguments
                obj
                data tabular
                nvp.sheet (1,1) string = []
                nvp.range (1,1) string = []
            end

            args = {};
            if ~isempty(nvp.sheet)
                args = [args, 'sheet', nvp.sheet];
            end

            if ~isempty(nvp.range)
                args = [args, 'range', nvp.range];
            end
            
            writetable(data, obj.FileName, args{:})

        end

    end

end