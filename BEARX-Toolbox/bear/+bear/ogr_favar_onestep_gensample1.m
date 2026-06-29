function [favar] = ogr_favar_onestep_gensample1(favar, meta)

    favar.bnames = sort(unique(meta.ReducibleBlocks));
    favar.nbnames = 1;
    
    favar.blockindex_each{1,1} = strcmp(favar.bnames(1), meta.ReducibleBlocks(:));
        
    % create block specfic data sets
    favar.X_block{1,1} = favar.X(:, favar.blockindex_each{1,1});
    
    blockName = favar.bnames(1);
    numF = meta.NumFactors.(blockName);
    [l, ~, ~, ~, explained] = pca(favar.X_block{1,1}, 'NumComponents', numF);

    %identify factors: normalise loadings, compute factors following BBE 2005
    l = sqrt(size(favar.X_block{1,1},2))*l;
    favar.XZ_block{1,1} = favar.X_block{1,1}*l/size(favar.X_block{1,1},2);

    % percent variability explained by principal components
    favar.bvariaexpl{1,1} = explained(1:numF, 1);
    favar.bsumvariaexpl{1,1} = sum(favar.bvariaexpl{1,1});

    %save the loadings
    favar.l_block{1,1} = l;
 
    %total factors
    favar.l = favar.l_block{1,1};
    favar.XZ = favar.X * favar.l / favar.nfactorvar;   

end
