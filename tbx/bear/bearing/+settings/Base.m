
% settings.Base  Base class for settings classes

classdef (CaseInsensitiveProperties=true) Base < handle

    methods
        function this = Base(varargin)
            this.modifyDefaults();
            for i = 1:2:numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
            this.postprocessSettings();
        end%
    end

    methods
        function modifyDefaults(this)
        end%

        function postprocessSettings(this)
        end%
    end

end

