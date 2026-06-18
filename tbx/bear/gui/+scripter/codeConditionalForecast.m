
function code = codeConditionalForecast()

    TASK_FORM_PATH = {"tasks", "conditional"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    general = gui.getGeneralSettings();
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place.FORECAST_SPAN = mts.span(taskSettings.ForecastSpan.value);
    place.CONTRIBUTIONS = mts.logical(taskSettings.Contributions.value);
    place.NUM_HISTORY = mts.number(general.NumHistory.value);


    % Conditioning plan or across-the-board shocks
    if taskSettings.UsePlan.value
        planCode = "conditionalForecastPlan";
    else
        planCode = "conditionalForecastNoPlan";
    end
    place.PLAN = scripter.readTemplate(planCode);

    % Where to take exogenous data from
    if taskSettings.ExogenousFromConditions.value
        place.EXOGENOUS_FROM = "conditions";
    else
        place.EXOGENOUS_FROM = "inputData";
    end

    taskSettings.HasHistory.value = double(place.NUM_HISTORY) > 0;
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("conditionalForecast");
    code = scripter.replaceInCode(code, place);

end%

