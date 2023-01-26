classdef tUtils < matlab.unittest.TestCase
    
    methods(Test, TestTags = {'Git'})
        
        function tfixstring(tc)
            str = '  a s dsds   sd asrt          as 2893 ~@           ';
            fix = bear.utils.fixstring(str);
            tc.verifyEqual(fix, 'a s dsds sd asrt as 2893 ~@');
        end

    end

end