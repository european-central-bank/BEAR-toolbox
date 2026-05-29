function [favar,favar_hd_estimates]=favar_hdestimates(favar,hd_estimates,n,IRFt,endo,strctident,L_g)

%% prelim
% number of identified shocks & create labels for the contributions
if IRFt==1||IRFt==2||IRFt==3
    identified=n; % fully identified
    labels=endo;
elseif IRFt==4 || IRFt==6 %if the model is identified by sign restrictions or sign restrictions (+ IV)
    identified=size(strctident.signreslabels_shocks,1); % count the labels provided in the sign res sheet (+ IV)
    labels=strctident.signreslabels_shocks; % signreslabels
elseif IRFt==5
    identified=1; % one IV shock
    labels{identified,1}=strcat('IV Shock (',strctident.Instrument,')'); % one label for the IV shock
end

% if favar.onestep==1
%     
% else
%     L=favar.L(favar.plotX_index,:);
% end

L=L_g;

% if the number of identified shocks is smaller than the number endo
% variables (not fully identified) and we have blocks, (and sum the
% shock contributions) then we have to compute blocks_index_shocks, to
% know to which blocks the shocks are assigned to, this is identified
% analogue to the Factors by checking for 'Blockidentifier'. [favar.bnames{jj,1} '.']&& identified<n
% endo_exfactors=endo(favar.variablestrings_exfactors);
if favar.blocks==1
    for jj=1:favar.nbnames
        for ii=1:size(labels,1)
            %for ll=1:favar.bnumpc{jj,1}
            %blocks_indexlogical{jj,1}(ll,ii)=strcmp(endo{ii,1},favar.factorlabels_blocks{jj,ll});
            blocks_indexlogical_shocks{jj,1}(ii,1)=contains(labels{ii,1},[favar.bnames{jj,1} '.'])==1;%((ll,ii))
            %end
        end
        %blocks_indexlogical{jj,1}=sum(blocks_indexlogical{jj,1},1);
        favar.blocks_index_shocks{jj,1}=find(blocks_indexlogical_shocks{jj,1}==1);
    end
%     nbnames_shocks=size(favar.blocks_index_shocks,1)
end

% favar.HD.sumShockcontributions=0;

    for jj=1:favar.npltX %for selected information variables
        for ii=1:n %for variables
            for ll=1:n%size(hd_estimates,1) %for shock contributions
                favar_hd_estimates{ll,ii,jj}(1,:)=hd_estimates{ll,ii}(2,:)*L(jj,ii);%summed over variables {ll,ii,jj} %%% summed over contributions {ii,ll,jj}
            end
        end
        
        for ll=n+1:size(hd_estimates,1) %for the rest of the contributions
            for ii=1:n %for variables
                favar_hd_estimates{ll,ii,jj}(1,:)=hd_estimates{ll,ii}(2,:)*L(jj,ii);
            end
        end
    end
