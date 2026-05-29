
% Starting a GUI application

function resume()

    guiFolder = gui_getFolder();

    % Recreate HTML files from originals
    guiHTMLFolder = fullfile(guiFolder, "html");
    customHTMLFolder = fullfile(".", "html");
    if exist(customHTMLFolder, "dir")
        rmdir(customHTMLFolder, "s");
    end
    copyfile(guiHTMLFolder, customHTMLFolder);

    %
    % Populate HTML files with current forms
    %

    % Input data tab
    gui.populateDataSourceHTML();

    % Reduced-form estimation tab
    gui.populateEstimatorSelectionHTML();
    gui.populateEstimatorSettingsHTML();

    % Meta information tab
    gui.populateMetaSettingsHTML();

    % Dummy observations tab
    gui.populateDummiesSelectionHTML();
    gui.populateVanillaFormHTML({"dummies", "Minnesota"});
    gui.populateVanillaFormHTML({"dummies", "InitialObs"});
    gui.populateVanillaFormHTML({"dummies", "SumCoeff"});
    gui.populateVanillaFormHTML({"dummies", "LongRun"});

    % Structural identification tab
    gui.populateIdentificationSelectionHTML();
    gui.populateVanillaFormHTML({"identification", "cholesky"});
    gui.populateVanillaFormHTML({"identification", "InstantZeros"});
    gui.populateVanillaFormHTML({"identification", "IneqRestrict"});
    gui.populateVanillaFormHTML({"identification", "GeneralRestrict"});

    % Tasks to execute tab
    gui.populateTasksSelectionHTML();
    gui.populateVanillaFormHTML({"tasks", "general"});
    gui.populateVanillaFormHTML({"tasks", "estimation"});
    gui.populateVanillaFormHTML({"tasks", "identification"});
    gui.populateVanillaFormHTML({"tasks", "redForecast"});
    gui.populateVanillaFormHTML({"tasks", "structForecast"});
    gui.populateVanillaFormHTML({"tasks", "conditional"}, "gui_collectConditionalSettings ");
    gui.populateVanillaFormHTML({"tasks", "responses"});
    gui.populateVanillaFormHTML({"tasks", "fevd"});
    gui.populateVanillaFormHTML({"tasks", "contributions"});


    % Matlab script tab
    gui.populateVanillaFormHTML({"script", "settings"});
    % gui.populateScriptSettingsHTML();
    gui.populateScriptExecutionHTML();
    gui.populateScriptListingHTML();


    %
    % Populate notes in all tabs
    %
    tabs = [
        "home", "data", "meta", "estimation", ...
        "identification", "tasks", "script"
    ];
    for i = tabs
        gui.populateNotesHTML(i);
    end


    %
    % Insert the correct paths to tables in the HTML files
    %
    currentFolder = pwd();
    wrapTablePath = @(n) fullfile(currentFolder, "tables", n);
    dispatcher = {
        fullfile(".", "html", "identification", "InstantZeros.html"), "?PATH?", "matlab: gui_openTable InstantZeros"
        fullfile(".", "html", "identification", "IneqRestrict.html"), "?PATH?", "matlab: gui_openTable IneqRestrict"
        fullfile(".", "html", "dummies", "longrun.html"), "?PATH?", "matlab: gui_openTable LongRunDummies"
        fullfile(".", "html", "identification", "GeneralRestrict.html"), "?PATH?", "matlab: gui_editGeneralRestrict"
        fullfile(".", "html", "tasks", "conditional.html"), "?DATA_PATH?", "matlab: gui_openTable ConditioningData"
        fullfile(".", "html", "tasks", "conditional.html"), "?PLAN_PATH?", "matlab: gui_openTable ConditioningPlan"
    };
    for i = 1 : height(dispatcher)
        htmlPath = dispatcher{i, 1};
        placeholder = dispatcher{i, 2};
        href = dispatcher{i, 3};
        gui.copyCustomHTML(htmlPath, htmlPath, placeholder, href);
    end


    %
    % Open Matlab web browser with the landing page
    %
    customHTMLFolder = fullfile(".", "html");
    indexPath = fullfile(customHTMLFolder, 'index.html');
    x = gui.web(indexPath);

end%

