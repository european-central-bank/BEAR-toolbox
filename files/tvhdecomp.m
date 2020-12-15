function [hd_record]=tvhdecomp(beta_gibbs,D_record,strshocks_record,It,Bu,Y,n,m,p,k,T)











% preliminary tasks
% first create the hd_record and temp cells
hd_record=cell(n,n+1);
temp=cell(n,2);



% then initiate the Gibbs algorithm
for ii=1:It-Bu

% recover beta for the current iteration (one column for each period)
beta_iter=[];
for jj=1:T
beta_iter=[beta_iter beta_gibbs{jj,1}(:,ii)];
end
    

% recover D for the current iteration (one page for each period)
D_iter=repmat(reshape(D_record(:,ii),n,n),[1,1,T]);

% recover the series of period-specific orthogonal IRFs
[IRFcell]=tvhdsim(beta_iter,D_iter,n,m,p,T,k);


% recover the structural disturbances
ETA=[];
for jj=1:n
ETA=[ETA;strshocks_record{jj,1}(ii,:)];
end
ETA=ETA';


% then compute the historical decomposition
   % loop over variables
   for jj=1:n
      % loop over shocks
      for kk=1:n
      % loop over shocks
      vshocks=ETA(:,kk);
         % loop over time periods
         for ll=1:T
         % initiate the vectors of IRFs and shocks
         virf=[];
            % then loop over IRF periods
            for mm=1:ll
            % create the vector of IRF coefficients
            virf=[virf IRFcell{mm,ll}(jj,kk)];
            end
         % compute then the contribution of shock kk for variable jj at period ll
         hd_record{jj,kk}(ii,ll)=virf*flipud(vshocks(1:ll,1));
         end
      end
   end


% then go for next Gibbs iteration
end





% step 6: compute the contributions of deterministic variables
% loop over rows of temp/hd_record
for ii=1:n
% fill the Ytot matrix in temp
% initial condition
temp{ii,1}=hd_record{ii,1};
   % sum over the remaining columns of hd_record
   for jj=2:n
   temp{ii,1}=temp{ii,1}+hd_record{ii,jj};
   end
% fill the Y matrix in temp
temp{ii,2}=repmat(Y(:,ii)',It-Bu,1);
% fill the Yd matrix in hd_record
hd_record{ii,n+1}=temp{ii,2}-temp{ii,1};
% go for next variable
end












