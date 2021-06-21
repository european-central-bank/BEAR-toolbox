import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

clear; clc;
suite1 = TestSuite.fromFile('replicationTests.m','Tag','QuickReplications');
suite2 = TestSuite.fromFile('tSettings.m');
suite = [suite1, suite2];

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder(bearroot(), 'IncludingSubfolders', true))
result = runner.run(suite);
tb = table(result);
disp(tb);