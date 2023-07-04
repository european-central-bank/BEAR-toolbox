classdef tDal < matlab.unittest.TestCase
    
    properties (TestParameter)
        frequency = {'yearly', 'quarterly', 'monthly','weekly', 'daily'}
    end

    properties
        DefaultDal
        Variable (:,1) string = ["YER"; "HICSA"; "STN"];
    end

    methods (TestClassSetup)
        function loadExcel(tc)
            tc.DefaultDal = bear.data.ExcelDAL('default_bear_data.xlsx');
            tc.DefaultDal.reload();
        end
    end

    methods (Test)

        function tDateTime(tc, frequency)
            % Test reading various datetime formats
            orgData = readtable('default_bear_data.xlsx', Sheet = frequency);
            file = tempname + ".xlsx";
            writetable(orgData, file, Sheet = 'data');
            cleanupObj = onCleanup(@() delete(file));

            dal = bear.data.ExcelDAL(file);
            data = dal.Data;
            tc.verifyClass(data, 'timetable');
        end

        function tARPriors(tc)
            tbActual = tc.DefaultDal.ARPriors;
            ARprior = [0.8; 0.6; 0.5];
            tbexpected = table(tc.Variable, ARprior, VariableNames=["Variable", "AR prior"]);
            tc.verifyEqual(tbActual, tbexpected);
        end

        function tExoMeanPriors(tc)
            tbActual = tc.DefaultDal.ExoMeanPriors;
            Constant = zeros(3,1);
            Oil = ones(3,1);
            Variable = tc.Variable; %#ok<PROP>
            tbexpected = table(Variable, Constant, Oil); %#ok<PROP>
            tc.verifyEqual(tbActual, tbexpected);
        end

        function tExoTightPriors(tc)
            tbActual = tc.DefaultDal.ExoTightPriors;
            Constant = 100*ones(3,1);
            Oil = 100*ones(3,1);
            Variable = tc.Variable; %#ok<PROP>
            tbexpected = table(Variable, Constant, Oil); %#ok<PROP>
            tc.verifyEqual(tbActual, tbexpected);
        end

        function tMeanAdjPrior(tc)
            tbActual = tc.DefaultDal.MeanAdjPrior;
            trend = ["1";"1";"1"];
            tPrior = ["1 4"; "1 4"; "2 5"];
            regime1 = ["2008q2 2014q4";"2008q2 2014q4";"2008q2 2014q4"];
            tPrior1 = ["0 1"; "0 2"; "0 3"];
            tbexpected = table(trend,tPrior,regime1, tPrior1, VariableNames=["trend", "trend prior", "regime 1", "trend prior 2"], RowNames=tc.Variable);
            tc.verifyEqual(tbActual, tbexpected);
        end

        function tLongRunPrior(tc)
            tbActual = tc.DefaultDal.LongRunPrior;            
            YER = [1; 0; 0];
            HICSA = [0; 1; -1];
            STN = [0; 1; 1];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tSurveryLocalMean(tc)
            tbActual = tc.DefaultDal.SurveyLocalMean;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyTrue(all(contains(tbActual.Properties.VariableNames, tc.Variable)))
        end

        function tPredExo(tc)
            tbActual = tc.DefaultDal.PredExo;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyTrue(all(contains(tbActual.Properties.VariableNames, [tc.Variable; "Oil"])))
        end

        function tGrid(tc)
            tbActual = tc.DefaultDal.PredExo;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyTrue(all(contains(tbActual.Properties.VariableNames, [tc.Variable; "Oil"])))
        end

        function tBlockExo(tc)
            tbActual = tc.DefaultDal.BlockExo;            
            YER = [NaN; NaN; NaN];
            HICSA = [1; NaN; NaN];
            STN = [1; 1; NaN];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tSignResValues(tc)
            tbActual = tc.DefaultDal.SignResValues;            
            YER = ["+"; "+"; "+"];
            HICSA = ["+"; "-"; missing];
            STN = ["+"; "+"; "-"];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tSignResPeriods(tc)
            tbActual = tc.DefaultDal.SignResPeriods;            
            YER = ["0 0"; "0 0"; "0 0"];
            HICSA = ["0 0"; "0 0"; missing];
            STN = ["1 3"; "0 0"; "0 0"];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tRelmagnResValues(tc)
            tbActual = tc.DefaultDal.RelMagnResValues;            
            YER = [missing; missing; missing];
            HICSA = [missing; missing; missing];
            STN = [missing; missing; missing];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tRelmagnResPeriods(tc)
            tbActual = tc.DefaultDal.RelMagnResPeriods;            
            YER = [missing; missing; "0 0"];
            HICSA = [missing; missing; missing];
            STN = [missing; missing; "0 0"];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tFEVDResValues(tc)
            tbActual = tc.DefaultDal.FEVDResValues;            
            YER = [missing; missing; missing];
            HICSA = [missing; missing; missing];
            STN = [missing; missing; missing];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tFEVDResPeriods(tc)
            tbActual = tc.DefaultDal.FEVDResPeriods;            
            YER = [missing; missing; missing];
            HICSA = [missing; missing; missing];
            STN = [missing; missing; missing];
            tbexpected = table(YER, HICSA, STN, RowNames=tc.Variable);
            tbexpected.Properties.VariableDescriptions = {'demand', 'supply','money'};
            tc.verifyEqual(tbActual(:,1:3), tbexpected)
        end

        function tIV(tc)
            tbActual = tc.DefaultDal.IV;
            tc.verifyClass(tbActual, 'timetable')
        end

        function tConditions(tc)
            tbActual = tc.DefaultDal.Conditions;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyEqual(width(tbActual), numel(tc.Variable))
        end

        function tShocks(tc)
            tbActual = tc.DefaultDal.Shocks;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyEqual(width(tbActual), numel(tc.Variable))
        end

        function tBlocks(tc)
            tbActual = tc.DefaultDal.Blocks;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyEqual(width(tbActual), numel(tc.Variable))
        end

        function tIntervals(tc)
            tbActual = tc.DefaultDal.Shocks;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyEqual(width(tbActual), numel(tc.Variable))
        end

        function tPanPredExo(tc)
            tbActual = tc.DefaultDal.PanelPredExo;
            tc.verifyClass(tbActual, 'timetable')
            tc.verifyTrue(all(contains(tbActual.Properties.VariableNames, "Oil")))
        end


    end

end