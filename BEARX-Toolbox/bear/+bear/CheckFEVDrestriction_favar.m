function[success]=CheckFEVDrestriction_favar(ortirfmatrix,gamma,IRFperiods,n,rowrelativeFEVD,clmrelativeFEVD,rowabsoluteFEVD,clmabsoluteFEVD,FEVDresperiods,rowsFEVD,nFEVDresX,LFEVD) 

%% Phase 1: Compute FEVD
temp=cell(nFEVDresX,n+1);

 % scale gamma
for oo=1:nFEVDresX
    for ll=1:n
       %favar_gamma{oo}(:,ll)=LFEVD(oo,ll)*gamma(:,ll);
       favar_gamma{oo}(:,ll)=gamma(:,ll);
    end
 end
                    
       
%%reorganize orthogonalized irf in cell
% deal with shocks in turn
   for jj=1:n
      % loop over variables
      for kk=1:nFEVDresX
         % loop over IRF periods
         for ll=1:IRFperiods
         irf_estimates{kk,jj}(1,ll)=ortirfmatrix(kk,jj,ll);
         end
      end
   end  
   
% start by filling the first column (shock) of every Tij matrix in the cell
% loop over rows of temp
for jj=1:nFEVDresX
   % loop over columns of temp
   for ii=1:n
   % square each element
   temp{jj,ii}(1,1)=irf_estimates{jj,ii}(1,1).^2;
   end
end
% fill all the other entries of the Tij matrices
% loop over rows of temp
for jj=1:nFEVDresX
   % loop over columns of temp
   for ii=1:n
      % loop over remaining columns
      for kk=2:IRFperiods
      % define the column as the square of the corresponding column in orthogonalised_irf_record
      % additioned to the value of the preceeding columns, which creates the cumulation
      temp{jj,ii}(1,kk)=irf_estimates{jj,ii}(1,kk)^2+temp{jj,ii}(:,kk-1);
      end
   end
end
% multiply each matrix in the cell by the variance of the structural shocks
% loop over rows of temp
for ii=1:nFEVDresX
% loop over columns of temp
   for jj=1:n
   % multiply column jj of the matrix by the variance of the structural shock
   temp{ii,jj}(1,:)=temp{ii,jj}(1,:)*favar_gamma{ii}(jj,jj);
   end
end
% obtain now the values for Ti, the (n+1)th matrix of each row
% loop over rows of temp
for ii=1:nFEVDresX
% start the summation over Tij matrices
temp{ii,n+1}=temp{ii,1};
   % sum over remaining columns %%%%%why is this splitt here?
   for jj=2:n
   temp{ii,n+1}=temp{ii,n+1}+temp{ii,jj};
   end      
end

% create the output cell fevd_record
fevd_estimates=cell(nFEVDresX,n);
% fill the cell
% loop over rows of fevd_estimates
for ii=1:nFEVDresX
   % loop over columns of fevd_estimates
   for jj=1:n
   % define the matrix Vfij as the division (pairwise entry) of Tfij by Tfj
   fevd_estimates{ii,jj}=temp{ii,jj}./temp{ii,n+1};
   end
end

%cell {Y,X}(Z,1) corresponds to the variance of the forecast error of variable
%Y, explained by Shock X in period Z

%% Phase 2: Check FEVD restrictions
numberofsuccesses = 0; %initiliaze number of successes (per restriction). In the end this should be equal to the number of restrictions
restriction_number_relative=0; %initiate restriction counter
restriction_number_absolute=0; %initiate restriction counter

% Check the restrictions
%loop over variables
for yy=1:nFEVDresX  %rowsFEVD are the variables with FEVD restriction
FEVDofVariable = nan(n,IRFperiods);
% extract FEVD of that variable
FEVDofVariablecell=fevd_estimates(yy,:);
for xx=1:n
    FEVDofVariable(xx,:)=FEVDofVariablecell{1,xx};
end
%determine the type of restriction for this variable by checking if the
%number of variable exists in the row vector of either absolute or
%relative restrictions. Cant exist in both.
testrelative=ismember(rowrelativeFEVD',rowsFEVD(yy,1));
testabsolute=ismember(rowabsoluteFEVD',rowsFEVD(yy,1));

if sum(testrelative)==1 %if the restriction corresponding to the variable is a relative restriction
restriction_number_relative=restriction_number_relative+1; %iterate relative restriction forward 
Periodstocheck = FEVDresperiods{rowrelativeFEVD(restriction_number_relative,1), clmrelativeFEVD(restriction_number_relative,1)};
FEVDperiods = []; %expand the restriction periods as they are only entered in intervalls
for ii=1:size(Periodstocheck,1) %1
FEVDperiods=[FEVDperiods Periodstocheck(ii,1):Periodstocheck(ii,2)]; %these are the periods corresponding to this FEVD restriction
end
okay=0;
for zz=1:length(FEVDperiods) %loop over periods
 FEVDtocheck = FEVDofVariable(:,FEVDperiods(1,zz)+1); %add plus 1 since bear convention starts from 0  FEVDtocheck = FEVDofVariable(:,FEVDperiods(1,zz)+1);
[~,best]=max(FEVDtocheck);      %%find the the highest contribution

if best==clmrelativeFEVD(restriction_number_relative,1) % FEVD contribution on the restricted variable of the corresponding shock is the largest relative to the other shocks
    okay=okay+1; %one more period corresponding to restriction yy is fullfilled
end
end %%end of loop over periods

if okay == length(FEVDperiods) %if all periods are fine 
    numberofsuccesses=numberofsuccesses+1; 
end
end

if sum(testabsolute)==1
restriction_number_absolute =restriction_number_absolute+1;
Periodstocheck = FEVDresperiods{rowabsoluteFEVD(restriction_number_absolute,1), clmabsoluteFEVD(restriction_number_absolute,1)};
FEVDperiods = []; %expand the restriction periods as they are only entered in intervalls
for ii=1:size(Periodstocheck,1) %1
FEVDperiods=[FEVDperiods Periodstocheck(ii,1):Periodstocheck(ii,2)]; %these are the periods corresponding to this FEVD restriction
end
% finally extract the FEVD to check
okay=0;
for zz=1:length(FEVDperiods) %loop over periods
 FEVDtocheck=FEVDofVariable(clmabsoluteFEVD(restriction_number_absolute,1),FEVDperiods(1,zz)+1); %add plus 1 since bear convention starts from 0 %%FEVDtocheck = FEVDofVariable(yy,FEVDperiods(1,zz)+1);

if FEVDtocheck > 0.5 % FEVD contribution of the shock is larger than 0.5, i.e. >50% of the FEVD of the restricted variable must be explained by corresponding shock
    okay=okay+1;
end
end %end of loop over periods

if okay==length(FEVDperiods) %if all periods are fine 
    numberofsuccesses=numberofsuccesses+1;
end

end %end of loop over kind of FEVD restrictions
end %end of loop over FEVD restrictions

if numberofsuccesses==length(rowsFEVD) %if we have as many successes as restrictions
    success=1;
else 
    success=0;
end

