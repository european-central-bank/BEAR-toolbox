classdef tSettings < matlab.unittest.TestCase
    
    methods(Test)
        
        function tSetterFcnByNumber(tc)
            s = BEARsettings(1, 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(1))

            s = BEARsettings(2, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(2))

            s = BEARsettings(3, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MADJsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(3))

            s = BEARsettings(4, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PANELsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(4))

            s = BEARsettings(5, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(5))

            s = BEARsettings(6, "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(6))
        end

        function tSetterFcnByName(tc)
            s = BEARsettings("OLS", 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSsettings')

            s = BEARsettings("BVAR", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARsettings')

            s = BEARsettings("MADJ", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MADJsettings')

            s = BEARsettings("PANEL", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PANELsettings')

            s = BEARsettings("SV", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVsettings')

            s = BEARsettings("TVP", "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPsettings')
        end

        function tFavar(tc)
            s = BEARsettings(1, 'data.xlsx');
            tc.verifyEqual(s.favar.FAVAR, false)
            s.favar.FAVAR = 1;
            tc.verifyClass(s.favar, 'bear.settings.FAVARsettings')
            tc.verifyEqual(s.favar.FAVAR, true)
        end

        function tStrctident(tc)
            s = BEARsettings(1, 'data.xlsx');

            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt4');
            tc.verifyEqual(s.IRFt, bear.IRFtype(4))

            s.IRFt = 5;
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt5');

            s.IRFt = 6;
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt6');

            s = BEARsettings(2, 'data.xlsx');

            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt4');
            tc.verifyEqual(s.IRFt, bear.IRFtype(4))

            s.IRFt = 5;
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt5');

            s.IRFt = 6;
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt6');

            s = BEARsettings(1, 'data.xlsx', 'IRFt', 5);
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt5');

            s = BEARsettings(2, 'data.xlsx', 'IRFt', 6);
            tc.verifyClass(s.strctident, 'bear.settings.StrctidentIRFt6');
        end

    end

end