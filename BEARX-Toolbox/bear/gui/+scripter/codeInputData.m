
function code = codeInputData()

    dataSource = gui.getCurrentDataSource();
    mts = gui.MatlabToScript();

    place = struct();
    place.INPUT_DATA_PATH = mts.string(dataSource.FilePath.value);

    code = scripter.readTemplate("inputData");
    code = scripter.replaceInCode(code, place);

end%

