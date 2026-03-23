
function out = markdownEstimatorSettings()
    % clear cache of all classes
    clear classes

    currentFile = which('docgen.markdownEstimatorSettings');
    rootDir = fileparts(fileparts(fileparts(fileparts(currentFile))));

    estimatorSettings = docgen.getEstimatorSettings();

    pages = [
        "basic_bvar",...
        "stochastic_volatility",...
        "panel",...
        "favar",...
        "time_varying",...
        "mixed_freq",...
        "large_scale"...
    ];

    pageTitles = [
        "Basic BVAR",...
        "Stochastic volatility",...
        "Panel",...
        "FAVAR",...
        "Time-varying BVAR",...
        "Mixed frequency BVAR",...
        "Large scale BVAR"...
    ];

    for page_ind = 1:numel(pages)
        pageName = pages(page_ind);
        PATH = fullfile(rootDir, "mkdocs_estimator", "docs", pageName+".md");
        lines = string.empty(0, 1);
        lines = [
            lines
            "# " + pageTitles(page_ind) + " estimators"
            ""
            "Estimators in alphabetical order"
            ""
        ];

        estimatorNames = textual.stringify(fieldnames(estimatorSettings.(pageName)));
        estimatorNames = sort(estimatorNames);
        for i = 1 : numel(estimatorNames)
            estimator = estimatorSettings.(pageName).(estimatorNames(i));
            lines(end+1) = "";
            lines(end+1) = "";
            lines(end+1) = "## `" + estimatorNames(i) + "` ";
            lines(end+1) = "";
            lines(end+1) = estimator.description;
            lines(end+1) = "";
            lines(end+1) = estimator.detailedDesc;
            lines(end+1) = "";
            lines(end+1) = "### Settings ";
            lines(end+1) = "Name | Description | Default value | Type | BEAR5 reference";
            % lines(end+1) = "------|-----------|-";
            lines(end+1) = "---|----|----|---|---";
            settings = estimator.settings;
            settingNames = textual.stringify(fieldnames(settings));
            settingNames = sort(settingNames);
            for j = 1 : numel(settingNames)
                settingName = settingNames(j);
                setting = settings.(settingName);
                try
                lines(end+1) = sprintf("`%s` | %s| %s| %s| %s", settingName, printSetting(setting.description), printSetting(setting.default), printSetting(setting.type), printSetting(setting.detailedDesc));
                catch
                    keyboard
                end
            end
        end

        lines(end+1) = "";
        out = join(lines, newline());

        writematrix(out, PATH, fileType="text", quoteStrings=false);
    end

end%


function out = printSetting(value)
    % if ~(isstring(value) || ischar(value))
    %     out = """" + string(value) + """";
    %     % out = string(value);
    %     return
    % end
    out = string(value);
end%

