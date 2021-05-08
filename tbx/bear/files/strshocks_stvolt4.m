function [strshocks_record]=strshocks_stvolt4(beta_gibbs,D_record,YincLags,n,k,It,Bu, Psi_gibbs,p)

for yyy=1:It-Bu
    for kkk=1:n 
Psi_gibbs_new(:,kkk,yyy) = Psi_gibbs{1,kkk}(:,yyy);
    end
end 

% first create the call storing the results
strshocks_record=cell(n,1);


% then loop over iterations
for ii=1:It-Bu
%recover the local mean estimate
Psidraw = Psi_gibbs_new(:,:,ii);
% recover the VAR coefficients, reshaped for convenience
B=reshape(beta_gibbs(:,ii),k,n);
%create the vector Ydraw by subtracting the local mean from the data
Ypsi = YincLags(p+1:end,:)-Psidraw(p+1:end,:);
% ultimately create the RHS and LHS of the demeaned data VAR
temp=lagx(Ypsi,p);
% to build X, take off the n initial columns of current data
Xdraw=[temp(:,n+1:end)];
Ydraw=temp(:,1:n);


% obtain the residuals from (XXX)
EPS=Ydraw-Xdraw*B;


% then recover the structural marix D
D=reshape(D_record(:,ii),n,n);

% obtain the structural disturbances from (XXX)
ETA=D\EPS';     

   % save in struct_shocks_record
   for jj=1:n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end


end

