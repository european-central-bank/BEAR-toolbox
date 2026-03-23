
function [favar] = initializeFAVAROneStep(meta, longYX, longZ)

    longY = longYX{1};
    p = meta.Order;


    if strcmp(meta.BlockType, "blocks")
       favar.blocks = true;
    elseif strcmp(meta.BlockType, "slowfast")
       favar.blocks = false;
    end

    favar.nfactorvar = meta.NumReducibleNames;

    [favar.X_std, favar.X_mean] = std(longZ, 0, 1);

    favar.X_dm = longZ - favar.X_mean;

    favar.X = favar.X_dm./ favar.X_std;

    [favar.Y_std, favar.Y_mean] = std(longY, 0, 1);

    favar.Y_dm = longY - favar.Y_mean;

    favar.Y = (longY - favar.Y_mean) ./ favar.Y_std;


    favar.numpc = meta.NumFactorNames;

    %gensample 1
    [favar] = bear.ogr_favar_onestep_gensample1(favar, meta);

    %gensample2
    endo = [meta.FactorNames, meta.EndogenousNames];
    [data, favar] = bear.ogr_favar_onestep_gensample2(favar.Y, endo, p, favar);

    % gensample 3
    [favar] = bear.ogr_favar_onestep_gensample3(data, favar);

end%

