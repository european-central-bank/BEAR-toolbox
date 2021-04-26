function [nconds cforecast_record cforecast_estimates]=panel4cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband)



% initiate the cell recording the Gibbs sampler draws
cforecast_record={};
cforecast_estimates={};

% because conditional forecasts can be computed for many (potentially all) units, loop over units
for ii=1:N
% check wether there are any conditions on unit ii
temp=cfconds(:,:,ii);
nconds(ii,1)=numel(temp(cellfun(@(x) any(~isempty(x)),temp)));

   % if there are conditions
   if nconds(ii,1)~=0
   % prepare the elements for conditional forecast estimation, depending on the type of conditional forecasts
   temp1=cfconds(:,:,ii);
      if CFt==1
      temp2={};
      temp3=[];
      elseif CFt==2
      temp2=cfshocks(:,:,ii);
      temp3=cfblocks(:,:,ii);
      end
   % run the Gibbs sampler for unit ii
   cforecast_record(:,:,ii)=cforecast(data_endo_a(:,:,ii),data_exo_a,data_exo_p,It,Bu,Fperiods,temp1,temp2,temp3,CFt,const,beta_gibbs(:,:,ii),D_record(:,:,ii),gamma_record(:,:,ii),n,m,p,k,q);
   % then obtain point estimates and credibility intervals
   cforecast_estimates(:,:,ii)=festimates(cforecast_record(:,:,ii),n,Fperiods,Fband);

   % if there are no conditions, return empty elements
   elseif nconds(ii,1)==0
   cforecast_record(:,:,ii)=cell(n,1);
   cforecast_estimates(:,:,ii)=cell(n,1);
   end
end


































