function [cfcondsFull, cfshocksFull, cfblocksFull] = set_conditions_example(panel, CFt, Fperiods, metaR)

    % initialize
    cfcondsFull = {};
    cfshocksFull = {};
    cfblocksFull = [];

    if panel == 2
        cfcondsFull = cell(Fperiods, metaR.NumEndogenousConcepts, metaR.NumUnits);
        if CFt == 2
            cfshocksFull = cell(Fperiods, metaR.NumEndogenousConcepts, metaR.NumUnits);
            cfblocksFull = zeros(Fperiods, metaR.NumEndogenousConcepts, metaR.NumUnits);
        end
    else
        cfcondsFull = cell(Fperiods, metaR.NumEndogenousNames);
        if CFt == 2
            cfshocksFull = cell(Fperiods, metaR.NumEndogenousNames);
            cfblocksFull = zeros(Fperiods, metaR.NumEndogenousNames);
        end
    end

    % set conditional forecast value for US CPI for 3 quarters to 3%
    % US_HICP
    if panel == 2
        cfcondsFull(1:3,2,1) = {3};
    else
        cfcondsFull(1:3,2) = {3};
    end

    % set conditional forecast value for EA GDP for 6 quarters to 2%
    % EA_YER
    if panel == 2
        cfcondsFull(1:6,1,2) = {2};
    else
        cfcondsFull(1:6,4) = {2};
    end

    if CFt == 2
        % select shocks for explaining US CPI (CPI and IR)
        if panel == 2
            cfshocksFull(1:3,2,1) = {[2 3]};
            cfblocksFull(1:3,2,1) = 1;
        else
            cfshocksFull(1:3,2) = {[2 3]};
            cfblocksFull(1:3,2) = 1;
        end

        % select shocks for explaining EA GDP (IR and YER)
        if panel == 2
            cfshocksFull(1:6,1,2) = {[1]};
            cfblocksFull(1:6,1,2) = 1;
        else
            cfshocksFull(1:6,4) = {[1]};
            cfblocksFull(1:6,4) = [2;2;2;1;1;1];
        end
    end 
end
