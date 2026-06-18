
function code = codeContributions()

    TASK_FORM_PATH = {"tasks", "contributions"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("contributions");
    code = scripter.replaceInCode(code, place);

end%

