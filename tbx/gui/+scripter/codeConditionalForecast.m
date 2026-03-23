
function code = codeConditionalForecast()

    TASK_FORM_PATH = {"tasks", "conditional"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place.FORECAST_SPAN = mts.span(taskSettings.ForecastSpan.value);
    place.CONTRIBUTIONS = mts.logical(taskSettings.Contributions.value);
    place.INCLUDE_INITIAL = mts.logical(taskSettings.IncludeInitial.value);

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

    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("conditionalForecast");
    code = scripter.replaceInCode(code, place);

end%

