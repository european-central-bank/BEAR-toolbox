
function code = assemble(options)

    arguments
        options.saveToFile (1, 1) string = ""
    end

    % Preparation and estimation

    isMixedFrequency = gui.isMixedFrequency();

    snippets = string.empty(0, 1);

    snippets = [snippets; scripter.codePreamble()];

    if gui.canHaveDummies()
        snippets = [snippets; scripter.codeDummies()];
    end

    snippets = [snippets; scripter.codeMeta()];

    snippets = [snippets; scripter.codeInputData()];

    if isMixedFrequency
        snippets = [snippets; scripter.codeLowFrequencyInputData()];
    end

    snippets = [snippets; scripter.codeDataHolder()];

    snippets = [snippets; scripter.codeReducedFormModel()];


    % Tasks

    tasks = gui.getCurrentTasks();

    if ismember("ReducedFormEstimation", tasks)
        snippets = [snippets; scripter.codeReducedFormEstimation()];
    end

    if ismember("StructuralEstimation", tasks)
        snippets = [snippets; scripter.codeIdentifier()];
        snippets = [snippets; scripter.codeStructuralEstimation()];
    end

    if ismember("ReducedFormForecast", tasks)
        snippets = [snippets; scripter.codeReducedFormForecast()];
    end

    % Historical shock contributions are needed either when requested by the
    % user or when contributions to the structural or conditional forecast are requested.
    needsShockContributions = ...
        ismember("ShockContributions", tasks) ...
        || hasStructuralForecastContributions(tasks) ...
        || hasConditionalForecastContributions(tasks);

    if needsShockContributions
        snippets = [snippets; scripter.calculateShockContributions()];
    end

    if ismember("ShockContributions", tasks)
        snippets = [snippets; scripter.reportShockContributions()];
    end

    if ismember("StructuralForecast", tasks)
        snippets = [snippets; scripter.structuralForecast()];
    end

    if hasStructuralForecastContributions(tasks)
        snippets = [snippets; scripter.structuralForecastContributions()];
    end

    if ismember("ConditionalForecast", tasks)
        snippets = [snippets; scripter.codeConditionalForecast()];
    end

    if ismember("ShockResponses", tasks)
        snippets = [snippets; scripter.codeShockResponses()];
    end

    if ismember("FEVD", tasks)
        snippets = [snippets; scripter.absoluteFevd()];
        snippets = [snippets; scripter.relativeFevd()];
    end

    snippets = [snippets; scripter.codeCompleted()];

    code = join(snippets, "");

    code = resolvePrinting_(code);

    if options.saveToFile ~= ""
        textual.write(code, options.saveToFile);
    end

end%


function code = resolvePrinting_(code)
    general = gui.getGeneralSettings();
    %
    if general.PrintInfo.value
        code = replace(code, "?PRINT_INFO?", "");
    else
        code = replace(code, "?PRINT_INFO?", "% ");
    end
    %
    if general.PrintTables.value
        code = replace(code, "?PRINT_TABLE?", "");
    else
        code = replace(code, "?PRINT_TABLE?", "% ");
    end
    %
    if general.PrintObjects.value
        code = replace(code, "?PRINT_OBJECT?", "");
    else
        code = replace(code, "?PRINT_OBJECT?", "% ");
    end
    %]
end%


function flag = hasStructuralForecastContributions(tasks)
    %[
    if ~ismember("StructuralForecast", tasks)
        flag = false;
        return
    end

    TASK_FORM_PATH = {"tasks", "structForecast"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    if ~logical(taskSettings.Contributions.value)
        flag = false;
        return
    end

    flag = true;
    %]
end%


function flag = hasConditionalForecastContributions(tasks)
    %[
    if ~ismember("ConditionalForecast", tasks)
        flag = false;
        return
    end

    TASK_FORM_PATH = {"tasks", "conditional"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    if ~logical(taskSettings.Contributions.value)
        flag = false;
        return
    end

    flag = true;
    %]
end%

