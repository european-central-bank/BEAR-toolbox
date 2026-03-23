
function code = codeStructuralForecast()

    TASK_FORM_PATH = {"tasks", "structForecast"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place = struct();
    place.FORECAST_SPAN = mts.span(taskSettings.ForecastSpan.value);
    place.STOCHASTIC_RESIDUALS = mts.logical(taskSettings.StochasticResiduals.value);
    place.INCLUDE_INITIAL = mts.logical(taskSettings.IncludeInitial.value);
    place.CONTRIBUTIONS = mts.logical(taskSettings.Contributions.value);

    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("structuralForecast");
    code = scripter.replaceInCode(code, place);

end%

