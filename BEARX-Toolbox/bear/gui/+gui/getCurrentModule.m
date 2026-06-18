
function currentModule = getCurrentModule()

    currentModule = gui.readFormsFile({"module", "selection"});
    currentModule = string(currentModule);

end%

