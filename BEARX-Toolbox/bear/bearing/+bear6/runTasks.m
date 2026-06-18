
function results = runTasks(config, modelS, logger)

    taskNames = string.empty(1, 0);
    for n = reshape(string(fieldnames(config)), 1, [])
        if startsWith(n, "Tasks_")
            taskNames(end+1) = n;
        end
    end

    results = struct();

    for n = taskNames
        if ~config.(n){1}
            continue
        end
        logger.info("Running " + n);
        results = feval(n, results, config.(n), modelS);
    end

end%


function saveCompressedTable(table, filePath, compressFunc)
    portable = tablex.toPortable(table, compressFunc);
    writetimetable(portable, filePath);
end%


function results = Tasks_Percentiles(results, config, ~)
    results.Percentiles = reshape(double(split(string(config{2}), " ")), 1, []);
    results.PercentileFunc = @(x) prctile(x, results.Percentiles, 2);
end%


function results = Tasks_ParameterTables(results, config, modelS)
end%


function results = Tasks_AsymptoticMeanTables(results, config, modelS)
end%


function results = Tasks_ResidualEstimates(results, config, modelS)
    filePath = config{2};
    results.ResidualEstimates = modelS.calculateResiduals();
    saveCompressedTable(results.ResidualEstimates, filePath, results.PercentileFunc);
end%


function results = Tasks_UnconditionalForecast(results, config, modelS)
    [filePath, forecastStart, forecastEnd] = config{2:4};
    forecastStart = datex.fromSdmx(forecastStart);
    forecastEnd = datex.fromSdmx(forecastEnd);
    forecastSpan = datex.span(forecastStart, forecastEnd);
    results.UnconditionalForecast = modelS.forecast(forecastSpan);
    saveCompressedTable(results.UnconditionalForecast, config{2}, results.PercentileFunc);
end%


function results = Tasks_ShockEstimates(results, config, modelS)
    filePath = config{2};
    results.ShockEstimates = modelS.calculateShocks();
    saveCompressedTable(results.ShockEstimates, filePath, results.PercentileFunc);
end%


function results = Tasks_ShockResponses(results, config, modelS)
    filePath = config{2};
    results.ShockResponses = modelS.simulateResponses();
    saveCompressedTable(results.ShockResponses, filePath, results.PercentileFunc);
end%


function results = Tasks_ConditionalForecast(results, config, modelS)
    [filePath, forecastStart, forecastEnd] = config{2:4};
    forecastStart = datex.fromSdmx(forecastStart);
    forecastEnd = datex.fromSdmx(forecastEnd);
    forecastSpan = datex.span(forecastStart, forecastEnd);
    results.ConditionalForecast = modelS.forecast(forecastSpan);
    saveCompressedTable(results.ConditionalForecast, config{2}, results.PercentileFunc);
end%


function results = Tasks_SaveResults(results, config, modelS)
    filePath = config{2};
    save(filePath, "-struct", "results");
end%


function results = Tasks_SaveConfig(results, config, modelS)
    filePath = config{2};
    json.write(config, filePath);
end%

