function [favar] = ogr_favar_gensample1(favar, meta)

    favar.bnames = sort(unique(meta.ReducibleBlocks));
    favar.nbnames = numel(favar.bnames);
    
    for ii = 1:favar.nbnames
        favar.blockindex_each{ii,1} = strcmp(favar.bnames(ii), meta.ReducibleBlocks(:));
    end
    
    % create block specfic data sets
    for ii = 1:favar.nbnames
        favar.X_block{ii,1} = favar.X(:, favar.blockindex_each{ii,1});
    end
    
    if favar.blocks
    
        % create block specific PC factors of X and specific numPC per block
        for ii = 1:favar.nbnames

            blockName = favar.bnames(ii);
            numF = meta.NumFactors.(blockName);
            [l, ~, ~, ~, explained] = pca(favar.X_block{ii,1}, 'NumComponents', numF);
    
            %identify factors: normalise loadings, compute factors following BBE 2005
            l = sqrt(size(favar.X_block{ii,1},2))*l;
            favar.XZ_block{ii,1} = favar.X_block{ii,1}*l/size(favar.X_block{ii,1},2);
    
            % percent variability explained by principal components
            favar.bvariaexpl{ii,1} = explained(1:numF, 1);
            favar.bsumvariaexpl{ii,1} = sum(favar.bvariaexpl{ii,1});
    
            %save the loadings
            favar.l_block{ii,1} = l;
    
        end

        if favar.nbnames == 1
           
            %total factors
            [favar.l] = favar.l_block{1,1};
            favar.XZ = favar.X * favar.l / favar.nfactorvar;
        
        end
    
    else

        numF = meta.NumFactors.slow;
        [favar.l_slow] = pca(favar.X_block{2,1},'NumComponents', numF);
    
        %identify factors: normalise loadings, compute factors following BBE 2005
        favar.l_slow = sqrt(size(favar.X_block{2,1},2))*favar.l_slow;
        favar.XZ_slow = favar.X_block{2,1}*favar.l_slow/size(favar.X_block{2,1},2);
    
        %total factors
        [favar.l] = pca(favar.X,'NumComponents', numF);
        %identify factors: normalise loadings, compute factors following BBE 2005
        favar.l = sqrt(favar.nfactorvar) * favar.l;
        favar.XZ = favar.X * favar.l / favar.nfactorvar;
    
    end

end
