classdef optionsProxyForApp < matlab.mixin.SetGet
    
    properties (Access = private)
        OLS     (1,1) bear.settings.OLSsettings   = BEARsettings('OLS',   'ExcelFile', 'data.xlsx')
        BVAR    (1,1) bear.settings.BVARsettings  = BEARsettings('BVAR',  'ExcelFile', 'data.xlsx')
        PANEL   (1,1) bear.settings.PANELsettings = BEARsettings('Panel', 'ExcelFile', 'data.xlsx')
        SV      (1,1) bear.settings.SVsettings    = BEARsettings('SV',    'ExcelFile', 'data.xlsx')
        TVP     (1,1) bear.settings.TVPsettings   = BEARsettings('TVP',   'ExcelFile', 'data.xlsx')
        MFVAR   (1,1) bear.settings.MFVARsettings = BEARsettings('MFVAR', 'ExcelFile', 'data.xlsx')
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
            obj.VARtype = value.VARtype;
            obj.(string(obj.VARtype)) = value;
            
            % Get base properties
            meta = ?bear.settings.BASEsettings;                        
            baseProps = {meta.PropertyList.Name};
            
            for p = baseProps
                if ~ismember(p, {'VARtype','FEVDinternal','HDinternal'})
                    obj.setCommonProp(p{1}, value.(p{1}));
                end
            end
        end
        
        function setCommonProp(obj, prop, value)
            % Sets common property to all of the classes
            e = enumeration('bear.VARtype');
            for i = 1 : numel(e)
                vt = string(e(i));
                if isprop(obj.(vt), prop)
                    try
                        obj.(vt).(prop) = value;
                    catch ME
                        if isequal(e(i), obj.opts.VARtype)
                            error('bear:app:optionsProxyForApp:WrongSetting', "Unable to set property in " + vt + ". Reason: " + ME.message)
                        else
                            warning('bear:app:optionsProxyForApp:WrongSettingInUnselectedVARtype', ...
                                "Unable to set property in " + vt + ". Reason: " + ME.message)
                        end
                    end
                    
                end
            end
        end
        
        function setProp(obj, prop, value)
            % Sets property just for a class
            obj.opts.(prop) = value;
        end
    end
end