classdef OLSVARSettings < bear.settings.BASELINESettings
    
    properties
        strctident
    end
    
    methods
        
        function obj = OLSVARSettings(excelPath, varargin)
            
            obj@bear.settings.BASELINESettings(1, excelPath, varargin{:})
                        
            if obj.IRFt==4
                strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
                % Correlation restriction options:
                strctident.CorrelShock='CorrelShock'; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
                strctident.CorrelInstrument='MHF'; % provide the IV variable in excel sheet "IV"
            elseif obj.IRFt==5
                % IV options:
                strctident.Instrument='MHF';% specify Instrument to identfy Shock
                strctident.startdateIV='1992m2';
                strctident.enddateIV='2003m12';
                strctident.bootstraptype=1; %1=wild bootstrap Mertens&Ravn(2013), 2=moving block bootstrap Jentsch&Lunsford(2018)
            elseif obj.IRFt==6
                strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
                % IV options:
                strctident.Instrument='MHF';% specify Instrument to identfy Shock
                strctident.startdateIV='1992m2';
                strctident.enddateIV='2003m12';
                strctident.bootstraptype=1; %1=wild bootstrap Mertens&Ravn(2013), 2=moving block bootstrap Jentsch&Lunsford(2018)
                strctident.TakeOLS=0; %only for IRFt6, OLS D and median irf_estimates
                % Correlation restriction options:
                strctident.CorrelShock='CorrelShock'; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
                strctident.CorrelInstrument='MHF'; % provide the IV variable in excel sheet "IV"
            end
            
            obj.strctident = strctident;
            
            obj = parseBEARSettings(obj, varargin{:});
            
        end
        
    end
end