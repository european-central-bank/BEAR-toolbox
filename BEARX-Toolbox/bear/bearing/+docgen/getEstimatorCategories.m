

function out = getEstimatorCategories()

    settingsDir = docgen.getDirectory("estimator.settings.Tracer");
    files = dir(fullfile(settingsDir, "*.m"));

    out = struct();
    for i = 1 : numel(files)
        fileName = string(files(i).name);
        estimatorClassName = extractBefore(files(i).name, ".m");
        try
            estimatorObject = estimator.(estimatorClassName);
        catch
            continue
        end
        out.(estimatorClassName) = string(estimatorObject.Category);
    end

end%


