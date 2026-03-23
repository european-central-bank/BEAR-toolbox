
classdef (CaseInsensitiveProperties=true) CCMMSVO ...
    < base.estimator.settings.CCMMSV

    properties
        % Mean outlier frequency: one outlier every X years
        OutlierFreq (1,1) double = 10 %mean outlier frequency: the value means one outlier in every X years, CCMM 3.2, originally Stock-Watson(2016)    

        % Outlier prior strength: precision matches X years of prior data
        PriorObsYears (1,1) double = 10 %controls the strength of the outlier prior, precision set to be consistent with X years’ worth of prior observations
        %CCMM 3.2, originally Stock-Watson(2016)   
    end

end

