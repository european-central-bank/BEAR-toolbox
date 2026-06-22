classdef NullFAVAR < matlab.mixin.CustomDisplay
    
    methods (Access = protected)
        
       function displayScalarObject(~)
           fprintf('FAVAR is undefined for this VAR subtype \n');
       end
       
    end
    
end