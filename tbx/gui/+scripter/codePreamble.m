
function code = codePreamble()

    mts = gui.MatlabToScript();
    timestamp = datetime();
    settings = gui.getCurrentPrerequisites();
    module = gui.getCurrentModule();

    place = struct();
    place.TIMESTAMP = string(timestamp);
    place.MODULE = string(module);
    place.PERCENTILES = mts.numbers(settings.Percentiles.value);
    place.OUTPUT_FOLDER = mts.string(settings.OutputFolder.value);

    code = scripter.readTemplate("preamble");
    code = scripter.replaceInCode(code, place);

end%

