
function targetFile = populateScriptListingHTML()

    HTML_END_PATH = {"html", "script", "listing.html"};
    TARGET_PAGE = {"html", "script", "listing.html"};
    LISTING = "<div class='language-matlab highlight'><pre><code>?CODE?</code></pre></div>";

    scriptName = gui.getCurrentScriptName();
    try
        code = textual.read(scriptName); 
    catch
        scriptName = "[No valid script name selected or script does not exist]";
        code = "";
    end

    listing = replace(LISTING, "?CODE?", code);

    guiFolder = gui_getFolder();
    sourceFile = fullfile(guiFolder, HTML_END_PATH{:});
    targetFile = fullfile(".", HTML_END_PATH{:});

    gui.copyCustomHTML( ...
        sourceFile, targetFile ...
        , "?SCRIPT_NAME?", scriptName ...
        , "?LISTING?", listing ...
    );

end%

