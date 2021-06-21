classdef StrctidentIRFt4 < bear.settings.Strctident

    properties
        CorrelShock = 'CorrelShock'; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
        CorrelInstrument = 'MHF';    % provide the IV variable in excel sheet "IV"
    end

end