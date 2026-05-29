
function returnFromCommandWindow(targetPage)

    if nargin < 1
        TARGET_PAGE = {"html", "script", "execution.html"};
        targetPage = fullfile(".", TARGET_PAGE{:});
    end

    bottomLine = "<a href=""matlab:gui.web('?HTML?')"">Click here to return to the GUI</a>";
    bottomLine = replace(bottomLine, "?HTML?", targetPage);

    disp(" ");
    disp(bottomLine);
    disp(" ");

end%

