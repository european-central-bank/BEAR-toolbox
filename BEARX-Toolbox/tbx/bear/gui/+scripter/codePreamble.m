
function code = codePreamble()

    mts = gui.MatlabToScript();
    timestamp = datetime();
    general = gui.getGeneralSettings();
    module = gui.getCurrentModule();

    place = struct();
    place.TIMESTAMP = string(timestamp);
    place.MODULE = string(module);
    place.PERCENTILES = mts.numbers(general.Percentiles.value);
    place.OUTPUT_FOLDER = mts.string(general.OutputFolder.value);

    code = scripter.readTemplate("preamble");
    code = scripter.replaceInCode(code, place);

end%

