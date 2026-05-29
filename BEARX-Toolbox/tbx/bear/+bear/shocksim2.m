function eta=shocksim2(cfconds,cfshocks,cfblocks,Fperiods,n,gamma,fmat,ortirfmat)



% function eta=shocksim2(cfconds,cfshocks,cfblocks,Fperiods,n,gamma,fmat,ortirfmat)
% draws a vector of shocks satisfying the conditions for the conditional forecast setting, allowing for a subset of shocks only to be used
% inputs:  - cell 'cfconds': conditional forecast conditions
%          - cell 'cfshocks': conditional forecast shocks generating the conditions
%          - matrix 'cfblocks': conditional forecast blocks
%          - integer 'Fperiods': number of forecast periods
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - matrix 'gamma': structural disturbance variance-covariance matrix (defined p 48 of technical guide)
%          - matrix 'fmat': matrix of predicted values
%          - matrix 'ortirfmat': matrix of orthogonalised IRFs
% outputs: - vector 'eta': vector of shocks satisfying the conditions



% this function implements algorithm 3.4.1 to identify the shocks of a conditional forecast problem



% preliminary tasks

% generate first the vector of shocks eta ; it starts being empty, but it will be updated at each period
% and it will eventually become the full vector of shocks for the whole forecasting period
eta=[];

% create a list of all shocks in the model
allshocks=[1:n];





% then loop over forecast periods
for ii=1:Fperiods


% step 1
% identify the constructive and non-constructive shocks
% first, count the number of blocks for the current period
nblocks=max(cfblocks(ii,:));
% list the constructive shocks associated with each block
blockshocks=cell(nblocks,1);
   for jj=1:nblocks
   % identify the position of block jj in cfblocks
   [~,loc]=find(cfblocks(ii,:)==jj);
   % then list the shocks corresponding to this block from the corresponding matrix in cfshocks
   blockshocks{jj,1}=cfshocks{ii,loc};
   end
% create a list of all constructive shocks: simply list the shocks in all the blocks
consshocks=cell2mat(blockshocks');
% identify the non-constructive shocks as the difference between all shocks and constructive shocks
nonconsshocks=setdiff(allshocks,consshocks);


% initiate the shocks for the current periods
% update first eta with zeros
eta=[eta;zeros(n,1)];
% also, create a vector containing only the shocks for the current period (not yet estimated) 
eta_t=zeros(n,1);




% check if there are conditions


% if there are no conditions, just draw shocks from their distributions
   if nblocks==0
   eta_t=mvnrnd(zeros(n,1),gamma)';


% if there are conditions
   else
   % step 2-3: create the linear system, that is, the R matrix and the r vector
   % initiate R and r
   r=0;
   R=zeros(1,ii*n);
   % initiate count of conditions
   count=0;
   % input conditions block by block
      for jj=1:nblocks
         % record which row of R corresponds to the beginning of the block
         Rblocks(jj,1)=count+1;
         % loop over columns of cfblocks, row ii
         for kk=1:n
            % check if cell contains a condition corresponding to block jj
            if cfblocks(ii,kk)==jj
            % if it does contain a condition corresponding to current block, add 1 to the count..
            count=count+1;         
            % .. fill r with the corresponding condition, minus forecast..
            r(count,1)=cfconds{ii,kk}-fmat(ii,kk);
            % .. and R with the corresponding orthogonalised IRFs entries
            % loop over periods up to the one on which there is the constraint
               for ll=1:ii
               temp(1,(ll-1)*n+1:ll*n)=ortirfmat(kk,:,ii-ll+1);
               end
            R(count,1:ii*n)=temp;
            clear temp;
            % if the cell has no corresponding condition, don't do anything
            else
            end
         end
         % record which row of R corresponds to the end of the block
         Rblocks(jj,2)=count;
      % go for next block and repeat until all the blocks have been covered
      end


   % step 4: once the linear system is created, Channel the impact of shocks from previous periods on r
   r=r-R*eta;
   % now that the impact has been channelled, reduce R by trimming all the columns related to previous periods
   R=R(:,(ii-1)*n+1:end);


   % step 5: check if there are any non-constructive shocks
      % if there are non-constructive shocks
      if isempty(nonconsshocks)==0
      % draw first these shocks from their distribution
      temp=mvnrnd(zeros(n,1),gamma)';
      % update eta_t
         for jj=1:numel(nonconsshocks)
         eta_t(nonconsshocks(1,jj),1)=temp(nonconsshocks(1,jj),1);
         end
      % channel the impact of these shocks on r
      r=r-R*eta_t;
      % update R by turning corresponding columns to 0
         for jj=1:numel(nonconsshocks)
         R(:,nonconsshocks(1,jj))=0;
         end
      clear temp
      % if there are no non-constructive shocks, do not do anything
      else
      end


   % steps 6-8: go for blocks
      % loop over blocks
      for jj=1:nblocks
      % retain only the rows of R and r corresponding to current block
      Rtemp=R(Rblocks(jj,1):Rblocks(jj,2),:);
      rtemp=r(Rblocks(jj,1):Rblocks(jj,2),:);
      % draw a full vector of shocks from the Waggoner-Zha distribution
      % realise the singular value decomposition of Rtemp as in (XXX) and obtain the matrices defined in (XXX)
      % recover Q and K, the dimensions of the matrix Rtemp
      [Q,K]=size(Rtemp);
      % obtain the singular value decomposition
      [U,S,V]=svd(Rtemp);
      % obtain the required matrices
      P=S(:,1:Q);
      V1=V(:,1:Q);
      V2=V(:,Q+1:end);
      % step 5: draw the vector of constrained shocks from N(etabar,gammabar)
      etatilde=V1/P*U'*rtemp+V2*mvnrnd(zeros(K-Q,1),eye(K-Q))';
      % a full vector of shocks has been drawn, but only the shocks corresponding to the current block are retained and updated on eta
         % loop over shocks corresponding to the current block
         for kk=1:size(blockshocks{jj,1},2)
         % and update eta with the corresponding shock drawn from the distribution
         eta_t(blockshocks{jj,1}(1,kk),1)=etatilde(blockshocks{jj,1}(1,kk),1);
         end
      % channel the impact of the newly drawn shocks on r..
      r=r-R*eta_t;
      % .. and update R by turning corresponding columns to 0
         for kk=1:size(blockshocks{jj,1},2)
         R(:,blockshocks{jj,1}(1,kk))=0;
         end
      % go for the next block
      end
   end


% update eta
eta(end-n+1:end,1)=eta_t;


% the vector of shocks eta is drawn for the current period; go for next period
end










