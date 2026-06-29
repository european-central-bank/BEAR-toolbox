classdef tBEAR6app < matlab.uitest.TestCase

    methods (Test)

        function tOpenClose(tc)
            here = pwd;
            app = BEAR6();
            tc.addTeardown(@() delete(app));
            tc.verifyEqual(pwd, here)
        end

        function tBadFolder(tc)
            here = pwd();
            app = BEAR6();
            tc.addTeardown(@() delete(app));
            tc.press(app.ExistingButton)
            tc.dismissDialog("uialert", app.Figure);
            tc.verifyEqual(pwd, here)
        end

        function tBadFolder2(tc)
            here = pwd();
            app = BEAR6();
            tc.addTeardown(@() delete(app));
            tc.press(app.NewButton)
            tc.dismissDialog("uialert",app.Figure);
            tc.verifyEqual(pwd, here)
        end

        function tNewEstimation(tc)
            % Return to here.
            here = pwd;
            tc.addTeardown(@() cd(here));

            % Start app
            app = BEAR6();
            tc.addTeardown(@() delete(app));

            fx = matlab.unittest.fixtures.TemporaryFolderFixture;
            tc.applyFixture(fx);

            app.WorkingDir = fx.Folder;
            tc.verifyEqual(app.WorkingDir, string(fx.Folder))

            tc.press(app.NewButton);
            pause(1) % Let BEAR render
            cd(here)
        end

        function tExistingEstimation(tc)
            % Return to here.
            here = pwd;
            tc.addTeardown(@() cd(here));

            % Start app
            app = BEAR6();

            % Create test folder
            fx = matlab.unittest.fixtures.TemporaryFolderFixture;
            tc.applyFixture(fx);

            % Create New Estimation.
            app.WorkingDir = fx.Folder;
            tc.press(app.NewButton);
            delete(app);

            tc.verifyEqual(pwd, fx.Folder)
            % Start New app.
            app = BEAR6();
            tc.addTeardown(@() delete(app));

            tc.verifyEqual(string(pwd), app.WorkingDir)
            tc.press(app.ExistingButton);
            pause(1) % Let BEAR render
            cd(here)
        end

    end
end