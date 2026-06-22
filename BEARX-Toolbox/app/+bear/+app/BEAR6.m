classdef BEAR6 < handle

    properties (Hidden, SetAccess = private)
        Figure
        Grid
        DirSelector
        ExistingButton
        NewButton
    end

    properties (SetAccess = ?matlab.unittest.TestCase)
        WorkingDir (1,1) string {mustBeFolder} = pwd
    end

    methods

        function obj = BEAR6()

            obj.Figure = uifigure(Position=[500,500,651,170], Name = "BEAR 6 estimation", Resize = "off");

            obj.WorkingDir = pwd;

            obj.Grid = uigridlayout(obj.Figure, [2,3], RowHeight={30, 50}, ColumnWidth={100, '1x'}, Padding=30);

            html = [
                '<!DOCTYPE html>' ...
                '<html>' ...
                '<head>' ...
                '<style>' ...
                '  html, body { margin:0; padding:0; overflow:hidden; background:transparent; }' ...
                '  svg { width:100%; height:100%; display:block; }' ...
                '</style>' ...
                '</head>' ...
                '<body>' ...
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">' ...
                '<path d="M15.75 19.13c-.83 0-1.5-.84-1.5-1.88 0-1.03.67-1.87 1.5-1.87s1.5.84 1.5 1.87c0 1.04-.67 1.88-1.5 1.88M12 11.25c-1.24 0-2.25-.84-2.25-1.87 0-1.04 1.01-1.88 2.25-1.88s2.25.84 2.25 1.88c0 1.03-1.01 1.87-2.25 1.87m-3.75 7.88c-.83 0-1.5-.84-1.5-1.88 0-1.03.67-1.87 1.5-1.87s1.5.84 1.5 1.87c0 1.04-.67 1.88-1.5 1.88M12 8.25c.41 0 .75.34.75.75s-.34.75-.75.75-.75-.34-.75-.75.34-.75.75-.75M18.75 12c-.32 0-.63.07-.91.2-.48-.61-1.13-1.13-1.91-1.53.57-.8.91-1.77.91-2.82v-.06c1.09-.23 1.91-1.2 1.91-2.37 0-1.33-1.09-2.42-2.42-2.42-.69 0-1.33.29-1.75.75a4.813 4.813 0 0 0-5.16 0C9 3.29 8.36 3 7.67 3 6.34 3 5.25 4.09 5.25 5.42c0 1.16.82 2.13 1.9 2.37v.06c0 1.05.35 2.03.91 2.82-.77.4-1.42.92-1.9 1.53A2.24 2.24 0 0 0 3 14.25c0 1.25 1 2.25 2.25 2.25h.06c-.04.24-.06.5-.06.75 0 2.07 1.34 3.75 3 3.75 1.01 0 1.9-.63 2.45-1.59.42.06.85.09 1.3.09s.88-.03 1.3-.09c.55.96 1.44 1.59 2.45 1.59 1.66 0 3-1.68 3-3.75 0-.25-.02-.51-.06-.75h.06c1.25 0 2.25-1 2.25-2.25S20 12 18.75 12"/>' ...
                '</svg>' ...
                '</body>' ...
                '</html>'
                ];

            Img = uihtml(obj.Grid,'HTMLSource',html);            
            Img.Layout.Row = [1 2];
            Img.Layout.Column = 1;
            
            obj.DirSelector = uidropdown(obj.Grid, "Items", [pwd, "Browse.."], "BackgroundColor", "w", ...
            "ValueChangedFcn",@(s,e) obj.selectionChangedCallback(s));
            obj.DirSelector.Layout.Row = 1;
            obj.DirSelector.Layout.Column = [2 3];            

            obj.NewButton = uibutton(obj.Grid, ...
                Text='New Estimation', ...
                FontSize = 20, ...
                FontWeight='bold', ...
                ButtonPushedFcn=@(s,e) obj.newCallback(s,e));
            obj.NewButton.Layout.Row = 2;
            obj.NewButton.Layout.Column = 2;

            obj.ExistingButton = uibutton(obj.Grid, ...
                Text='Existing Estimation', ...
                FontSize = 20, ...
                FontWeight='bold', ...
                ButtonPushedFcn=@(s,e) obj.existingCallback(s,e));
            obj.ExistingButton.Layout.Row = 2;
            obj.ExistingButton.Layout.Column = 3;
        end

        function selectionChangedCallback(obj, s, ~)
            dName = uigetdir(fullfile(pwd), 'BEAR results folder');
            if isnumeric(dName) && dName == 0
                return
            end
            obj.WorkingDir = dName;
            s.Items = [dName, "Browse.."];
            s.Value = dName;
        end

        % --- Callbacks ---
        function newCallback(obj, ~, ~)

            dName = obj.WorkingDir;
            d = dir(fullfile(dName,"*"));
            d = d(~ismember({d.name}, {'.','..'}));
            if ~isempty(d)
                obj.throwError('Please select a folder that is empty', 'Folder not Empty')
            else
                cd(dName)
                gui.start()   
                delete(obj)
            end
           
        end

        function existingCallback(obj, ~, ~)
            dName = obj.WorkingDir;

            d = dir(fullfile(dName,"*"));
            if all(ismember({'html','forms','tables'}, {d.name}))
                here = pwd();
                try
                    cd(dName)
                    gui.resume;
                    delete(obj)
                catch
                    cd(here)
                    obj.throwError(...
                        'Unable to resume BEAR estimation, please check that the folder you selected contains a valid BEAR estimation', ...
                        'Invalid Folder')
                end
            else
                obj.throwError(...
                    'Unable to resume BEAR estimation, please check that the folder you selected contains a valid BEAR estimation', ...
                    'Invalid Folder')
            end
           

        end

        function throwError(obj, msg, title)
            uialert(obj.Figure, msg , title)
        end

        function delete(obj)
            close(obj.Figure);
        end

    end

end