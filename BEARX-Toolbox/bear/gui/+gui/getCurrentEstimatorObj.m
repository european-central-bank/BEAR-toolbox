
function currentEstimatorObj = getCurrentEstimatorObj()

    currentEstimator = gui.getCurrentEstimator();

    if currentEstimator == ""
        currentEstimatorObj = [];
        return
    end

    currentModule = gui.getCurrentModule();
    currentEstimatorObj = eval(currentModule + ".estimator." + currentEstimator);

end%

