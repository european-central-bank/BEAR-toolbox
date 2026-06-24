classdef tPanelSettings < matlab.unittest.TestCase
    
    
    methods (Test, TestTags = {'Git'})
        function tPanelIRFt56(tc)
            opts = BEARsettings(4, 'ExcelFile', 'data.xlsx');
            
            fcn = @() setProp(opts, 'IRFt',5);            
            tc.verifyError(fcn, 'bear:settings:PANELsettings:UnusedIRFt')
            
            fcn = @() setProp(opts, 'IRFt',6);            
            tc.verifyError(fcn, 'bear:settings:PANELsettings:UnusedIRFt')
        end
        
        function tPanel1IRFt1(tc)
            opts = BEARsettings(4, 'ExcelFile', 'data.xlsx');
            opts.panel = 1;
            tc.verifyEqual(bear.PANELtype(1), opts.panel);

            fcn = @() setProp(opts, 'IRFt',2);            
            tc.verifyError(fcn, 'bear:settings:PANELsettings:WrongIRFt')
            
            fcn = @() setProp(opts, 'IRFt',3);            
            tc.verifyError(fcn, 'bear:settings:PANELsettings:WrongIRFt')
            
            fcn = @() setProp(opts, 'IRFt',4);            
            tc.verifyError(fcn, 'bear:settings:PANELsettings:WrongIRFt')
            
        end
        
        function tPanel234IRFt234(tc)
            opts = BEARsettings(4, 'ExcelFile', 'data.xlsx');
            opts.panel = 2;
            tc.verifyEqual(bear.PANELtype(2), opts.panel);    
            
            opts.IRFt = 1;
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
            opts.IRFt = 2;
            tc.verifyEqual(bear.IRFtype(2), opts.IRFt); 
            opts.IRFt = 3;
            tc.verifyEqual(bear.IRFtype(3), opts.IRFt); 
            opts.IRFt = 4;
            tc.verifyEqual(bear.IRFtype(4), opts.IRFt); 
            
            opts.panel = 3;
            tc.verifyEqual(bear.PANELtype(3), opts.panel);            
            
            opts.IRFt = 1;
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
            opts.IRFt = 2;
            tc.verifyEqual(bear.IRFtype(2), opts.IRFt); 
            opts.IRFt = 3;
            tc.verifyEqual(bear.IRFtype(3), opts.IRFt); 
            opts.IRFt = 4;
            tc.verifyEqual(bear.IRFtype(4), opts.IRFt);  
            
            opts.panel = 2;
            tc.verifyEqual(bear.PANELtype(2), opts.panel);
            
            opts.IRFt = 1;
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
            opts.IRFt = 2;
            tc.verifyEqual(bear.IRFtype(2), opts.IRFt); 
            opts.IRFt = 3;
            tc.verifyEqual(bear.IRFtype(3), opts.IRFt); 
            opts.IRFt = 4;
            tc.verifyEqual(bear.IRFtype(4), opts.IRFt); 
            
        end
        
        function tPanel56(tc)
            opts = BEARsettings(4, 'ExcelFile', 'data.xlsx');
            opts.panel = 5;
            tc.verifyEqual(bear.PANELtype(5), opts.panel);
        end
        
        function tSwitchPanels(tc)
            opts = BEARsettings(4, 'ExcelFile', 'data.xlsx');
            opts.panel = 1;
            tc.verifyEqual(bear.PANELtype(1), opts.panel);
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
            
            opts.panel = 3;
            tc.verifyEqual(bear.PANELtype(3), opts.panel);
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
            opts.IRFt = 2;
            tc.verifyEqual(bear.IRFtype(2), opts.IRFt);
            
            opts.panel = 5;
            tc.verifyEqual(bear.PANELtype(5), opts.panel);
            tc.verifyEqual(bear.IRFtype(1), opts.IRFt);
        end
    end
    
end

function s = setProp(s, prop, value)
s.(prop) = value;
end