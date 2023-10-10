import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoverageResult

clear; clc;
suite1 = TestSuite.fromFile('tests/replicationTests.m','Tag','QuickReplications');
suite2 = TestSuite.fromFolder('tests', 'Tag', 'Unit');
suite = [suite1, suite2];

runner = TestRunner.withTextOutput;
result = runner.run(suite);
tb = table(result);
disp(tb);