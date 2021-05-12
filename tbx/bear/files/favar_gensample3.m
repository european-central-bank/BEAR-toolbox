function [data_endo,favar]=favar_gensample3(data_endo,favar)

% determine the numbers of variables other than factors
favar.numdata_exfactors=size(favar.data_exfactors,2);

if favar.onestep==1
    % initalise variables
    XZ=favar.XZ;
    nfactorvar=favar.nfactorvar;
    numpc=favar.numpc;
    Lf=favar.l;
    % identify factors in the case of onestep estimation: rotate the
    % factors and the loadings matrix following Bernanke, Boivin, Eliasz (2005)
    Lfy=favar_olssvd(favar.X(:,numpc+1:nfactorvar),data_endo)';% upper KxM block of Ly set to zero
    Lf=[Lf(1:numpc,:);Lfy(:,1:numpc)];
    Ly=[zeros(numpc,favar.numdata_exfactors);Lfy(:,numpc+1:numpc+favar.numdata_exfactors)];
    
    %transform factors and loadings for LE normalization
    [ql,rl]=qr(Lf');
    Lf=rl;  % do not transpose yet, is upper triangular
    XZ=XZ*ql;
    %need identity in the first K columns of Lf, call them A for now
    A=Lf(:,1:numpc); %index here for factors
    Lf=[eye(numpc),inv(A)*Lf(:,numpc+1:nfactorvar)]';
    favar.XZ_rotated=XZ*A;
    
    %rotated loadings
    favar.L=[Lf Ly;zeros(favar.numdata_exfactors,numpc),eye(favar.numdata_exfactors)];
    
    %replace factors with factors rotated in data_endo
    for ii=1:size(favar.variablestrings_factorsonly)
        data_endo(:,favar.variablestrings_factorsonly(ii))=favar.XZ_rotated(:,ii);
    end
    
    %errors of factor equation (observation equation)
    if favar.numdata_exfactors~=0
        favar.evf=favar.X-favar.data_exfactors*Ly'-favar.XZ_rotated*Lf';
    elseif favar.numdata_exfactors==0 % in this case we have a pure factor model
        favar.evf=favar.X-favar.XZ_rotated*Lf';
    end
    %favar.evf=favar.XY-data_endo*favar.L';
    favar.Sigma=favar.evf'*favar.evf/size(favar.X,1);
    favar.Sigma=diag(diag(favar.Sigma));
    favar.Sigma=diag([diag(favar.Sigma);zeros(favar.numdata_exfactors,1)]);
    
    % from here proceed with non-standardised data
    favar.data_exfactors=favar.data_exfactors_temp;
    favar.X=favar.X_temp;
    
    % replace standardised data with not-standardised data in endo
    for ii=1:size(favar.variablestrings_exfactors)
        data_endo(:,favar.variablestrings_exfactors(ii))=favar.data_exfactors(:,ii);
    end
    
    % state-space representation
    favar.XY=[favar.X,favar.data_exfactors];
    
elseif favar.onestep==0 % two-step
    if favar.numdata_exfactors==0
        favar.slowfast=0; % this identifiaction is not applicable in a pure factor model
    end
    if favar.slowfast==1 %apply slowfast recursive identification as in BBE (2005)
        % factor roation with slow/fast scheme
        favar.XZ_rotated=favar_facrot(favar.XZ,favar.data_exfactors(:,end),favar.XZ_slow); %end, has eventually to be changed
        %replace factors with factors rotated
        for ii=1:size(favar.variablestrings_factorsonly)
            data_endo(:,favar.variablestrings_factorsonly(ii))=favar.XZ_rotated(:,ii);
        end
    end
    % state-space representation
    favar.XY=[favar.X,favar.data_exfactors];
    % new loadings
    favar.L=(favar_olssvd(favar.XY,data_endo))';
    % manipulate loadings matrix for blocks
    if favar.blocks==1
        for bb=1:favar.nbnames
            Xbindex=favar.blockindex_each{bb,1};
            Xbindex2=favar.blockindex_each{bb,1}==0;
            %
            favar.L(Xbindex,favar.blocks_index{bb,1})=favar.l_block{bb,1};
            favar.L(Xbindex2,favar.blocks_index{bb,1})=0;
            favar.L(1:favar.nfactorvar,favar.variablestrings_exfactors)=0;
            favar.L(favar.nfactorvar+1:end,favar.variablestrings_factorsonly)=0;
        end
        for vv=1:favar.numdata_exfactors
            favar.L(favar.nfactorvar+1:end,favar.variablestrings_exfactors(vv,1))=1;
        end
    end
    
    %errors of factor equation (observation equation)
    favar.evf=favar.XY-data_endo*favar.L';
    favar.Sigma=favar.evf'*favar.evf/size(favar.XY,1); %
    favar.Sigma=diag(diag(favar.Sigma));
end

% to activate routines in the BVAR framwork and IRFt 4, where we have It-Bu
% x X, Y and L
favar.bvar=1;
%%% this should be equivalent
%regressing the factors from all x on the slow moving factors and the FFR
% % %         favar.Beta = mvregress(data_endo,favar.XZ);
% % %         favar.Beta_exfactors = favar.Beta(favar.variablestrings_exfactors(:,end),:); %we assume here that favar.variablestrings_exfactors, all the variables that are not factors, are
% % %         favar.Frot=favar.XZ-favar.data_endo(:,favar.variablestrings_exfactors(:,end))*favar.Beta_exfactors;

