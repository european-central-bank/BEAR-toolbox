classdef tSettings < matlab.unittest.TestCase
    
    methods(Test)
        
        function tSetterFcnByNumber(tc)
            s = BEARSettings(1, 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSVARsettings')

            s = BEARSettings(2, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MeanAdjBVARsettings')

            s = BEARSettings(3, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARSettings')

            s = BEARSettings(4, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PanelBVARsettings')

            s = BEARSettings(5, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVBVARsettings')

            s = BEARSettings(6, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPBVARsettings')
        end

        function tSetterFcnByName(tc)
            s = BEARSettings("OLSVAR", 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSVARsettings')

            s = BEARSettings("MeanAdjBVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MeanAdjBVARsettings')

            s = BEARSettings("BVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARSettings')

            s = BEARSettings("PanelBVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PanelBVARsettings')

            s = BEARSettings("SVBVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVBVARsettings')

            s = BEARSettings("TVPBVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPBVARsettings')
        end

        function tFavar(tc)
            s = BEARSettings(1, 'data.xlsx');
            tc.verifyEqual(s.favar.FAVAR, false)
            s.favar.FAVAR = 1;
            tc.verifyClass(s.favar, 'bear.settings.FAVARsettings')
            tc.verifyEqual(s.favar.FAVAR, true)
        end

    end

end