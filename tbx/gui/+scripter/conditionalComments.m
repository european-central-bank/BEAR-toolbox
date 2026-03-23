
function place = conditionalComments(place, taskSettings)

    x = struct( ...
        SaveMAT="SAVE_MAT", ...
        SaveCSV="SAVE_CSV", ...
        SaveXLS="SAVE_XLS", ...
        DrawCharts="DRAW_CHARTS", ...
        SavePDF="SAVE_PDF" ...
    );

    for n = textual.fields(x)
        if ~isfield(taskSettings, n)
            continue
        end
        if taskSettings.(n).value
            comment = "";
        else
            comment = "% ";
        end
        ph = x.(n);
        place.(ph) = comment;
    end

end%

