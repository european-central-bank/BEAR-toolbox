
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

    for i = 1 : numFigures
        exportgraphics( ...
            figureHandles{i} ...
            , filePath ...
            , contentType="vector" ...
            , append=true ...
        );
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

