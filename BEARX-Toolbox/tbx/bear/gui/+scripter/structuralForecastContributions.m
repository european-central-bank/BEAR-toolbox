
function code = structuralForecastContributions()

    TASK_FORM_PATH = {"tasks", "structForecast"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    general = gui.getGeneralSettings();
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place.NUM_HISTORY = mts.number(general.NumHistory.value);

    taskSettings.HasHistory.value = double(place.NUM_HISTORY) > 0;
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("structuralForecastContributions");
    code = scripter.replaceInCode(code, place);

end%

