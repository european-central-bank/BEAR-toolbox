import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

clear; clc;
suite1 = TestSuite.fromFile('replicationTests.m','Tag','QuickReplications');
suite2 = TestSuite.fromFile('tSettings.m');
suite3 = TestSuite.fromFile('tPanelSettings.m');
suite4 = TestSuite.fromFile('tUtils.m');
suite5 = TestSuite.fromFile('tFAVAR.m');
suite6 = TestSuite.fromFile('tNewInterface.m');
suite7 = TestSuite.fromFile('tApp.m');
suite8 = TestSuite.fromFile('tDAL.m');
suite = [suite1, suite2, suite3, suite4, suite5, suite7, suite8];

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder(bearroot(), 'IncludingSubfolders', true))
result = runner.run(suite);
tb = table(result);
disp(tb);