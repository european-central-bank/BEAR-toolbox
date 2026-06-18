
function estimatorSettings = getCurrentEstimatorSettings()

    estimator = gui.getCurrentEstimator();

    if estimator == ""
        estimatorSettings = [];
        return
    end

    path = {"estimation", estimator};
    estimatorSettings = gui.readFormsFile(path);

end%

