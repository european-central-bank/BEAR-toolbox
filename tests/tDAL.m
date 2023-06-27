classdef tDAL < matlab.unittest.TestCase
    
    properties (TestParameter)
        frequency = {'yearly', 'quarterly', 'monthly','weekly', 'daily'}
    end

    methods (Test)

        function tDateTime(tc, frequency)
            orgData = readtable('default_bear_data.xlsx', Sheet = frequency);
            file = tempname + ".xlsx";
            writetable(orgData, file, Sheet = 'data');
            cleanupObj = onCleanup(@() delete(file));

            dal = bear.data.ExcelDAL(file);
            data = dal.Data;
            tc.verifyClass(data, 'timetable');
        end
    end
end