import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoverageResult


clear; clc;
% suite = TestSuite.fromFile('replicationTests.m');
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
table(results)

% assert(all([result.Passed]))
% coverageResults = format.Result;
% summary = coverageSummary(coverageResults,"statement");
% assert(summary(1,1)/summary(1,2) > 0.6) % Coverage above 60 requried