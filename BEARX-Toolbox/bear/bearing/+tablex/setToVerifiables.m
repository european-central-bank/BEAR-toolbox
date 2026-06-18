
function tbx = setToVerifiables(tbx, func)
    try
        tbx = addprop(tbx, "ToVerifiables", "table");
    end
    tbx.Properties.CustomProperties.ToVerifiables = func;
end%

