
function status = canHaveDummies()

    try
        estimatorObj = gui.getCurrentEstimatorObj();
        status = isequal(estimatorObj.CanHaveDummies, true);
    catch
        status = false;
    end

end%

