
classdef ExcelUX < handle

    properties (Constant)
        DATA_SOURCE_SHEET = "Data source"
        TASKS_SHEET = "Tasks"
        REDUCED_FORM_META_SHEET = "Reduced-form meta information"
        DUMMIES_SHEET = "Dummy observations"
        REDUCED_FORM_ESTIMATOR_SHEET = "Reduced-form estimation"
        STRUCTURAL_META_SHEET = "Structural meta information"

        CELL_READER_OPTIONS = {"Range", [1, 1], "TextType", "string", }

        INPUT_DATA_READER = struct( ...
            csv=@tablex.fromCsv ...
        );
    end


    properties
        FilePath (1, 1) string
        DataSource (:, :) cell
        Tasks (:, :) cell
        Meta (:, :) cell
        Estimator (:, :) cell
        Dummies (:, :) cell

        Config (1, 1) bear6.Config
        InputDataTable (:, :) timetable
    end


    methods

        function this = ExcelUX(options)
            arguments
                options.FilePath (1, 1) string = "BEAR6-EstimationUX.xlsx"
            end
            this.FilePath = options.FilePath;
            this.readAll();
            this.configureAll();
        end%


        function readInputData(this, varargin)
            arguments
                this
            end
            arguments (Repeating)
                varargin
            end
            config = this.Config;
            reader = this.INPUT_DATA_READER.(lower(config.DataSource_Format));
            this.InputDataTable = reader(config.DataSource_FilePath, varargin{:});
        end%

    end


    methods (Access=protected)

        function readAll(this)
            this.readDataSource();
            this.readTasks();
            this.readMeta();
            this.readEstimator();
            this.readDummies();
        end%


        function readDataSource(this)
            this.DataSource = readcell( ...
                this.FilePath ...
                , "sheet", this.DATA_SOURCE_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readTasks(this)
            this.Tasks = readcell( ...
                this.FilePath ...
                , "sheet", this.TASKS_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readMeta(this)
            this.Meta = readcell( ...
                this.FilePath ...
                , "sheet", this.META_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readDummies(this)
            this.Dummies = readcell( ...
                this.FilePath ...
                , "sheet", this.DUMMIES_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
        end%


        function readEstimator(this)
            x = readcell( ...
                this.FilePath ...
                , "sheet", this.REDUCED_FORM_ESTIMATOR_SHEET ...
                , this.CELL_READER_OPTIONS{:} ...
            );
            index = cellfun(@(x) isequal(x, true), x(2, :));
            if nnz(index) ~= 1
                error("Invalid selection of reduced-form estimation");
            end
            index = find(index, 1);
            this.Estimator = x(:, index-1:index);
        end%


        function readMeta(this)
        end%


        function configureAll(this)
            this.configureDataSource();
            this.configureTasks();
            this.configureReducedFormMeta();
            this.configureEstimator();
            this.configureMeta();
        end%


        function configureDataSource(this)
            this.Config.DataSource_Format = this.DataSource{2, 2};
            this.Config.DataSource_FilePath = this.DataSource{3, 2};
        end%


        function configureTasks(this)
            for row = 2 : height(this.Tasks)
                settingName = this.Tasks{row, 2};
                if ~isstring(settingName) || settingName == ""
                    continue
                end
                settingValue = this.Tasks(row, 3:end);
                this.Config.("Tasks_" + settingName) = settingValue;
            end
        end%


        function configureReducedFormMeta(this)
            x = this.Meta;
            this.Config.Meta_Units = stringListFromCellArray(x(2, 2:end), whenEmpty="");
            this.Config.Meta_EndogenousConcepts = stringListFromCellArray(x(3, 2:end));
            this.Config.Meta_ExogenousNames = stringListFromCellArray(x(4, 2:end));
            this.Config.Meta_HasIntercept = x{5, 2};
            this.Config.Meta_Order = x{6, 2};
            this.Config.Meta_EstimationStart = x{7, 2};
            this.Config.Meta_EstimationEnd = x{8, 2};
            this.Config.Meta_NumDraws = x{9, 2};
        end%


        function configureEstimator(this)
            this.Config.Estimator_Name = string(this.Estimator{3, 2});
            settings = cell.empty(1, 0);
            for row = 6 : height(this.Estimator)
                if ismissing(this.Estimator{row, 1})
                    continue
                end
                settingName = string(this.Estimator{row, 1});
                if strlength(settingName) == 0
                    continue
                end
                settingValue = this.Estimator{row, 2};
                settings = [settings, {settingName, settingValue}];
            end
            this.Config.Estimator_Settings = settings;
        end%


        function configureMeta(this)
            x = this.Meta;
            this.Config.Meta_ShockConcepts = stringListFromCellArray(x(2, 2:end));
            this.Config.Meta_IdentificationHorizon = x{3, 2};
        end%

    end

end


function output = stringListFromCellArray(input, options)
    arguments
        input (1, :) cell
        options.WhenEmpty (1, :) string = string.empty(1, 0)
    end
    isMissing = @(x) isempty(x) || ismissing(x) || (isstring(x) && strlength(x) == 0);
    indexMissing = cellfun(isMissing, input);
    input(indexMissing) = [];
    output = string(input);
    if isempty(output)
        output = options.WhenEmpty;
    end
end%


