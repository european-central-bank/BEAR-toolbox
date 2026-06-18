
function gui_selectInputDataFile(field)

    % Read the existing form
    FORM_PATH = {"data", "source"};
    jsonForm = gui.readFormsFile(FORM_PATH);

    FILTER = ["*.csv"; "*.xls"; "*.xlsx"; "*.mat"];
    PROMPT = "Select input data file";

    [inputDataFileName, inputDataFilePath] = uigetfile(FILTER, PROMPT);
    if isequal(inputDataFileName, 0) || isequal(inputDataFilePath, 0)
        return
    end

    % Construct the full file path
    filePath = string(fullfile(inputDataFilePath, inputDataFileName));

    % Try to make the path relative to the current folder
    currentFolder = pwd();
    filePath = replace(filePath, currentFolder, ".");

    submission = struct();
    submission.(field) = filePath;
    jsonForm = gui.updateValuesFromSubmission(jsonForm, submission);

    % Write the updated form back to the JSON file
    gui.writeFormsFile(jsonForm, FORM_PATH);

    targetPage = gui.populateDataSourceHTML();
    gui.web(targetPage);

end%

