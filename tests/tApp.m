classdef tApp < matlab.uitest.TestCase
    
    properties
        App
    end
    
    methods (TestMethodSetup)
        
        function loadApp(tc)
            tc.App = BEARapp20a();
            addTeardown(tc, @() delete(tc.App));
        end
        
    end
    
    methods (Test, TestTags = {'Git'})
        function tFrequency(tc)
           tc.choose(tc.App.frequency_cp, 'monthly');
           tc.press(tc.App.QuickExporttoWorkspaceButton)
           opts = evalin('base', 'opts');
           tc.verifyEqual(opts.frequency, 3);
           
           tc.choose(tc.App.frequency_cp, 'quarterly');
           tc.press(tc.App.QuickExporttoWorkspaceButton)
           opts = evalin('base', 'opts');
           tc.verifyEqual(opts.frequency, 2);  
           
           tc.choose(tc.App.frequency_cp, 'yearly');
           tc.press(tc.App.QuickExporttoWorkspaceButton)
           opts = evalin('base', 'opts');
           tc.verifyEqual(opts.frequency, 1);
           
           tc.choose(tc.App.frequency_cp, 'weekly');
           tc.press(tc.App.QuickExporttoWorkspaceButton)
           opts = evalin('base', 'opts');
           tc.verifyEqual(opts.frequency, 4);  
           
           tc.choose(tc.App.frequency_cp, 'daily');
           tc.press(tc.App.QuickExporttoWorkspaceButton)
           opts = evalin('base', 'opts');
           tc.verifyEqual(opts.frequency, 5);  
        end
    end

end