function [ar, lambda1, lambda2, lambda3, lambda4, lambda6, lambda7]=mgridsearch(X,Y,y,n,m,p,k,q,T,grid,arvar,sigmahat,data_endo,data_exo,priorexo,blockexo,const,H,opts)

lambda5 = opts.lambda5;
lambda6 = opts.lambda6;
lambda7 = opts.lambda7;
lambda8 = opts.lambda8;
prior = opts.prior;
bex = opts.bex;
scoeff = opts.scoeff;
iobs = opts.iobs;
lrp = opts.lrp;

% set preliminary values
logmlopt=-inf;
ar=[];
lambda1=[];
lambda2=[];
lambda3=[];
lambda4=[];

gridOptions = readmatrix(opts.excelFile, 'Sheet', 'grid', 'Range', 'C10:C11');
optimizeGridSearch = gridOptions(1);
if isnan(optimizeGridSearch) || ~isnumeric(optimizeGridSearch)
    optimizeGridSearch = 0;
end

if isempty(ver('globaloptim')) || ~license('test','GADS_Toolbox')
    optimizeGridSearch = 0;
end

if optimizeGridSearch == 1
    options = optimoptions('surrogateopt','PlotFcn', 'surrogateoptplot', 'MaxFunctionEvaluations', gridOptions(2));

    if scoeff==0 && iobs==0

        x = surrogateopt(@(x) -objectiveFunctionS0I0(x, X, y, n,m,p,k,q,T,lambda5,arvar,sigmahat,prior,priorexo,bex,blockexo), ...
            [grid{1:5,1}], [grid{1:5,2}], options);

        ar_default=NaN(n,1);
        ar_default(:,1)=x(1);
        ar=ar_default;
        lambda1=x(2);
        lambda2=x(3);
        lambda3=x(4);
        lambda4=x(5);

    elseif scoeff==1 && iobs==0

        x = surrogateopt(@(x) -objectiveFunctionS1I0(x, X,Y,n,m,p,k,q,T,lambda5,lambda7,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H), ...
            [grid{1:6,1}], [grid{1:6,2}], options);
        ar_default=NaN(n,1);
        ar_default(:,1)=x(1);
        ar=ar_default;
        lambda1=x(2);
        lambda2=x(3);
        lambda3=x(4);
        lambda4=x(5);
        lambda6=x(6);

    elseif scoeff==0 && iobs==1

        x = surrogateopt(@(x) -objectiveFunctionS0I1(x, X,Y,n,m,p,k,q,T,lambda5,lambda6,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H), ...
            [grid{[1:5,7],1}], [grid{[1:5,7],2}], options);

        ar_default=NaN(n,1);
        ar_default(:,1)=x(1);
        ar=ar_default;
        lambda1=x(2);
        lambda2=x(3);
        lambda3=x(4);
        lambda4=x(5);
        lambda7=x(6);

    elseif  scoeff==1 && iobs==1

        x = surrogateopt(@(x) -objectiveFunctionS1I1(x, X,Y,n,m,p,k,q,T,lambda5,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H), ...
            [grid{1:7,1}], [grid{1:7,2}], options);

        ar_default=NaN(n,1);
        ar_default(:,1)=x(1);
        ar=ar_default;
        lambda1=x(2);
        lambda2=x(3);
        lambda3=x(4);
        lambda4=x(5);
        lambda6=x(6);
        lambda7=x(7);

    end
else

    % run the classic grid search
    % loop over ar values
    for ii=grid{1,1}:grid{1,3}:grid{1,2}
        % loop over lambda1 values
        for jj=grid{2,1}:grid{2,3}:grid{2,2}
            % loop over lambda2 values
            for kk=grid{3,1}:grid{3,3}:grid{3,2}
                % loop over lambda3 values
                for ll=grid{4,1}:grid{4,3}:grid{4,2}
                    % loop over lambda4 values
                    for mm=grid{5,1}:grid{5,3}:grid{5,2}
                        % now the treatment will differ depending on whether there are dummy observations or not in the model

                        % first,if there are no dummy observation applications, run the grid normally
                        if scoeff==0 && iobs==0

                            logml = objectiveFunctionS0I0([ii, jj, kk, ll, mm], X, y, n,m,p,k,q,T,lambda5,arvar,sigmahat,prior,priorexo,bex,blockexo);

                            % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                            if logml>=logmlopt
                                logmlopt=logml;
                                ar=ii;
                                % create ar  vector
                                ar_default=NaN(n,1);
                                ar_default(:,1)=ar;
                                ar=ar_default;
                                lambda1=jj;
                                lambda2=kk;
                                lambda3=ll;
                                lambda4=mm;
                            end

                            % if only the sum-of-coefficient extension is selected
                        elseif scoeff==1 && iobs==0

                            % loop over lambda6 values
                            for nn=grid{6,1}:grid{6,3}:grid{6,2}

                                logml = objectiveFunctionS1I0([ii, jj, kk, ll, mm, nn], X,Y,n,m,p,k,q,T,lambda5,lambda7,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H);

                                % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                                if logml>=logmlopt
                                    logmlopt=logml;
                                    ar=ii;
                                    % create ar  vector
                                    ar_default=NaN(n,1);
                                    ar_default(:,1)=ar;
                                    ar=ar_default;
                                    lambda1=jj;
                                    lambda2=kk;
                                    lambda3=ll;
                                    lambda4=mm;
                                    lambda6=nn;
                                end

                            end

                            % if only the dummy initial observation extension is selected
                        elseif scoeff==0 && iobs==1

                            % loop over lambda7 values
                            for nn=grid{7,1}:grid{7,3}:grid{7,2}

                                logml = objectiveFunctionS0I1([ii, jj, kk, ll, mm, nn], X,Y,n,m,p,k,q,T,lambda5,lambda6,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H);

                                % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                                if logml>=logmlopt
                                    logmlopt=logml;
                                    ar=ii;
                                    % create ar  vector
                                    ar_default=NaN(n,1);
                                    ar_default(:,1)=ar;
                                    ar=ar_default;
                                    lambda1=jj;
                                    lambda2=kk;
                                    lambda3=ll;
                                    lambda4=mm;
                                    lambda7=nn;
                                end
                            end

                            % finally, if both the sum-of-coefficient and dummy initial observation extensions are selected
                        elseif scoeff==1 && iobs==1
                            % loop over lambda6 values
                            for nn=grid{6,1}:grid{6,3}:grid{6,2}
                                % loop over lambda7 values
                                for oo=grid{7,1}:grid{7,3}:grid{7,2}

                                    logml = objectiveFunctionS1I1([ii, jj, kk, ll, mm, nn, oo], X,Y,n,m,p,k,q,T,lambda5,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H);

                                    % if this value is greater than the current optimising value, set the hyperparameter values as the new optimum values
                                    if logml>=logmlopt
                                        logmlopt=logml;
                                        ar=ii;
                                        % create ar  vector
                                        ar_default=NaN(n,1);
                                        ar_default(:,1)=ar;
                                        ar=ar_default;
                                        lambda1=jj;
                                        lambda2=kk;
                                        lambda3=ll;
                                        lambda4=mm;
                                        lambda6=nn;
                                        lambda7=oo;
                                    end
                                end
                            end
                        end %endif
                    end
                end
            end
        end
    end
end

if isempty(ar)
    error('bear:mgridsearch:unabletofindvalues', 'the gridsearch was not able to identify any suitable values, please revise your inputs')
end

end

function logml = objectiveFunctionS0I0(x, X, y, n,m,p,k,q,T,lambda5,arvar,sigmahat,prior,priorexo,bex,blockexo)

ii = x(1);
jj = x(2);
kk = x(3);
ll = x(4);
mm = x(5);

% obtain prior elements
[beta0, omega0, sigma]=bear.mprior(ii,arvar,sigmahat,jj,kk,ll,mm,lambda5,n,m,p,k,q,prior,bex,blockexo,priorexo);

% obtain posterior elements
[betabar, omegabar]=bear.mpost(beta0,omega0,sigma,X,y,q,n);
% obtain the log marginal value (up to a constant) term
[logml]=bear.mmlikgrid(X,y,n,T,q,sigma,beta0,omega0,betabar,omegabar);

end

function logml = objectiveFunctionS1I0(x,X,Y,n,m,p,k,q,T,lambda5,lambda7,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H)

ii = x(1);
jj = x(2);
kk = x(3);
ll = x(4);
mm = x(5);
nn = x(6);

% generate the dummy observations
[~, ystar, Xstar, Tstar, ~, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,nn,lambda7,lambda8,scoeff,iobs,lrp,H);
% obtain prior elements
[beta0, omega0, sigma]=bear.mprior(ii,arvar,sigmahat,jj,kk,ll,mm,lambda5,n,m,p,k,q,prior,bex,blockexo);
% obtain posterior elements for the dummy-augmented data
[betabar, omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
% obtain the log marginal value (up to a constant) term for the dummy-augmented data
[logml]=bear.mmlikgrid(Xstar,ystar,n,Tstar,q,sigma,beta0,omega0,betabar,omegabar);
% now obtain posterior elements for the dummy data alone
[betabardum, omegabardum]=bear.mpost(beta0,omega0,sigma,Xdum,ydum,q,n);
% obtain the log marginal value (up to a constant) term for the dummy data alone
[logmldum]=bear.mmlikgrid(Xdum,ydum,n,Tdum,q,sigma,beta0,omega0,betabardum,omegabardum);
% finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
logml=logml-logmldum;

end

function logml = objectiveFunctionS0I1(x,X,Y,n,m,p,k,q,T,lambda5,lambda6,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H)
ii = x(1);
jj = x(2);
kk = x(3);
ll = x(4);
mm = x(5);
nn = x(6);

% generate the dummy observations
[~, ystar, Xstar, Tstar, ~, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,nn,lambda8,scoeff,iobs,lrp,H);
% obtain prior elements
[beta0, omega0, sigma]=bear.mprior(ii,arvar,sigmahat,jj,kk,ll,mm,lambda5,n,m,p,k,q,prior,bex,blockexo);
% obtain posterior elements for the dummy-augmented data
[betabar, omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
% obtain the log marginal value (up to a constant) term for the dummy-augmented data
[logml]=bear.mmlikgrid(Xstar,ystar,n,Tstar,q,sigma,beta0,omega0,betabar,omegabar);
% now obtain posterior elements for the dummy data alone
[betabardum, omegabardum]=bear.mpost(beta0,omega0,sigma,Xdum,ydum,q,n);
% obtain the log marginal value (up to a constant) term for the dummy data alone
[logmldum]=bear.mmlikgrid(Xdum,ydum,n,Tdum,q,sigma,beta0,omega0,betabardum,omegabardum);
% finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
logml=logml-logmldum;

end

function logml = objectiveFunctionS1I1(x,X,Y,n,m,p,k,q,T,lambda5,lambda8,arvar,sigmahat,data_endo,data_exo,prior,bex,blockexo,const,scoeff,iobs,lrp,H)
ii = x(1);
jj = x(2);
kk = x(3);
ll = x(4);
mm = x(5);
nn = x(6);
oo = x(7);

% generate the dummy observations
[~, ystar, Xstar, Tstar, ~, ydum, Xdum, Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,nn,oo,lambda8,scoeff,iobs,lrp,H);
% obtain prior elements
[beta0, omega0, sigma]=bear.mprior(ii,arvar,sigmahat,jj,kk,ll,mm,lambda5,n,m,p,k,q,prior,bex,blockexo);
% obtain posterior elements for the dummy-augmented data
[betabar, omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
% obtain the log marginal value (up to a constant) term for the dummy-augmented data
[logml]=bear.mmlikgrid(Xstar,ystar,n,Tstar,q,sigma,beta0,omega0,betabar,omegabar);
% now obtain posterior elements for the dummy data alone
[betabardum, omegabardum]=bear.mpost(beta0,omega0,sigma,Xdum,ydum,q,n);
% obtain the log marginal value (up to a constant) term for the dummy data alone
[logmldum]=bear.mmlikgrid(Xdum,ydum,n,Tdum,q,sigma,beta0,omega0,betabardum,omegabardum);
% finally obtain the log marginal likelihood for actual data by subtracting the dummy value from the total value
logml=logml-logmldum;

end
