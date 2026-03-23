
function tbx = setCheckConsistency(tbx, func)
    try
        tbx = addprop(tbx, "CheckConsistency", "table");
    end
    tbx.Properties.CustomProperties.CheckConsistency = func;
end%

