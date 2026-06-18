
function code = codeReducedFormForecast()

    TASK_FORM_PATH = {"tasks", "redForecast"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    general = gui.getGeneralSettings();
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place.FORECAST_SPAN = mts.span(taskSettings.ForecastSpan.value);
    place.STOCHASTIC_RESIDUALS = mts.logical(taskSettings.StochasticResiduals.value);
    place.NUM_HISTORY = mts.number(general.NumHistory.value);

    taskSettings.HasHistory.value = double(place.NUM_HISTORY) > 0;
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("reducedFormForecast");
    code = scripter.replaceInCode(code, place);

end%

