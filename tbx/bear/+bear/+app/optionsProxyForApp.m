classdef optionsProxyForApp < matlab.mixin.SetGet
    
    properties (Access = private)
        OLS      = BEARsettings('OLS',   'ExcelFile', 'data.xlsx')
        BVAR     = BEARsettings('BVAR',  'ExcelFile', 'data.xlsx')
        PANEL    = BEARsettings('Panel', 'ExcelFile', 'data.xlsx')
        SV       = BEARsettings('SV',    'ExcelFile', 'data.xlsx')
        TVP      = BEARsettings('TVP',   'ExcelFile', 'data.xlsx')
        MFVAR    = BEARsettings('MFVAR', 'ExcelFile', 'data.xlsx')
    end
    
    properties
        VARtype (1,1) bear.VARtype = 2;
    end
    
    properties (Dependent)
        opts
    end
    
    methods
        function value = get.opts(obj)
            value = obj.(string(obj.VARtype));
        end
        
        function set.opts(obj, value)
           obj.(string(obj.VARtype)) = value;
        end
        
        function setCommonProp(obj, prop, value)            
            % Sets common property to all of the classes
            e = enumeration('bear.VARtype');
            for i = 1 : numel(e)
                vt = string(e(i));
                if isprop(obj.(vt), prop)
                    obj.(vt).(prop) = value;
                end                
            end
        end
        
        function setProp(obj, prop, value)
            % Sets property just for a class
            obj.opts.(prop) = value;
        end
    end
end