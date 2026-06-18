%
% VerifiableTests  Container for verifiable test functions
%

classdef VerifiableTests ...
    < handle

    properties (Constant)
        TEST_FUNC_ARG_NAME = "x"
    end

    properties
        TestStrings (1, :) string
    end

    methods
        function this = VerifiableTests(testStrings)
            arguments
                testStrings (1, :) string
            end
            this.TestStrings = testStrings;
        end%

        function [func, occurrence, funcString] = buildTestEnvironment(this, meta)
            testStrings = this.TestStrings;
            testStrings = this.resolveNames(testStrings, meta);
            testStrings = this.resolveDates(testStrings, meta);
            [testStrings, occurrence] = this.resolvePropertyReferences(testStrings);
            %
            % Long circuit test function - needed for sign flipping
            funcString = "@(" + this.TEST_FUNC_ARG_NAME + ")[" + join(testStrings, "; ") + "]";
            func = str2func(funcString);
        end%

        function status = evaluateAll(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            status = this.TestFunctionAll(verifiableProperties);
        end%


        function status = evaluateShortCircuit(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            status = false(1, 1);
            status(1) = this.TestFunctionShortCircuit(verifiableProperties);
        end%
    end

    methods
        function testStrings = resolveNames(this, testStrings, meta)
            dict = struct();
            dict = textual.createDictionary(meta.SeparableShockNames, dict);
            dict = textual.createDictionary(meta.SeparableEndogenousNames, dict);
            function y = replaceName(x)
                % Remove the leading and trailing single quotes
                modelName = x(2:end-1);
                try
                    y = string(dict.(modelName));
                catch
                    error("Reference to an unkonwn name in the test string: %s", modelName);
                end
            end%
            replaceNameFunc = @replaceName;
            testStrings = regexprep(testStrings, "'\<[a-zA-Z]\w*\>'", "${replaceNameFunc($0)}");
        end%

        function testStrings = resolveDates(this, testStrings, meta)
        % Replace any occurrence of 'XXXX', 'XXXX-AX', 'XXXX-AX' (X is a
        % digit, A is a letter) with the number of periods from the start of
        % the short estimation span.
            shortStart = meta.ShortStart;
            function y = replaceDate(x)
                % Remove the leading and trailing single quotes
                x = x(2:end-1);
                y = string(datex.diff(datex.fromSdmx(x), shortStart) + 1);
            end%
            replaceDateFunc = @replaceDate;
            testStrings = regexprep(testStrings, "'\<[0-9]{4}(\-\w[0-9]{1,2})?\>'", "${replaceDateFunc($0)}");
        end%

        function [testStrings, occurrence] = resolvePropertyReferences(this, testStrings)
            occurrence = initializeOccurrenceStruct();
            argName = this.TEST_FUNC_ARG_NAME;
            %
            function y = replaceProperty(x)
                % Remove the leading dollar sign, e.g. $SHKRESP -> SHKRESP
                propertyName = string(x(2:end));
                occurrence.(propertyName) = {};
                y = argName + "." + propertyName;
            end%
            %
            replacePropertyFunc = @replaceProperty;
            testStrings = regexprep(testStrings, "\$\w+", "${replacePropertyFunc($0)}");
            %
            occurrence = resolveDependencies(occurrence);
            occurrence = pruneOccurrence(occurrence);
        end%
    end

end


function occurrence = initializeOccurrenceStruct()
    occurrence = struct();
    occurrence.SHKRESP = false;
    occurrence.SHKEST = false;
    occurrence.SHKCONT = false;
    occurrence.FEVD = false;
end%


function occurrence = resolveDependencies(occurrence)
    if isfield(occurrence, "FEVD")
        occurrence.SHKRESP = {};
    end
    if isfield(occurrence, "SHKCONT")
        occurrence.SHKEST = {};
    end
end%


function occurrence = pruneOccurrence(occurrence)
    remove = string.empty(1, 0);
    for n = textual.fields(occurrence)
        if isequal(occurrence.(n), false)
            remove(end+1) = n;
        end
    end
    if ~isempty(remove)
        occurrence = rmfield(occurrence, remove);
    end
end%

