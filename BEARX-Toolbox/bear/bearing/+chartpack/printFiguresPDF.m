
function printFiguresPDF(figureHandles, filePath, options)

    arguments
        figureHandles (1, :) cell
        filePath (1, 1) string
        %
        options.FillPaper (1, 1) logical = true
        options.PaperType (1, 1) string = "A4"
    end

    numFigures = numel(figureHandles);

    for i = 1 : numFigures
        preparePaper_(figureHandles{i}, options);
    end

    filePath = string(filePath) + ".pdf";
    if isfile(filePath)
        delete(filePath);
    end

    % BEARX6 Linux/headless patch: hide figures during export and isolate
    % each call so a single failing exportgraphics (e.g. when run from the
    % GUI via htmlviewer) does not abort the whole script. Visibility is
    % restored after the export so figures still show on screen.
    for i = 1 : numFigures
        fh = figureHandles{i};
        if ~isgraphics(fh)
            warning("chartpack:printFiguresPDF:invalidFigure", "Figure %d is invalid; skipping.", i);
            continue;
        end
        prevVisible = get(fh, "Visible");
        try
            set(fh, "Visible", "off");
        catch
        end
        try
            exportgraphics( ...
                fh ...
                , filePath ...
                , contentType="vector" ...
                , append=true ...
            );
        catch err
            warning("chartpack:printFiguresPDF:exportFailed", ...
                "exportgraphics failed for figure %d: %s", i, err.message);
        end
        try
            if isgraphics(fh)
                set(fh, "Visible", prevVisible);
            end
        catch
        end
    end

end%


function preparePaper_(figureHandle, options)
    %[
    set(figureHandle, paperType=options.PaperType);
    set(figureHandle, paperPositionMode="manual");
    set(figureHandle, paperOrientation="landscape");
    paperSize = get(figureHandle, "paperSize");
    set(figureHandle, paperPosition=[0, 0, paperSize]);
    %]
end%

