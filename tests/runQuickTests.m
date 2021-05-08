import matlab.unittest.TestSuite
cd(fileparts(mfilename('fullpath')));
suite = TestSuite.fromFile('replicationTests.m','Tag','QuickReplications');
suite.run()