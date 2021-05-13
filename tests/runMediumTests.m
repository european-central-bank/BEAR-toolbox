import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

clear; clc;
suite = TestSuite.fromFile('replicationTests.m','Tag','MediumReplications');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder(bearroot(), 'IncludingSubfolders', true))
result = runner.run(suite);
tb = table(result);
disp(tb);