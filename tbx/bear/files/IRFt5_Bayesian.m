function [struct_irf_record,D_draws,gamma_draws,ETA_record,It,Bu,beta_draws,sigma_draws]=...
    IRFt5_Bayesian(names,betahat,m,n,X,Y,k,p,enddate,startdate,IRFperiods,IRFt,T,arvar,q,It,Bu,lambda1,lambda3,lambda4,pref,strctident)
%%Implementation of a Bayesian Proxy VAR based on the Codes published by Caldara and Herbst (2018)
%%Implementation by Ben Schumann
%% IV identification
%Load IV and make it comparable with the reduced form errors
[EPSIV,IVcut,~,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,~,cut1,cut2,cut3,cut4]...
    =loadIV(betahat,k,n,Y,X,T,p,names,startdate,enddate,strctident);

% IV routine
[beta_draws,sigma_draws,~,~,D_draws,gamma_draws,irf_storage,ETA_storage,It,Bu]=...
    irfIV_MH(EPSIV,IVcut,betahat,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,cut1,cut2,cut3,cut4,names,It,Bu,n,arvar,lambda1,lambda3,lambda4,m,p,k,q,X,Y,T,startdate,enddate,pref,strctident,IRFperiods,IRFt);

% reorganise
Acc=It-Bu;
% loop over iterations
for ii=1:Acc/strctident.Thin
    for jj=1:IRFperiods
        % loop over variables
        for kk=1:n
            % loop over shocks (only one)
            for ll=1
                %for ll=1:n
                struct_irf_record{kk,ll}(ii,jj)=irf_storage{ii,1}(kk,ll,jj);
            end
        end
    end
end

% loop over variables
for kk=1:n
    % loop over shocks (only one)
    for ll=2:n
        %for ll=1:n
        struct_irf_record{kk,ll}=zeros(Acc/strctident.Thin,IRFperiods);
    end
end

%reorganize Structural Shocks
ETA_record=cell(n,1);
for jj=1:Acc/strctident.Thin
    for kk=1:n
        ETA_record{kk,1}(jj,:)= ETA_storage{jj,1}(kk,:);
    end
end

%finally update It and Bu such that BEAR knows how many draws we kept
It = It/strctident.Thin;
Bu = Bu/strctident.Thin; 
