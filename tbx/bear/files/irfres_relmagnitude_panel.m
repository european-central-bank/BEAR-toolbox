function [struct_irf_record D_record gamma_record]=irfres_relmagnitude_panel(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods, relmagrestable, relmagresperiods)



% function [struct_irf_record D_record gamma_record Qdraw Qsuccess]=irfres(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,m,p,k,signrestable,signresperiods)
% runs the gibbs sampler to obtain draws from the posterior distribution of IRFs, orthogonalised with a sign restriction setting
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix 'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - cell 'signrestable': table recording the sign restriction input from the user
%          - cell 'signresperiods': table containing the periods corresponding to each restriction
% outputs: - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - integer 'Qdraw': total number of draws of the Q matrix 
%          - integer 'Qsuccess': number of successful draws of the Q matrix 





% preliminary tasks
% create first the cell that will store the results from the simulations
struct_irf_record=cell(n,n);
% storage cell
storage1=cell(It-Bu,1);
storage2=cell(It-Bu,1);

% now identify all the periods concerned with restrictions
% first expand the non-empty entries in signresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; I don't think this can done without a loop
temp=cell2mat(signresperiods(~cellfun(@isempty,signresperiods)));
periods=[];
for ii=1:size(temp,1)
periods=[periods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
periods=sort(unique(periods))';
% count the total number of restriction periods (required for IRF matrix)
nperiods=size(periods,1);

% now identify all the periods concerned with relative magnitude
% restrictions
% first expand the non-empty entries in magresperiods since they are only expressed in intervals: transform into list
% for instance, translate [1 4] into [1 2 3 4]; 
temp=cell2mat(relmagresperiods(~cellfun(@isempty,relmagresperiods)));
mperiods=[];
for ii=1:size(temp,1)
mperiods=[mperiods temp(ii,1):temp(ii,2)];
end
% suppress duplicates and sort
mperiods=sort(unique(mperiods))';
% count the total number of restriction periods (required for IRF matrix)
rmperiods=size(periods,1);

% Identify the restriction matrices
% create five cells, corresponding to the three possible restrictions:
% one cell for sign restrictions, three cells for magnitude restrictions, one cell for zero restrictions
Scell=cell(1,n);
Mcell=cell(1,n);
Mlcell=cell(1,n);
Mucell=cell(1,n);
Zcell=cell(1,n);

% Check if value and periods restrictions correspond to each other
if sum(sum(~cellfun(@isempty,signresperiods) == ~cellfun(@isempty,signrestable))) == n^2
    % All cells with sign restrictions also specify the horizon over which
    % these are applied
else
    disp('Warning: Value restrictions do not correspond to period restrictions one to one')
    pause(1)
end

% loop over rows and columns of the period matrix
for ii=1:n
   for jj=1:n
      % if entry (ii,jj) of the period matrix and of the value matrix is not empty...
      if ~isempty(signresperiods{ii,jj}) && ~isempty(signrestable{ii,jj})
      % ... then there is a restriction over one (or several) periods
      % loop overt those periods
         for kk=signresperiods{ii,jj}(1,1):signresperiods{ii,jj}(1,2)
         % identify the position of the considered period within the list of all periods (required to build the matrix)
         position=find(periods==kk);
         % now create the restriction matrix: this will depend on the type of restriction
            % if it is a positive sign restriction...
            if strcmp(signrestable{ii,jj},'+')
            % ... then input a 1 entry in the corresponding S matrix
            Scell{1,jj}=[Scell{1,jj};zeros(1,n*nperiods)];
            Scell{1,jj}(end,(position-1)*n+ii)=1;
            % if it is a negative sign restriction...
            elseif strcmp(signrestable{ii,jj},'-')
            % ... then input a -1 entry in the corresponding S matrix
            Scell{1,jj}=[Scell{1,jj};zeros(1,n*nperiods)];
            Scell{1,jj}(end,(position-1)*n+ii)=-1;
            % if it is a zero restriction...
            elseif strcmp(signrestable{ii,jj},'0')
            % ... then input a 1 entry in the corresponding Z matrix
            Zcell{1,jj}=[Zcell{1,jj};zeros(1,n*nperiods)];
            Zcell{1,jj}(end,(position-1)*n+ii)=1;
            % else, a non-empty entry being neither a sign nor a zero restriction has to be a magnitude restriction                
            else
            % fill the corresponding M matrices:
            % input a 1 in M
            Mcell{1,jj}=[Mcell{1,jj};zeros(1,n*nperiods)];
            Mcell{1,jj}(end,(position-1)*n+ii)=1;
            % input the lower value of the interval in Ml
            temp=str2num(signrestable{ii,jj});
            Mlcell{1,jj}=[Mlcell{1,jj};temp(1,1)];
            % input the upper value of the interval in Mu
            Mucell{1,jj}=[Mucell{1,jj};temp(1,2)];
            end
         end
      end
   end
end



%create matrix entry for relative magnitude restrictions (on impact)
[r clm] = find(~cellfun('isempty',relmagrestable));
%2. Indentify which entry corresponds to the positive magnitude
%restriction (which shock is supposed to have a larger impact on which
%variable)
num_magres=length(r)/2; %number of relative magnitude restrictions
IndextempL=double.empty;
kk=1; %number of the restrictions
IndextempS=double.empty;
kk=1; %%number of restriction

rowsS = [];
columnsS = [];
for jj=1:num_magres %%loop over number of magnitude restrictions
strtemp = strcat('S',num2str(jj)); %%find entry in the table corresponding to the Stronger than restriction
Stronger = strcmp(relmagrestable, strtemp);
[rowS columnS] = find(Stronger==1);
rowsS = [rowsS rowS];
columnsS = [columnsS columnS]; 
end 

rowsW = [];
columnsW = [];
for jj=1:num_magres
strtemp = strcat('W',num2str(jj)); 
Weaker = strcmp(relmagrestable, strtemp);
[rowW columnW] = find(Weaker==1);
rowsW = [rowsW rowW];
columnsW = [columnsW columnW]; 
end 

% now check what kind of restrictions apply among sign, zero and magnitude restrictions
% check for sign restrictions: if there are any, at least one entry in the cell Scell is non-empty
if sum(~cellfun(@isempty,Scell))~=0
signres=1;
else
signres=0;
end
% similarly check for zero restrictions
if sum(~cellfun(@isempty,Zcell))~=0
zerores=1;
else
zerores=0;
end
% and finally, check for magnitude restrictions
if sum(~cellfun(@isempty,Mcell))~=0
magnres=1;
else
magnres=0;
end
if length(columnsS)~=0
relmagnres=1;
else
relmagnres=0;
end




% initiate Gibbs algorithm
not_successful = 0;
hbar = parfor_progressbar(It-Bu,'Progress of Sign Restriction Draws');  %create the progress bar
for ii=1:It-Bu
% initiate the variable 'success'; this variable will be used to check whether the restrictions are satisfied
% if there are only zero restrictions, they will be satisfied by construction, and 'success' will simply be ignored
success=0;

% how the algorithm will be conducted will depend on the types of restrictions implemented

   % if there are only zero restrictions, the algorithm is simple as no checking is required: the conditions are satisfied by construction
   if zerores==1 && signres==0 && magnres==0 && relmagnres==0
   % draw beta and sigma
   beta=beta_gibbs(:,ii);
   sigma=reshape(sigma_gibbs(:,ii),n,n);
   hsigma=chol(nspd(sigma),'lower');
   % obtain orthogonalised IRFs
   [irfmatrix ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
   % generate the stacked IRF matrix
   stackedirfmat=[];
      for jj=1:numel(periods)
      stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
      end
   % draw an entire random matrix Q satisfying the zero restrictions
   [Q]=qzerores(n,Zcell,stackedirfmat);
   % there is no need to verify the restrictions: there are satisfied by construction



   % if there are sign/magnitude restrictions, possibly associated with zero restrictions
   else
   % the algorithm becomes a bit more complicated as conditions now need to be checked
   % to maintain efficiency, the algorithm proceeds recursively shock by shock, and stops as soon as a condition on the considered shock fails
      % repeat algorithm for the iteration as long as not all conditions are satisfied
      while success==0
      not_successful = not_successful+1;
      % switch 'success' to 1; it will be turned back to zero if at any time Q is detected as a candidate not satisfying the restrictions
      success=1;
      % draw randomly the vector of VAR coefficients: draw a random index
      index=floor(rand*(It-Bu))+1;
      % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
      beta=beta_gibbs(:,index);
      sigma=reshape(sigma_gibbs(:,index),n,n);
      hsigma=chol(nspd(sigma),'lower');
      % obtain orthogonalised IRFs
      [irfmatrix ortirfmatrix]=irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
      % generate the stacked IRF matrix
      stackedirfmat=[];
         for jj=1:numel(periods)
         stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
         end
      % initiate Qj
      Qj=[];
      % now start looping over the shocks and checking sequentially whether conditions on these shocks hold
      % stop as soon as one restriction fails
         jj=1;
         while success==1 && jj<=n
         % build column j of the random matrix Q
         [qj]=qrandj(n,Zcell{1,jj},stackedirfmat,Qj);
         % obtain the candidate column fj
         fj=stackedirfmat*qj;
         % check restrictions: first sign restrictions
         [success qj]=checksignres(Scell{1,jj},qj,fj);
         % if 'success' is still equal to 1, also check for magnitude restrictions
            if success==1
            [success]=checkmagres(Mcell{1,jj},Mlcell{1,jj},Mucell{1,jj},fj);
            end
         % also, if 'success' is still equal to 1, update Qj by concatenating qj
            if success==1
            Qj=[Qj qj];
            end
            
%once all n columns are build and fullfill the sign restrictions, check
%relative magnitudes 
            jj=jj+1;
           if size(Qj,2)==n && success==1  && relmagnres==1
             %disp('I reached magnitude restrictions') 
             D=hsigma*Qj;   
             [~, ortirfmatrixmagnitude]=irfsim(beta,D,n,m,p,k,max(IRFperiods,max(mperiods)));
             % generate the stacked IRF matrix
              stackedirfmatmagn=[];
              for kk=1:numel(mperiods)
              stackedirfmatmagn=[stackedirfmatmagn;ortirfmatrixmagnitude(:,:,mperiods(kk,1)+1)];
              end
              [success]=checkrelmag(stackedirfmatmagn,columnsS, columnsW, rowsS, rowsW, n, mperiods);
              if success ==1
              %disp('Sign and Magnitude Restrictions fullfilled')
              else
              disregarded=ortirfmatrixmagnitude;
              end 
            end
        end
      % repeat this loop until a succesful draw is obtained
   end 
% with succesful Qj at hand, eventually set Q as Qj
Q=Qj;
end 

  % store
   for jj=1:IRFperiods
   storage1{ii,1}(:,:,jj)=ortirfmatrix(:,:,jj)*Q;
   end
   storage2{ii,1}=hsigma*Q;
   hbar.iterate(1);   % update progress by one iteration
end
close(hbar);   %close progress bar
    
% reorganise storage
% loop over iterations
for ii=1:It-Bu
   % loop over IRF periods
   for jj=1:IRFperiods
      % loop over variables
      for kk=1:n
         % loop over shocks
         for ll=1:n
         struct_irf_record{kk,ll}(ii,jj)=storage1{ii,1}(kk,ll,jj);    
         end
      end
   end
D_record(:,ii)=storage2{ii,1}(:);
gamma_record(:,ii)=vec(eye(n));
end



fprintf('Accepted Draws in Percent of Total Number of Draws: %f', 100*(It-Bu)/(not_successful + It-Bu))





