function [ar, lambda1, lambda3, lambda4, lambda6, lambda7]=nwgridsearch(X,Y,n,m,p,k,q,T,lambda2,lambda5,lambda6,lambda7,lambda8,grid,arvar,data_endo,data_exo,prior,priorexo,hogs,bex,const,scoeff,iobs,pref,It,Bu,lrp,H)

% set preliminary values
logmlopt=-inf;
ar=[];
lambda1=[];
lambda3=[];
lambda4=[];



% run the grid search
% loop over ar values
for ii=grid{1,1}:grid{1,3}:grid{1,2}
    % loop over lambda1 values
    for jj=grid{2,1}:grid{2,3}:grid{2,2}
        % loop over lambda3 values
        for kk=grid{4,1}:grid{4,3}:grid{4,2}
            % loop over lambda4 values
            for ll=grid{5,1}:grid{5,3}:grid{5,2}
                % now the treatment will differ depending on whether there are dummy observations or not in the model
                
                
                
                % first,if there are no dummy observation applications, run the grid normally
                if scoeff==0 && iobs==0
                    % obtain prior elements
                    [B0, beta0, phi0, S0, alpha0]=bear.nwprior(ii,arvar,jj,kk,ll,n,m,p,k,q,prior,priorexo);
                    % obtain posterior elements
                    [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k);
                    % obtain the log marginal value (up to a constant) term
                    [logml]=bear.nwmlikgrid(X,n,k,phi0,S0,Sbar,alphabar);
                    % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                    if logml>=logmlopt
                        logmlopt=logml;
                        ar=ii;
                        % create ar  vector
                        ar_default=NaN(n,1);
                        ar_default(:,1)=ar;
                        ar=ar_default;
                        lambda1=jj;
                        lambda3=kk;
                        lambda4=ll;
                    end
                    
                    
                    
                    % if only the sum-of-coefficient extension is selected
                elseif scoeff==1 && iobs==0
                    % loop over lambda6 values
                    for mm=grid{6,1}:grid{6,3}:grid{6,2}
                        % generate the dummy observations
                        [Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,lambda7,lambda8,scoeff,iobs,lrp,H);
                        % obtain prior elements
                        [B0, beta0, phi0, S0, alpha0]=bear.nwprior(ii,arvar,jj,kk,ll,n,m,p,k,q,prior,priorexo);
                        % obtain posterior elements for the dummy-augmented data
                        [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
                        % obtain the log marginal value (up to a constant) term for the dummy-augmented data
                        [logml]=bear.nwmlikgrid(Xstar,n,k,phi0,S0,Sbar,alphabar);
                        % now obtain posterior elements for the dummy data alone
                        [~,~,~,Sbardum,alphabardum,~]=bear.nwpost(B0,phi0,S0,alpha0,Xdum,Ydum,n,Tdum,k);
                        % obtain the log marginal value (up to a constant) term for the dummy data alone
                        [logmldum]=bear.nwmlikgrid(Xdum,n,k,phi0,S0,Sbardum,alphabardum);
                        % finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
                        logml=logml-logmldum;
                        % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                        if logml>=logmlopt
                            logmlopt=logml;
                            ar=ii;
                            % create ar  vector
                            ar_default=NaN(n,1);
                            ar_default(:,1)=ar;
                            ar=ar_default;
                            lambda1=jj;
                            lambda3=kk;
                            lambda4=ll;
                            lambda6=mm;
                        end
                    end
                    
                    
                    
                    % if only the dummy initial observation extension is selected
                elseif scoeff==0 && iobs==1
                    % loop over lambda7 values
                    for mm=grid{7,1}:grid{7,3}:grid{7,2}
                        % generate the dummy observations
                        [Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,lambda7,lambda8,scoeff,iobs,lrp,H);
                        % obtain prior elements
                        [B0, beta0, phi0, S0, alpha0]=bear.nwprior(ii,arvar,jj,kk,ll,n,m,p,k,q,prior,priorexo);
                        % obtain posterior elements for the dummy-augmented data
                        [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
                        % obtain the log marginal value (up to a constant) term for the dummy-augmented data
                        [logml]=bear.nwmlikgrid(Xstar,n,k,phi0,S0,Sbar,alphabar);
                        % now obtain posterior elements for the dummy data alone
                        [~,~,~,Sbardum,alphabardum,~]=bear.nwpost(B0,phi0,S0,alpha0,Xdum,Ydum,n,Tdum,k);
                        % obtain the log marginal value (up to a constant) term for the dummy data alone
                        [logmldum]=bear.nwmlikgrid(Xdum,n,k,phi0,S0,Sbardum,alphabardum);
                        % finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
                        logml=logml-logmldum;
                        % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                        if logml>=logmlopt
                            logmlopt=logml;
                            ar=ii;
                            % create ar  vector
                            ar_default=NaN(n,1);
                            ar_default(:,1)=ar;
                            ar=ar_default;
                            lambda1=jj;
                            lambda3=kk;
                            lambda4=ll;
                            lambda7=mm;
                        end
                    end
                    
                    
                    
                    % finally, if both the sum-of-coefficient and dummy initial observation extensions are selected
                elseif scoeff==1 && iobs==1
                    % loop over lambda6 values
                    for mm=grid{6,1}:grid{6,3}:grid{6,2}
                        % loop over lambda7 values
                        for nn=grid{7,1}:grid{7,3}:grid{7,2}
                            % generate the dummy observations
                            [Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,lambda7,lambda8,scoeff,iobs,lrp,H);
                            % obtain prior elements
                            [B0, beta0, phi0, S0, alpha0]=bear.nwprior(ii,arvar,jj,kk,ll,n,m,p,k,q,prior,priorexo);
                            % obtain posterior elements for the dummy-augmented data
                            [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
                            % obtain the log marginal value (up to a constant) term for the dummy-augmented data
                            [logml]=bear.nwmlikgrid(Xstar,n,k,phi0,S0,Sbar,alphabar);
                            % now obtain posterior elements for the dummy data alone
                            [~,~,~,Sbardum,alphabardum,~]=bear.nwpost(B0,phi0,S0,alpha0,Xdum,Ydum,n,Tdum,k);
                            % obtain the log marginal value (up to a constant) term for the dummy data alone
                            [logmldum]=bear.nwmlikgrid(Xdum,n,k,phi0,S0,Sbardum,alphabardum);
                            % finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
                            logml=logml-logmldum;
                            % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                            if logml>=logmlopt
                                logmlopt=logml;
                                ar=ii;
                                % create ar  vector
                                ar_default=NaN(n,1);
                                ar_default(:,1)=ar;
                                ar=ar_default;
                                lambda1=jj;
                                lambda3=kk;
                                lambda4=ll;
                                lambda6=mm;
                                lambda7=nn;
                            end
                        end
                    end
                end
                
                
                
            end
        end
    end
end



% save the preferences, updated with the optimised values
if exist('userpref2.m','file')==2
    delete('userpref2.m')
end
if pref.results==1
    fid=fopen('userpref2.txt','wt');
    priorinfo=['prior=' num2str(prior) ';'];
    fprintf(fid,'%s\n',priorinfo);
    arinfo=['ar=' num2str(ar(1,1)) ';'];
    fprintf(fid,'%s\n',arinfo);
    lambda1info=['lambda1=' num2str(lambda1) ';'];
    fprintf(fid,'%s\n',lambda1info);
    lambda2info=['lambda2=' num2str(lambda2) ';'];
    fprintf(fid,'%s\n',lambda2info);
    lambda3info=['lambda3=' num2str(lambda3) ';'];
    fprintf(fid,'%s\n',lambda3info);
    lambda4info=['lambda4=' num2str(lambda4) ';'];
    fprintf(fid,'%s\n',lambda4info);
    lambda5info=['lambda5=' num2str(lambda5) ';'];
    fprintf(fid,'%s\n',lambda5info);
    lambda6info=['lambda6=' num2str(lambda6) ';'];
    fprintf(fid,'%s\n',lambda6info);
    lambda7info=['lambda7=' num2str(lambda7) ';'];
    fprintf(fid,'%s\n',lambda7info);
    Itinfo=['It=' num2str(It) ';'];
    fprintf(fid,'%s\n',Itinfo);
    Buinfo=['Bu=' num2str(Bu) ';'];
    fprintf(fid,'%s\n',Buinfo);
    hogsinfo=['hogs=' num2str(hogs) ';'];
    fprintf(fid,'%s\n',hogsinfo);
    bexinfo=['bex=' num2str(bex) ';'];
    fprintf(fid,'%s\n',bexinfo);
    scoeffinfo=['scoeff=' num2str(scoeff) ';'];
    fprintf(fid,'%s\n',scoeffinfo);
    iobsinfo=['iobs=' num2str(iobs) ';'];
    fprintf(fid,'%s\n',iobsinfo);
    fclose(fid);
    movefile('userpref2.txt','userpref2.m');
end
