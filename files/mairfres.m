function [struct_irf_record D_record gamma_record]=mairfres(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,p,k1,signrestable,signresperiods)



% function [struct_irf_record D_record gamma_record Qdraw Qsuccess]=mairfres(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,p,k1,signrestable,signresperiods)
% runs the gibbs sampler to obtain draws from the posterior distribution of IRFs, orthogonalised with a sign restriction setting
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix 'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
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
      % if entry (ii,jj) of the period matrix is not empty...
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

not_successful = 0;
hbar = parfor_progressbar(It-Bu,'Progress of Sign Restriction Draws');  %create the progress bar

% initiate Gibbs algorithm
parfor ii=1:It-Bu
% initiate the variable 'success'; this variable will be used to check whether the restrictions are satisfied
success=0;


   while success==0
   not_successful = not_successful+1;
   % switch 'success' to 1; it will be turned back to zero if at any time Q is detected as a candidate not satisfying the restrictions
   success=1;


   % draw the vector of VAR coefficients
   % select first a draw index randomly
   index=floor(rand*(It-Bu))+1;
   % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
   B=reshape(beta_gibbs(:,ii),k1,n);
   sigma=reshape(sigma_gibbs(:,ii),n,n);
   hsigma=chol(nspd(sigma),'lower');
   % obtain orthogonalised IRFs
   [irfmatrix ortirfmatrix]=mairfsim(B,hsigma,p,n,max(IRFperiods,max(periods)));


  
   % generate the stacked IRF matrix
   stackedirfmat=[];
      for jj=1:numel(periods)
      stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
      end
   % draw an entire random matrix Q satisfying the zero restrictions
   [Q]=qzerores(n,Zcell,stackedirfmat);


   % generate the candidate matrix of structural IRFs
   candidate=stackedirfmat*Q;


   % verify the restrictions in turn (sign, magnitude, or both)
   % the zero restrictions don't have to be verified, there are satisfied by construction
      % consider first the case of pure sign restrictions
      if signres==1 && magnres==0
         % loop over structural shocks; stop as soon as the draw is detected as a fail
         jj=1;
         while success==1 && jj<=n
            % if the corresponding entry in Scell is not empty, it contains a restriction to be checked
            if ~isempty(Scell{1,jj})
               % check if the restrictions hold
               if all(Scell{1,jj}*candidate(:,jj)>=0)
               % if the restrictions do not hold, there may still be a possibility by switching the sign of the Q column
               elseif all(Scell{1,jj}*((-1)*candidate(:,jj))>=0)
               Q(:,jj)=-Q(:,jj);
               % else, if there is no way to have Q succesful, count it as a fail and switch the variable success to 0
               else
               success=0;
               end
            end
         jj=jj+1;
         end
      % consider now the case of pure magnitude restrictions
      elseif signres==0 && magnres==1
         % loop over structural shocks
         jj=1;
         while success==1 && jj<=n
            % if the corresponding entry is not empty, it contains a restriction to be checked
            if ~isempty(Mcell{1,jj})
               % check if the restriction holds
               if all((Mcell{1,jj}*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*candidate(:,jj))>=0)
               % if they do not hold, there may still be a possibility by switching the sign of the Q column
               elseif all((Mcell{1,jj}*(-1)*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*(-1)*candidate(:,jj))>=0)
               Q(:,jj)=-Q(:,jj);
               % else, if there is no way to have Q succesful, count it as a fail and switch the variable success to 0
               else
               success=0;
               end
            end
         jj=jj+1;
         end
      % consider then the case of mixed sign and magnitude restrictions
      elseif signres==1 && magnres==1
         % loop over structural shocks
         jj=1;
         while success==1 && jj<=n
         % for a given structural shock, there may be no restrictions, only one type, or both types
            % if both types
            if ~isempty(Scell{1,jj}) && ~isempty(Mcell{1,jj})
               % check both restrictions
               if all(Scell{1,jj}*candidate(:,jj)>=0) && all((Mcell{1,jj}*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*candidate(:,jj))>=0)
               % if not, try to switch the sign of the corresponding column in Q
               elseif all(Scell{1,jj}*((-1)*candidate(:,jj))>=0) && all((Mcell{1,jj}*(-1)*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*(-1)*candidate(:,jj))>=0)
               Q(:,jj)=-Q(:,jj);
               % else, if there is no way to have Q succesful, count it as a fail and switch the variable success to 0
               else
               success=0;
               end
            % if only sign restrictions
            elseif ~isempty(Scell{1,jj}) && isempty(Mcell{1,jj})
               % check if the restrictions hold
               if all(Scell{1,jj}*candidate(:,jj)>=0)
               % if the restrictions do not hold, there may still be a possibility by switching the sign of the Q column
               elseif all(Scell{1,jj}*((-1)*candidate(:,jj))>=0)
               Q(:,jj)=-Q(:,jj);
               % else, if there is no way to have Q succesful, count it as a fail and switch the variable success to 0
               else
               success=0;
               end
            % if only magnitude restrictions
            elseif isempty(Scell{1,jj}) && ~isempty(Mcell{1,jj})
               % check if the restriction holds
               if all((Mcell{1,jj}*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*candidate(:,jj))>=0)
               % if they do not hold, there may still be a possibility by switching the sign of the Q column
               elseif all((Mcell{1,jj}*(-1)*candidate(:,jj)-Mlcell{1,jj}).*(Mucell{1,jj}-Mcell{1,jj}*(-1)*candidate(:,jj))>=0)
               Q(:,jj)=-Q(:,jj);
               % else, if there is no way to have Q succesful, count it as a fail and switch the variable success to 0
               else
               success=0;
               end
            end
         jj=jj+1;
         end
      % finally, the only possible remaining case is that of pure zero restrictions, satisfied by construction: no need to check
      else
      end
 
   % now, if sucess is still equal to 1, it means that the draw was successful for all the restrictions: keep it
   % otherwise, if success has been switched to 0, there was at least one failure: discard the draw and try with a new draw
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



