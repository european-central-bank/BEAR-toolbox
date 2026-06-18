
function out = isMixedFrequency()

    module = gui.getCurrentModule();
    out = lower(module) == lower("mixed");

end%

