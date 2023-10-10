import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoverageResult

clear; clc;
suite1 = TestSuite.fromFile('tests/replicationTests.m','Tag','QuickReplications');
suite2 = TestSuite.fromFile('tests/tSettings.m');
suite3 = TestSuite.fromFile('tests/tPanelSettings.m');
suite4 = TestSuite.fromFile('tests/tUtils.m');
suite5 = TestSuite.fromFile('tests/tFAVAR.m');
suite6 = TestSuite.fromFile('tests/tNewInterface.m');
suite7 = TestSuite.fromFile('tests/tApp.m');
suite = [suite1, suite2, suite3, suite4, suite5, suite7];

runner = TestRunner.withTextOutput;
result = runner.run(suite);
tb = table(result);
disp(tb);