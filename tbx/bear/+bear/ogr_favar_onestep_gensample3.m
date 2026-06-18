function [favar] = ogr_favar_onestep_gensample3(data_endo, favar)

    % determine the numbers of variables other than factors
    favar.numdata_exfactors = size(favar.data_exfactors, 2);

    % initalise variables
    XZ = favar.XZ;
    nfactorvar = favar.nfactorvar;
    numpc = favar.numpc;
    Lf = favar.l;
    % identify factors in the case of onestep estimation: rotate the
    % factors and the loadings matrix following Bernanke, Boivin, Eliasz (2005)
    Lfy = bear.favar_olssvd(favar.X(:, numpc+1:nfactorvar), data_endo)';% upper KxM block of Ly set to zero
    Lf = [Lf(1:numpc,:);Lfy(:,1:numpc)];
    Ly = [zeros(numpc,favar.numdata_exfactors);Lfy(:,numpc+1:numpc+favar.numdata_exfactors)];
    
    %transform factors and loadings for LE normalization
    [ql,rl] = qr(Lf');
    Lf = rl;  % do not transpose yet, is upper triangular
    XZ = XZ*ql;
    %need identity in the first K columns of Lf, call them A for now
    A = Lf(:,1:numpc); %index here for factors
    Lf = [eye(numpc), A\Lf(:,numpc+1:nfactorvar)]';
    favar.XZ_rotated = XZ*A;
    
    %rotated loadings
    favar.L = [Lf Ly;zeros(favar.numdata_exfactors,numpc),eye(favar.numdata_exfactors)];
    
    %replace factors with factors rotated in data_endo
    for ii = 1:numel(favar.variablestrings_factorsonly)
        data_endo(:,favar.variablestrings_factorsonly(ii)) = favar.XZ_rotated(:,ii);
    end
    
    %errors of factor equation (observation equation)
    if favar.numdata_exfactors~=0
        favar.evf = favar.X - favar.data_exfactors*Ly'- favar.XZ_rotated*Lf';
    elseif favar.numdata_exfactors==0 % in this case we have a pure factor model
        favar.evf = favar.X -favar.XZ_rotated*Lf';
    end
  
    %favar.evf=favar.XY-data_endo*favar.L';
    tmp = favar.evf'*favar.evf/size(favar.X,1);
    tmp = diag(diag(tmp));
    favar.Sigma = diag([diag(tmp);zeros(favar.numdata_exfactors,1)]);

    % % from here proceed with non-standardised data
    favar.data_exfactors = favar.Y_dm;
    favar.X = favar.X_dm;
    % 
    % % replace standardised data with not-standardised data in endo
    for ii=1:numel(favar.variablestrings_exfactors)
         data_endo(:,favar.variablestrings_exfactors(ii))=favar.data_exfactors(:,ii);
    end
    
    % state-space representation
    favar.XY = [favar.X, favar.data_exfactors];

    favar.FY = data_endo;

end
