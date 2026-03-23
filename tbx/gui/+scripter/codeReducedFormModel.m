
function code = codeReducedFormModel()

    estimator = gui.getCurrentEstimator();
    estimatorSettings = gui.getCurrentEstimatorSettings();

    place = struct();
    place.ESTIMATOR = string(estimator);
    place.ESTIMATOR_SETTINGS = scripter.printFormAsSettings(estimatorSettings);

    % Create the code from the template
    code = scripter.readTemplate("reducedFormModel");
    code = scripter.replaceInCode(code, place);

end%

