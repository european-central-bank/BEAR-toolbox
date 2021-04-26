function [hd_record,hd_estimates]=panel6hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,N,n,m,p,k,T,d,HDband)











% preliminary tasks
% first create the hd_record and temp cells
hd_record=cell(n*N,n*N+1);
temp=cell(n*N,2);



% then initiate the Gibbs algorithm
for ii=1:It-Bu

% recover theta for the current iteration (one column for each period)
theta_iter=reshape(theta_gibbs(:,ii,:),d,T);

% recover D for the current iteration (one page for each period)
D_iter=[];
for jj=1:T
D_iter(:,:,jj)=reshape(D_record(:,ii,jj),N*n,N*n);
end

% recover the series of period-specific orthogonal IRFs
[IRFcell]=panel6hdsim(theta_iter,D_iter,Xi,N,n,m,p,T,k);


% recover the structural disturbances
ETA=[];
for jj=1:N*n
ETA=[ETA;strshocks_record{jj,1}(ii,:)];
end
ETA=ETA';


% then compute the historical decomposition
   % loop over variables
   for jj=1:n*N
      % loop over shocks
      for kk=1:n*N
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




% compute the contributions of deterministic variables
% loop over rows of temp/hd_record
for ii=1:n*N
% fill the Ytot matrix in temp
% initial condition
temp{ii,1}=hd_record{ii,1};
   % sum over the remaining columns of hd_record
   for jj=2:n*N
   temp{ii,1}=temp{ii,1}+hd_record{ii,jj};
   end
% fill the Y matrix in temp
temp{ii,2}=repmat(Ymat(:,ii)',It-Bu,1);
% fill the Yd matrix in hd_record
hd_record{ii,N*n+1}=temp{ii,2}-temp{ii,1};
% go for next variable
end




% finally, obtain point esimates and credibility intervals
[hd_estimates]=hdestimates(hd_record,N*n,T,HDband);

