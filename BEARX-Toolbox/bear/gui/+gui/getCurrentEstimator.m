
function estimator = getCurrentEstimator()

    FORM_PATH = {"estimation", "selection"};

    estimatorSelectionForm = gui.readFormsFile(FORM_PATH);
    estimator = gui.querySelection(form=estimatorSelectionForm, count=[0, 1]);

    if isempty(estimator)
        estimator = "";
    end
    estimator = string(estimator);

end%

