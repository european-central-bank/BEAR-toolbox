classdef (Abstract) tBEARGUIBase <  matlab.unittest.TestCase

    properties
        RootDir
    end

    methods (TestClassSetup)
        function storeRoot(tc)
            tc.RootDir = pwd;
        end
    end

    methods (TestMethodTeardown)
        function restoreState(tc)
            close all force
            cd(tc.RootDir);
        end
    end

end