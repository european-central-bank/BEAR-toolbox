classdef optionsProxyForApp < matlab.mixin.SetGet
    
    properties (Access = private)
        OLS      = BEARsettings('OLS',   'ExcelPath', 'data.xlsx')
        BVAR     = BEARsettings('BVAR',  'ExcelPath', 'data.xlsx')
        PANEL    = BEARsettings('Panel', 'ExcelPath', 'data.xlsx')
        SV       = BEARsettings('SV',    'ExcelPath', 'data.xlsx')
        TVP      = BEARsettings('TVP',   'ExcelPath', 'data.xlsx')
    end
    
    properties
        VARtype (1,1) bear.VARtype = 1;
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
        
        function setProp(obj, prop, value)
            % Sets common property to all of the classes
            e = enumeration('bear.VARtype');
            for i = 1 : numel(e)
                vt = string(e(i));
                if isprop(obj.(vt), prop)
                    obj.(vt).(prop) = value;
                end                
            end
        end
    end
end