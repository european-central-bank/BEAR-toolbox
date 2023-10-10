classdef tApp < matlab.uitest.TestCase
    
    properties
        App
    end
    
    methods (TestMethodSetup)
        
        function loadApp(tc)
            tc.App = BEARapp();
            addTeardown(tc, @() delete(tc.App));
        end
        
    end
    
    methods (Test)
        
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
        
        function tFeval(tc)
            
            tc.choose(tc.App.APPLICATIONSTab)
            tc.press(tc.App.QuickExporttoWorkspaceButton)
            opts = evalin('base', 'opts');
            tc.verifyEqual(opts.Feval, false);
            
            tc.press(tc.App.Feval_cp);
            tc.press(tc.App.QuickExporttoWorkspaceButton)
            opts = evalin('base', 'opts');
            tc.verifyEqual(opts.Feval, true);
            
        end

        function tCaldaraReplication(tc)
            
            tc.press(tc.App.CaldaraandHerbst2019Menu)
            tc.press(tc.App.QuickExporttoWorkspaceButton)
            opts = evalin('base', 'opts');
            tc.verifyEqual(opts.strctident.prior_type_reduced_form, 2);
            
        end

        function tStructIdent(tc)
            
            tc.choose(tc.App.APPLICATIONSTab)
            tc.choose(tc.App.Proxysign)
            tc.press(tc.App.QuickExporttoWorkspaceButton)            
            opts = evalin('base', 'opts');
            tc.verifyEqual(opts.strctident.prior_type_reduced_form, 1);
            tc.verifyEqual(opts.strctident.prior_type_proxy, 1);

            tc.choose(tc.App.prior_type_proxy, 'No');
            tc.press(tc.App.QuickExporttoWorkspaceButton)
            opts = evalin('base', 'opts');
            tc.verifyEqual(opts.strctident.prior_type_proxy, 2);

        end
        
    end
    
end