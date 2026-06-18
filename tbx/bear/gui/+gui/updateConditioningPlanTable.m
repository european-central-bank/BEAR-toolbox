
%
% updateConditioningPlanTable  Update the conditioning plan table
%
% Update the column names and periods in the conditioning plan table whenever
% Meta settings or Tasks/Conditional settings are submitted.
%

function updateConditioningPlanTable()

    FORM_PATH = {"tasks", "conditional"};
    TABLE_PATH = {"tables", "ConditioningPlan.xlsx"};
    TITLE = "Conditioning plan";

    % Retrieve the correct meta object with the current settings
    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;
    if isempty(endogenousNames) || isequal(endogenousNames, "")
        % disp("Not updating conditioning plan table because there are no endogenous names.");
        return
    end

    % Read the current tasks/conditional form
    form = gui.readFormsFile(FORM_PATH);
    if isempty(form.ForecastSpan.value) || isequal(form.ForecastSpan.value, "")
        % disp("Not updating conditioning plan table because forecast span is empty.");
        return
    end

    % Create forecast span from the form values
    forecastSpan = datex.span( ...
        form.ForecastSpan.value(1), ...
        form.ForecastSpan.value(end) ...
    );
    forecastSpanStrings = string(forecastSpan);

    gui.updateTableWhenNecessary( ...
        rowNames=forecastSpanStrings, ...
        columnNames=endogenousNames, ...
        fileName=string(fullfile(TABLE_PATH{:})), ...
        title=TITLE ...
    );

end%

