
function status = canBeIdentified()

    try
        estimatorObj = gui.getCurrentEstimatorObj();
        status = isequal(estimatorObj.CanBeIdentified, true);
    catch
        status = false;
    end 

end%

