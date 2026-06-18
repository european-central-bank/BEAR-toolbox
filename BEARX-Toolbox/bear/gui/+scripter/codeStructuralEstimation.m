
function code = codeStructuralEstimation()

    TASK_FORM_PATH = {"tasks", "identification"};
    taskSettings = gui.readFormsFile(TASK_FORM_PATH);

    mts = gui.MatlabToScript();

    place = struct();
    place.NUM_SAMPLES = mts.number(taskSettings.NumSamples.value);
    place = scripter.conditionalComments(place, taskSettings);

    % Create the code from the template
    code = scripter.readTemplate("structuralEstimation");
    code = scripter.replaceInCode(code, place);

end%

