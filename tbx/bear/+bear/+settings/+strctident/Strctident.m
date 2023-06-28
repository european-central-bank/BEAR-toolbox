classdef Strctident

    properties
        MM = 0; % option for Median model (0=no (standard), 1=yes)
    end

    methods 

        function obj = Strctident(str)

            if nargin > 0 && ~isempty(str)
                
                for prop = properties(str)'

                    if isprop(obj, prop{1})

                        obj.(prop{1}) = str.(prop{1});

                    end

                end
                
            end

        end

    end

end
