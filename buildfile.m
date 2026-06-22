function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("check") = CodeIssuesTask(["BEARX-Toolbox/bear/bearing", "BEARX-Toolbox/bear/+bear"]);    % Task for identifying code issues
plan("test") = TestTask(["tests/bearx_feature_tests", "tests/app"], ...
    SourceFiles=[ ...
    fullfile("BEARX-Toolbox", "bear", "+bear"), ...
    fullfile("BEARX-Toolbox", "bear", "app"), ...
    fullfile("BEARX-Toolbox", "bear", "bearing"),  ...
    fullfile("BEARX-Toolbox", "bear", "gui", "+gui"),  ...
    fullfile("BEARX-Toolbox", "bear", "gui", "+scripter")], ...
    CodeCoverageResults=fullfile("tests","results", "coverage.html"), ...
    TestResults=[fullfile("tests", "results", "results.html"), fullfile("tests", "results", "results.xml")]);           % Task for running tests

plan("archive").Dependencies = ["check", "test"];

plan.DefaultTasks = "archive";
end

function archiveTask(~)
fld = bearroot;

% Create MLTBX file
v = ver('bear').Version;
% Create TBX
% opts = matlab.addons.toolbox.ToolboxOptions("BEARX-Toolbox", "88d5c97e-6fab-4fbd-b973-c6f3685996b3", ...
%     ToolboxMatlabPath = [ ...
%     fullfile(fld, "bear"), ...
%     fullfile(fld, "bear", "bearing"), ...
%     fullfile(fld, "bear", "gui"), ...
%     fullfile(fld, "app"), ...
%     fullfile(fld, "app", "bear5")]);

opts = matlab.addons.toolbox.ToolboxOptions("BEARX-Toolbox", "88d5c97e-6fab-4fbd-b973-c6f3685996b3", ...
    ToolboxMatlabPath = [ ...
    fullfile(fld), ...
    fullfile(fld, "bear"), ...
    fullfile(fld, "app"), ...
    fullfile(fld, "app", "bear5")]);

% Add apps. Icons are in ./resources/mltbx_app_gallery_registration.xml
opts.AppGalleryFiles = [fullfile(fld, "app", "BEAR6.m"), ...
    fullfile(fld, "app", "bear5", "BEARapp.m")];

% Tbx details
opts.ToolboxName = "BEAR toolbox";
opts.AuthorCompany = 'European Central Bank';
opts.AuthorEmail = 'alistair.dieppe@ecb.europa.eu';
opts.AuthorName = 'Alistair Dieppe and Björn van Roye';
opts.Description = "The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis.";
opts.OutputFile = fullfile(fileparts(fld), "releases", "BEARtoolbox.mltbx");
opts.Summary = 'The Bayesian Estimation, Analysis and Regression toolbox (BEAR)';
% opts.ToolboxGettingStartedGuide = fullfile(currentProject().RootFolder,'BEARX-Toolbox','doc','mfiles','GettingStarted.m');
opts.ToolboxVersion = v;
opts.MinimumMatlabRelease = "";

%% Package Toolbox
matlab.addons.toolbox.packageToolbox(opts)

%% Add License (requires Text Analytics Toolbox to read the PDF)
licPdf = fullfile(fileparts(fld), "BEAR End User Licence Agreement.pdf");
lic = char(extractFileText(licPdf));
mlAddonSetLicense(char(opts.OutputFile), struct("type", 'Custom', "text", lic));

end