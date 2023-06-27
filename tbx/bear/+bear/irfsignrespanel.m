function [struct_irf_record, D_record, gamma_record]=irfsignrespanel(beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,n,p,m,k,signrestable,signresperiods)

% function [struct_irf_record D_record gamma_record]=irfsignrespanel(sigma_gibbs,irf_record,It,Bu,IRFperiods,n,signrestable,signresperiods,checkalgo,checkiter)
% runs the gibbs sampler to obtain draws from the posterior distribution of
% IRFs, orthogonalised with sign restrictions
% inputs:  - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - cell 'irf_record': record of the gibbs sampler draws for the IRFs
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - cell 'struct_irf_record': record of the gibbs sampler draws for the orthogonalised IRFs
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma



% this function implements the sign restrictions approach for the panel



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


% loop over rows and columns of the period matrix
for ii=1:n
    for jj=1:n
        % if entry (ii,jj) of the period matrix is not empty...
        if ~isempty(signresperiods{ii,jj})
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

hbar = bear.parfor_progressbar(It-Bu,'Progress');  %create the progress bar


% step 1: repeat simulations a number of times equal to the number of simulations retained from Gibbs sampling
parfor ii=1:It-Bu
    % initiate the variable 'success'; this variable will be used to check whether the restrictions are satisfied
    % if there are only zero restrictions, they will be satisfied by construction, and 'success' will simply be ignored
    success=0;
    % how the algorithm will be conducted will depend on the types of restrictions implemented
    
    
    % if there are only zero restrictions, the algorithm is simple as no checking is required: the conditions are satisfied by construction
    if zerores==1 && signres==0 && magnres==0
        % draw beta and sigma
        beta=beta_gibbs(:,ii);
        sigma=reshape(sigma_gibbs(:,ii),n,n);
        hsigma=chol(bear.nspd(sigma),'lower');
        % obtain orthogonalised IRFs
        [irfmatrix, ortirfmatrix]=bear.irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
        % generate the stacked IRF matrix
        stackedirfmat=[];
        for jj=1:numel(periods)
            stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
        end
        % draw an entire random matrix Q satisfying the zero restrictions
        [Q]=bear.qzerores(n,Zcell,stackedirfmat);
        % there is no need to verify the restrictions: there are satisfied by construction
        
        
        
        
        % if there are sign/magnitude restrictions, possibly associated with zero restrictions
    else
        % the algorithm becomes a bit more complicated as conditions now need to be checked
        % to maintain efficiency, the algorithm proceeds recursively shock by shock, and stops as soon as a condition on the considered shock fails
        % repeat algorithm for the iteration as long as not all conditions are satisfied
        while success==0
            % switch 'success' to 1; it will be turned back to zero if at any time Q is detected as a candidate not satisfying the restrictions
            success=1;
            % draw randomly the vector of VAR coefficients: draw a random index
            index=floor(rand*(It-Bu))+1;
            % then draw a random set of beta and sigma corresponding to this index (this is done to make it possible to draw, if required, an infinite number of values from the gibbs sampler record, with equal probability on each value)
            beta=beta_gibbs(:,index);
            sigma=reshape(sigma_gibbs(:,index),n,n);
            hsigma=chol(bear.nspd(sigma),'lower');
            % obtain orthogonalised IRFs
            [irfmatrix, ortirfmatrix]=bear.irfsim(beta,hsigma,n,m,p,k,max(IRFperiods,max(periods)));
            % generate the stacked IRF matrix
            stackedirfmat=[];
            for jj=1:numel(periods)
                stackedirfmat=[stackedirfmat;ortirfmatrix(:,:,periods(jj,1)+1)];
            end
            % initiate Qj
            Qj=[];
            % now start looping over the shocks and checking sequentially whether conditions on these shocks hold
            % stop as soon as one restriction fails
            kk=1;
            while success==1 && kk<=n
                % build column j of the random matrix Q
                [qj]=bear.qrandj(n,Zcell{1,kk},stackedirfmat,Qj);
                % obtain the candidate column fj
                fj=stackedirfmat*qj;
                % check restrictions: first sign restrictions
                [success qj]=bear.checksignres(Scell{1,kk},qj,fj);
                % if 'success' is still equal to 1, also check for magnitude restrictions
                if success==1
                    [success]=bear.checkmagres(Mcell{1,kk},Mlcell{1,kk},Mucell{1,kk},fj);
                end
                % also, if 'success' is still equal to 1, update Qj by concatenating qj
                if success==1
                    Qj=[Qj qj];
                end
                kk=kk+1;
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
    gamma_record(:,ii)=bear.vec(eye(n));
end