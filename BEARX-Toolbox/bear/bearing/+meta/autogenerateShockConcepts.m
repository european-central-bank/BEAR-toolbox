
function shockConcepts = autogenerateShockConcepts(numEndogenous)

    arguments
        numEndogenous (1, 1) {mustBeInteger, mustBePositive}
    end

    shockConcepts = "shock" + string(1:numEndogenous);

end%

