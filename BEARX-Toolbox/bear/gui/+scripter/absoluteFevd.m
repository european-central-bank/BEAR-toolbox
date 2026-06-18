
function code = absoluteFevd()

    TASK_FORM_PATH = {"tasks", "fevd"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);
    mts = gui.MatlabToScript();

    % Parts of the code
    place = struct();
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("absoluteFevd");
    code = scripter.replaceInCode(code, place);

end%

