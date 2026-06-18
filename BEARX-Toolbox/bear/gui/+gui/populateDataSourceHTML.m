
function targetPath = populateDataSourceHTML()

    isText = @(x) ischar(x) || isstring(x);

    FORM_PATH = {"data", "source"};
    HTML_END_PATH = {"html", "data", "source.html"};
    NO_DATA_FILE_SELECTED = "[No data file selected]";

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, HTML_END_PATH{:});
    targetPath = fullfile(".", HTML_END_PATH{:});

    filePath = gui.getCurrentDataFilePath("FilePath");
    isFilePath = isText(filePath) && strlength(filePath) > 0;
    filePathMessage = filePath;
    if ~isFilePath
        filePathMessage = NO_DATA_FILE_SELECTED;
    end

    isMixed = gui.isMixedFrequency();
    lowFilePath = gui.getCurrentDataFilePath("LowFrequencyFilePath");
    isLowFilePath = isText(lowFilePath) && strlength(lowFilePath) > 0;
    lowFilePathMessage = filePath;
    if ~isLowFilePath
        lowFilePathMessage = NO_DATA_FILE_SELECTED;
    end

    spans = struct();
    if isFilePath
        tbl = tablex.fromFile(filePath);
        spans = tablex.getObservationPeriods(tbl, spans);
    end

    if isMixed && isLowFilePath
        tbl = tablex.fromFile(lowFilePath);
        spans = tablex.getObservationPeriods(tbl, spans);
    end

    names = textual.fields(spans);

    if isempty(names)
        info = "<code>" + NO_DATA_FILE_SELECTED + "</code>";
    else
        maxLength = max(strlength(names));
        info = "<ul>";
        for n = textual.fields(spans)
            info = [info; sprintf( ...
                "<li><code>%s....%s:%s</code></li>", ...
                pad(n, maxLength, "."), ...
                string(spans.(n)(1)), ...
                string(spans.(n)(end)) ...
            )]; %#ok<AGROW>
        end
        info = [info; "</ul>"];
        info = join(info, newline());
    end

    filePathMessage = "<code>" + filePathMessage + "</code>";
    lowFilePathMessage = "<code>" + lowFilePathMessage + "</code>";

    args = {
        "?FILE?", filePathMessage ...
        , "?LOW_FILE?", lowFilePathMessage ...
        , "?INFO?", info  ...
    };

    if ~isMixed
        args = [{@removeLowFrequencySection_}, args];
    end

    gui.copyCustomHTML(sourcePath, targetPath, args{:});

end%


function html = removeLowFrequencySection_(html)
    pattern = "<hr />.*?<hr />";
    replace = "<hr />";
    html = regexprep(html, pattern, replace);
end%

