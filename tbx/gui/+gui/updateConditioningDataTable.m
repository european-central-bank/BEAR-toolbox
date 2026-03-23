
%
% updateConditioningDataTable  Update the conditioning data table
%
% Update the column names and periods in the conditioning data table whenever
% Meta settings or Tasks/Conditional settings are submitted.
%

function updateConditioningDataTable()

    FORM_PATH = {"tasks", "conditional"};
    TABLE_PATH = {"tables", "ConditioningData.xlsx"};
    TITLE = "Conditioning data";

    % Retrieve the correct meta object with the current settings
    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;
    exogenousNames = meta.ExogenousNames;
    if isempty(endogenousNames) || isequal(endogenousNames, "")
        % disp("Not updating conditioning data table because there are no endogenous names.");
        return
    end
    columnNames = [endogenousNames, exogenousNames];

    % Read the current tasks/conditional form
    form = gui.readFormsFile(FORM_PATH);
    if isempty(form.ForecastSpan.value) || isequal(form.ForecastSpan.value, "")
        % disp("Not updating conditioning data table because forecast span is empty.");
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
        columnNames=columnNames, ...
        fileName=string(fullfile(TABLE_PATH{:})), ...
        title=TITLE ...
    );

end%

