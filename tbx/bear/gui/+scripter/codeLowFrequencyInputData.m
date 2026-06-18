
function code = codeLowFrequencyInputData()

    dataSource = gui.getCurrentDataSource();
    mts = gui.MatlabToScript();

    place = struct();
    place.INPUT_DATA_PATH = mts.string(dataSource.LowFrequencyFilePath.value);

    code = scripter.readTemplate("lowFrequencyInputData");
    code = scripter.replaceInCode(code, place);

end%

