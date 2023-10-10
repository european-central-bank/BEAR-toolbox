import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoverageResult

clear; clc;
suite = TestSuite.fromProject(currentProject);

runner = TestRunner.withTextOutput;
htmlFolder = 'tests/myResults';
plugin = TestReportPlugin.producingHTML(htmlFolder);
runner.addPlugin(plugin);

sourceCodeFolder = "tbx";
reportFolder = "tests/coverageReport";
reportFormat = CoverageReport(reportFolder);
format = CoverageResult;
plugin = CodeCoveragePlugin.forFolder(bearroot(),"Producing",[reportFormat,format], ...
    IncludingSubfolders = true);
runner.addPlugin(plugin)

result = runner.run(suite);
table(result)