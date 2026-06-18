
classdef MatlabToScript

    methods (Static)
        function script = name(matlab)
            script = gui.MatlabToScript.string(matlab);
        end%

        function script = names(matlab)
            arguments
                matlab (1, :) string
            end
            if isempty(matlab)
                script = "[]"; %"string.empty(1, 0)";
                return
            end
            script = """" + matlab + """";
            if numel(matlab) > 1
                script = join(script, ", ");
                script = "[" + script + "]";
            end
        end%

        function script = string(matlab)
            arguments
                matlab (1, 1) string
            end
            script = """" + matlab + """";
        end%

        function script = number(matlab)
            arguments
                matlab double {mustBeScalarOrEmpty(matlab)} = []
            end
            if isempty(matlab)
                script = "NaN";
                return
            end
            script = gui.MatlabToForm.number(matlab);
        end%

        function script = numbers(matlab)
            arguments
                matlab (1, :) double = []
            end
            script = gui.MatlabToForm.numbers(matlab);
            if numel(matlab) > 1
                script = "[" + script + "]";
            end
        end%

        function script = logical(matlab)
            script = string(gui.isTrue(matlab));
        end%

        function script = logicals(matlab)
            script = gui.MatlabToForm.logicals(matlab);
            if numel(matlab) > 1
                script = "[" + script + "]";
            end
        end%

        function script = date(matlab)
            arguments
                matlab (1, 1) string
            end
            script = gui.MatlabToScript.dates(matlab);
        end%

        function script = dates(matlab)
            arguments
                matlab (:, :) string
            end
            script = reshape(strip(matlab), 1, []);
            script = compose("datex(""%s"")", script);
            if numel(matlab) > 1
                script = "[" + join(script, ", ") + "]";
            end
        end%

        function script = span(matlab)
            arguments
                matlab (1, :) string {mustBeNonempty}
            end
            script = sprintf("datex.span(""%s"", ""%s"")", matlab(1), matlab(end));
        end%

        function script = filename(matlab)
            script = gui.MatlabToScript.string(matlab);
        end%
    end

end

