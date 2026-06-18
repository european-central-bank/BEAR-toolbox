
% Starting a GUI application

function start()

    % Recreate folders and files with custom content
    % * forms
    % * tables
    gui.recreateCustomFolders();

    % Recreates HTML files from originals
    % Resume the GUI application from the current content of forms
    gui.resume();

end%

