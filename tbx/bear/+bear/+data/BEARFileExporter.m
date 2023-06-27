classdef (Abstract) BEARFileExporter < bear.data.BEARExporter

    properties (Abstract)
        FileName (1,1) string
    end

end