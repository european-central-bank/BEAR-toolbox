import matlab.unittest.TestSuite
mfilename('fullpath')
suite = TestSuite.fromFile('replicationTests.m','Tag','QuickReplications');
suite.run()