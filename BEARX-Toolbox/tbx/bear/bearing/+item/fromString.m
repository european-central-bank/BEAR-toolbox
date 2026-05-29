
function outItem = fromString(inputString)

    arguments
        inputString (1, 1) string
    end

    inputString = strip(inputString);
    if item.isSpecial(inputString)
        outItem = item.createSpecial(extractAfter(inputString, 1));
    else
        outItem = item.Variable(inputString);
    end

end%
