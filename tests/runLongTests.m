import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

clear; clc;
suite = TestSuite.fromFile('tests/replicationTests.m','Tag','LongReplications');
runner = TestRunner.withTextOutput;
result = runner.run(suite);
tb = table(result);
disp(tb);