
function code = codeReducedFormEstimation()

    TASK_FORM_PATH = {"tasks", "estimation"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);

    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place.NUM_SAMPLES = mts.number(taskSettings.NumSamples.value);

    % Create the code from the template
    code = scripter.readTemplate("reducedFormEstimation");
    code = scripter.replaceInCode(code, place);

end%

