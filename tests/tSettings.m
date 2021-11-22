classdef tSettings < matlab.unittest.TestCase
    
    methods(Test)
        
        function tDefaults(tc)
            s = @() BEARsettings(1);
            tc.verifyError(s, 'bear:settings:UndefinedExcelFile')
        end
        
        function tSetterFcnByNumber(tc)
            s = BEARsettings(1, 'ExcelFile', 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(1))

            s = BEARsettings(2, 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(2))

            s = BEARsettings(4, 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PANELsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(4))

            s = BEARsettings(5, 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(5))

            s = BEARsettings(6, 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(6))            
            
            s = BEARsettings(7, 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MFVARsettings')
            tc.verifyEqual(s.VARtype, bear.VARtype(7))
        end

        function tSetterFcnByName(tc)
            s = BEARsettings("OLS", 'ExcelFile', 'data.xlsx');
            tc.verifyClass(s, 'bear.settings.OLSsettings')

            s = BEARsettings("BVAR", 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.BVARsettings')

            s = BEARsettings("PANEL", 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.PANELsettings')

            s = BEARsettings("SV", 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.SVsettings')

            s = BEARsettings("TVP", 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.TVPsettings')          
            
            s = BEARsettings("MFVAR", 'ExcelFile', "data.xlsx");
            tc.verifyClass(s, 'bear.settings.MFVARsettings')
        end

        function tFavar(tc)
            s = BEARsettings(1, 'ExcelFile', 'data.xlsx');
            tc.verifyEqual(s.favar.FAVAR, false)
            s.favar.FAVAR = 1;
            tc.verifyClass(s.favar, 'bear.settings.favar.FAVARsettings')
            tc.verifyEqual(s.favar.FAVAR, true)
        end

        function tStrctident(tc)
            s = BEARsettings(1, 'ExcelFile', 'data.xlsx');

            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt4');
            tc.verifyEqual(s.IRFt, bear.IRFtype(4))

            s.IRFt = 5;
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt5');

            s.IRFt = 6;
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt6');

            s = BEARsettings(2, 'ExcelFile', 'data.xlsx');

            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt4');
            tc.verifyEqual(s.IRFt, bear.IRFtype(4))

            s.IRFt = 5;
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt5');

            s.IRFt = 6;
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt6');

            s = BEARsettings(1, 'ExcelFile', 'data.xlsx', 'IRFt', 5);
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt5');

            s = BEARsettings(2, 'ExcelFile', 'data.xlsx', 'IRFt', 6);
            tc.verifyClass(s.strctident, 'bear.settings.strctident.StrctidentIRFt6');
        end
        
        function tBVARHyperparamLimits(tc)
            param = ["ar";"lambda1";"lambda2";"lambda3";"lambda4";"lambda5";"lambda6";"lambda7";"lambda8"];
            lowerBound   = [-inf; 0; 0.1; 0; 0; 0; 0; 0; -inf];
            defaultValue = [0.8; 0.1; 0.5; 1; 100; 0.001; 0.1; 0.001; 1];
            upperBound   = [inf; inf; inf; 2; inf; 1; inf; inf; inf];
            
            t = table(param, lowerBound, defaultValue, upperBound);
            s = BEARsettings('bvar', 'ExcelFile', 'data.xlsx');
            
            tc.icheckHyperparamLimits(s, t)
        end
        
        function tPANELHyperparamLimits(tc)
            param = ["ar";"lambda1";"lambda2";"lambda3";"lambda4";"s0";"v0";"alpha0";"delta0";"gamma";"a0";"b0";"rho";"psi"];
            lowerBound   = [-inf; 0; 0.1; 1; 0; -inf; -inf; -inf; -inf; -inf; -inf; -inf; -inf; -inf];
            defaultValue = [0.8; 0.1; 0.5; 1; 100; 0.001; 0.001; 1000; 1; 0.85; 1000; 1; 0.75; 0.1];
            upperBound   = [inf; inf; inf; 2; inf; inf; inf; inf; inf; inf; inf; inf; inf; inf];
            
            t = table(param, lowerBound, defaultValue, upperBound);
            s = BEARsettings('panel', 'ExcelFile', 'data.xlsx');
            
            tc.icheckHyperparamLimits(s, t)
        end
        
        function tSVHyperparamLimits(tc)
            param = ["ar";"lambda1";"lambda2";"lambda3";"lambda4";"lambda5";"gamma";"alpha0";"delta0";"gamma0";"zeta0"];
            lowerBound   = [-inf; 0; 0.1; 1; 0; 0; -inf; -inf; -inf; -inf; -inf];
            defaultValue = [0; 0.2; sqrt(2)/2; 1; 100; 0.001; 1; 0.001; 0.001; 0; 10000];
            upperBound   = [inf; inf; inf; 2; inf; 1; inf; inf; inf; inf; inf];
            
            t = table(param, lowerBound, defaultValue, upperBound);
            s = BEARsettings('sv', 'ExcelFile', 'data.xlsx');
            
            tc.icheckHyperparamLimits(s, t)
        end
        
        function tTVPHyperparamLimits(tc)
            param = ["gamma";"alpha0";"delta0"];
            lowerBound   = [-inf; -inf; -inf];
            defaultValue = [0.85; 0.001; 0.001];
            upperBound   = [inf; inf; inf];
            
            t = table(param, lowerBound, defaultValue, upperBound);
            s = BEARsettings('tvp', 'ExcelFile', 'data.xlsx');
            
            tc.icheckHyperparamLimits(s, t)
        end
        
        function tMFVARHyperparamLimits(tc)
            param = ["ar";"lambda1";"lambda2";"lambda3";"lambda4";"lambda5"];
            lowerBound   = [-inf; 0; 0.1; 1; 0; -inf;];
            defaultValue = [0.9; 0.1; 3.4; 1; 3.4; 14.763158];
            upperBound   = [inf; inf; inf; 2; inf; inf];
            
            t = table(param, lowerBound, defaultValue, upperBound);
            s = BEARsettings('mfvar', 'ExcelFile', 'data.xlsx');
            
            tc.icheckHyperparamLimits(s, t)
        end
        
        function tMustBeInRange(tc)
            
           opts = BEARsettings(2,'ExcelFile','data.xlsx');
            
            fcn = @() setProp(opts, 'lambda3',10);            
            tc.verifyError(fcn, 'MATLAB:validators:mustBeLessThanOrEqual')
            
            fcn = @() setProp(opts, 'lambda3',-10);            
            tc.verifyError(fcn, 'MATLAB:validators:mustBeGreaterThanOrEqual') 
            
        end
    end
    
    methods (Access = private)
        
        function icheckHyperparamLimits(tc, s, t)
            for i = 1 : height(t)
                tc.verifyEqual( s.(t.param(i)), t.defaultValue(i));
                if isinf(t.lowerBound(i))
                    s.(t.param(i)) = -inf;
                    tc.verifyEqual( s.(t.param(i)), -inf );
                else
                    fcn = @() setProp(s, t.param(i), -inf);
                    tc.verifyError(fcn, 'MATLAB:validators:mustBeGreaterThanOrEqual')
                end
                
                if isinf(t.upperBound(i))
                    s.(t.param(i)) = inf;
                    tc.verifyEqual( s.(t.param(i)), inf );
                else
                    fcn = @() setProp(s, t.param(i), inf);
                    tc.verifyError(fcn, 'MATLAB:validators:mustBeLessThanOrEqual')
                end
            end
            
        end
        
    end

end

function s = setProp(s, prop, value)
s.(prop) = value;
end