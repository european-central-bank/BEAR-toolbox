
function code = replaceInCode(code, place)

    function ph = createPlaceholderString(name)
        ph = "?" + name + "?";
    end%

    for n = textual.fields(place)
        ph = createPlaceholderString(n);
        code = replace(code, ph, place.(n));
    end

end%
