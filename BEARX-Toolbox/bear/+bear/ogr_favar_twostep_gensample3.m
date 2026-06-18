function [favar] = ogr_favar_twostep_gensample3(data_endo, favar)

    % determine the numbers of variables other than factors
    favar.numdata_exfactors = size(favar.data_exfactors, 2);

    if favar.numdata_exfactors == 0
        favar.blocks = true; % slowfast identifiaction is not applicable in a pure factor model
    end
    
    if ~favar.blocks  %apply slowfast recursive identification as in BBE (2005)
        % factor roation with slow/fast scheme
        favar.XZ_rotated = bear.favar_facrot(favar.XZ, favar.data_exfactors(:,end), favar.XZ_slow); %end, has eventually to be changed
        %replace factors with factors rotated
        for ii=1:size(favar.variablestrings_factorsonly)
            data_endo(:,favar.variablestrings_factorsonly(ii)) = favar.XZ_rotated(:,ii);
        end
    end
    
    % state-space representation
    favar.XY = [favar.X, favar.data_exfactors];
    
    % new loadings
    favar.L = (bear.favar_olssvd(favar.XY,data_endo))';
    
    % manipulate loadings matrix for blocks
    for bb = 1:favar.nbnames
        Xbindex = favar.blockindex_each{bb,1};
        Xbindex2 = favar.blockindex_each{bb,1} == 0;
        %
        favar.L(Xbindex,favar.blocks_index{bb,1}) = favar.l_block{bb,1};
        favar.L(Xbindex2,favar.blocks_index{bb,1}) = 0;
        favar.L(1:favar.nfactorvar,favar.variablestrings_exfactors) = 0;
        favar.L(favar.nfactorvar+1:end,favar.variablestrings_factorsonly) = 0;
    end

    for vv = 1:favar.numdata_exfactors
        favar.L(favar.nfactorvar+1:end,favar.variablestrings_exfactors(vv,1)) = 1;
    end
   
    %errors of factor equation (observation equation)
    favar.evf = favar.XY - data_endo*favar.L';
    tmp = favar.evf'*favar.evf/size(favar.XY,1); %
    favar.Sigma = diag(diag(tmp));

    favar.FY = data_endo;

end
