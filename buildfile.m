function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("check") = CodeIssuesTask(["tbx/bear/bearing", "tbx/bear/+bear"]);    % Task for identifying code issues
plan("test") = TestTask('tests', SourceFiles='tbx');           % Task for running tests

plan("archive").Dependencies = ["check", "test"];

plan.DefaultTasks = "archive";
end

function archiveTask(~)
fld = currentProject().RootFolder;

% Create MLTBX file
v = ver('bear').Version;
% Create TBX
opts = matlab.addons.toolbox.ToolboxOptions("tbx", "88d5c97e-6fab-4fbd-b973-c6f3685996b3", ...
    ToolboxMatlabPath = [ ...
    fullfile(fld, "tbx", "bear"), ...
    fullfile(fld, "tbx", "bear", "bearing"), ...
    fullfile(fld, "tbx", "bear", "gui"), ...
    fullfile(fld, "tbx", "bear", "app")]);
% Add apps. Icons are in ./resources/mltbx_app_gallery_registration.xml
opts.AppGalleryFiles = [fullfile(fld, "tbx", "bear", "app", "BEAR6.m"), ...
     fullfile(fld, "tbx", "bear", "app", "BEARapp.m")];

% Tbx details
opts.ToolboxName = "BEAR toolbox";
opts.AuthorCompany = 'European Central Bank';
opts.AuthorEmail = 'alistair.dieppe@ecb.europa.eu';
opts.AuthorName = 'Alistair Dieppe and Björn van Roye';
opts.Description = "The Bayesian Estimation, Analysis and Regression toolbox (BEAR) is a comprehensive (Bayesian Panel) VAR toolbox for forecasting and policy analysis.";
opts.OutputFile = fullfile(fld, "releases", "BEARtoolbox.mltbx");
opts.Summary = 'The Bayesian Estimation, Analysis and Regression toolbox (BEAR)';
opts.ToolboxGettingStartedGuide = fullfile(currentProject().RootFolder,'tbx','doc','mfiles','GettingStarted.m');
opts.ToolboxVersion = v;
opts.MinimumMatlabRelease = "";

%% Package Toolbox
matlab.addons.toolbox.packageToolbox(opts)

%% Add License (requires Text Analytics Toolbox to read the PDF)
licPdf = fullfile(fld, "BEAR End User Licence Agreement.pdf");
licTxt = fullfile(fld, "BEAR End User Licence Agreement.txt");
lic = '';
if exist(licTxt, 'file')
    lic = fileread(char(licTxt));
elseif exist('extractFileText', 'file') == 2 && exist(licPdf, 'file')
    lic = char(extractFileText(licPdf));
else
    warning('buildfile:noLicenseText', ...
        ['Skipping license embedding: extractFileText (Text Analytics Toolbox) ' ...
         'is unavailable and no .txt fallback was found next to the PDF.']);
end
if ~isempty(lic)
    mlAddonSetLicense(char(opts.OutputFile), struct("type", 'Custom', "text", lic));
end
end