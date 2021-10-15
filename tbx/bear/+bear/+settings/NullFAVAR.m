classdef NullFAVAR < matlab.mixin.CustomDisplay
    
    methods (Access = protected)
        
       function displayScalarObject(~)
           fprintf('FAVAR is undefined for this prior type \n');
       end
       
    end
    
end