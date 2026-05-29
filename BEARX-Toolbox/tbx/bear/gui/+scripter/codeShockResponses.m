
function code = codeShockResponses()

    TASK_FORM_PATH = {"tasks", "responses"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    place = struct();
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("shockResponses");
    code = scripter.replaceInCode(code, place);

end%

