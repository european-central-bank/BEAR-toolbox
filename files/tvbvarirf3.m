function [irf_record_allt,favar]=tvbvarirf3(beta_gibbs,sigma_t_gibbs,IRFt,It,Bu,IRFperiods,n,m,p,k,T,favar)


% Favar preliminaries
if favar.FAVAR==1
    signresX_index=[];
    npltX=favar.npltX;
    if npltX>0
        favar_FAVAR=1;
        plotX_index=favar.plotX_index;
    else
        favar_FAVAR=0;
        plotX_index=[];
    end
    %relevant loadings
    relLindex=[signresX_index;plotX_index];
    % reshape the L gibbs draws
    Lgibbs=reshape(favar.L_gibbs,size(favar.L,1),size(favar.L,2),It-Bu);
    Lgibbs=Lgibbs(relLindex,:,:);
else
    npltX=0;
    favar_FAVAR=0;
    Lgibbs=NaN;
end


% create the cell aray that will store the values from the simulations
irf_record_allt=cell(n,n);
favar.IRF.favar_irf_record_allt=cell(npltX,n);

% loop over sample periods
for tt=1:T
    % loop over iterations
    for jj=1:It-Bu
        % draw beta
        beta=beta_gibbs{tt}(:,jj);
        sigma=sigma_t_gibbs{tt}(:,:,jj);
        if favar_FAVAR==1
            Lg=squeeze(Lgibbs(:,:,It-Bu)); % this is different for IRFt4, we need to record the index there and adjust the case
        end
        if IRFt==1
            D=eye(n);
        elseif IRFt==2
            D=chol(nspd(sigma),'lower');
        elseif IRFt==3
            [D,~]=triangf(sigma);
        end
        [~,ortirfmatrix]=irfsim(beta,D,n,m,p,k,IRFperiods);
        
        % if we have FAVAR restrictions we scale the ortirfmatrix from the previous step
        if favar_FAVAR==1
            favar_ortirfmatrix=[];
            % scale with loading
            for uu=1:npltX %over variables in X that we choose to plot
                for mm=1:IRFperiods
                    for ll=1:n % over shocks
                        favar_ortirfmatrix(uu,ll,mm)=Lg(uu,:)*ortirfmatrix(:,ll,mm);
                    end
                end
            end
        end
        
        % save
        for kk=1:n
            for ll=1:n
                for mm=1:IRFperiods
                    irf_record_allt{kk,ll}(jj,mm,tt)=ortirfmatrix(kk,ll,mm);
                end
            end
        end
        
        if favar_FAVAR==1
            for uu=1:npltX % loop over variables
                for ll=1:n % loop over shocks
                    for mm=1:IRFperiods
                        favar.IRF.favar_irf_record_allt{uu,ll}(jj,mm,tt)=favar_ortirfmatrix(uu,ll,mm);
                    end
                end
            end
        end
    end
end



