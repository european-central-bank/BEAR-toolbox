
function testStrings = testStringsFromMarkdown(filePath)

    fileContent = textual.read(filePath);
    testStrings = extractBetween(fileContent, "```", "```");
    testStrings = strip(split(testStrings, newline()));
    testStrings = removeEnclosingDoubleQuote_(testStrings);
    testStrings(testStrings == "") = [];

end%


function strings = removeEnclosingDoubleQuote_(strings)
    %[
    chars = cellstr(strings);
    for i = 1 : numel(chars)
        if startsWith(chars{i}, '"')
            chars{i} = chars{i}(2:end);
        end
        if endsWith(chars{i}, '"')
            chars{i} = chars{i}(1:end-1);
        end
    end
    strings = strip(string(chars));
    %]
end%
