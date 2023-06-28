function []=tvbvardisp(beta_t_median,beta_t_std,beta_t_lbound,beta_t_ubound,sigma_median,sigma_t_lbound,sigma_t_median,sigma_t_ubound,Xbart,Y,yt,n,m,p,k,q,T,tvbvar,gamma,alpha0,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref)







% before displaying and saving the results, start estimating the evaluation measures for the model

% reshape the cells of results for beta
B_t_median=reshape(cell2mat(beta_t_median),T,q)';
B_t_std=reshape(cell2mat(beta_t_std),T,q)';
B_t_lbound=reshape(cell2mat(beta_t_lbound),T,q)';
B_t_ubound=reshape(cell2mat(beta_t_ubound),T,q)';


% compute predictions and residuals
for jj=1:T
Ytilde(:,jj)=Xbart{jj,1}*B_t_median(:,jj);
EPStilde(:,jj)=yt(:,:,jj)-Ytilde(:,jj);
end
Ytilde=Ytilde';
EPStilde=EPStilde';


% check first whether the model is stationary, using (a.7.2)
[stationary eigmodulus]=bear.checkstable(B_t_median(:,end),n,p,k);


% Compute then the sum of squared residuals
% compute first the RSS matrix, defined in (a.8.4)
RSS=EPStilde'*EPStilde;
% retain only the diagonal elements to get the vector of RSSi values
rss=diag(RSS);


% Go on calculating R2
% generate Mbar
Mbar=eye(T)-ones(T,T)/T;
% then compute the TSS matrix, defined in (a.8.7)
TSS=Y'*Mbar*Y;
% generate the R2 matrix in (a.8.8)
R2=eye(n)-RSS./TSS;
% retain only the diagonal elements to get the vector of R2 values
r2=diag(R2);


% then calculate the adjusted R2, using (a.8.9)
R2bar=eye(n)-((T-1)/(T-k))*(eye(n)-R2);
% retain only the diagonal elements to get the vector of R2bar values
r2bar=diag(R2bar);







% now start displaying and saving the results


% preliminary task: create and open the txt file used to save the results

filelocation=fullfile(pref.results_path, pref.results_sub + ".txt");
fid=fopen(filelocation,'wt');

% print toolbox header

fprintf('%s\n','');
fprintf(fid,'%s\n','');

% print the list of contributors
bear.printcontributors(fid);

% print then estimation results

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

toolboxinfo='BEAR toolbox estimates';
fprintf('%s\n',toolboxinfo);
fprintf(fid,'%s\n',toolboxinfo);

time=clock;
datestring=datestr(time);
dateinfo=['Date: ' datestring(1,1:11) '   Time: ' datestring(1,13:17)];
fprintf('%s\n',dateinfo);
fprintf(fid,'%s\n',dateinfo);

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

VARtypeinfo='Time-varying BVAR';
fprintf('%s\n',VARtypeinfo);
fprintf(fid,'%s\n',VARtypeinfo);


if tvbvar==1
modelinfo='Time-varing BVAR: VAR coefficients only';
elseif tvbvar==2
modelinfo='Time-varing BVAR: general';
end
fprintf('%s\n',modelinfo);
fprintf(fid,'%s\n',modelinfo);


if IRFt==1
SVARinfo='structural decomposition: none'; 
elseif IRFt==2
SVARinfo='structural decomposition: choleski factorisation'; 
elseif IRFt==3
SVARinfo='structural decomposition: triangular factorisation'; 
elseif IRFt==4
SVARinfo='structural decomposition: sign restrictions'; 
end
fprintf('%s\n',SVARinfo);
fprintf(fid,'%s\n',SVARinfo);

temp='endogenous variables: ';
for ii=1:n
temp=[temp ' ' endo{ii,1} ' '];
end
endoinfo=temp;
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);

temp='exogenous variables: ';
if const==0 && m==0
temp=[temp ' none'];
elseif const==1 && m==1
temp=[temp ' constant '];
elseif const==0 && m>0
   for ii=1:m-1
   temp=[temp ' ' exo{ii,1} ' '];
   end
elseif const==1 && m>1
temp=[temp ' constant '];
   for ii=1:m-1
   temp=[temp ' ' exo{ii,1} ' '];
   end
end
exoinfo=temp;
fprintf('%s\n',exoinfo);
fprintf(fid,'%s\n',exoinfo);

sampledateinfo=['estimation sample: ' startdate '-' enddate];
fprintf('%s\n',sampledateinfo);
fprintf(fid,'%s\n',sampledateinfo);

samplelengthinfo=['sample size (omitting initial conditions): ' num2str(T)];
fprintf('%s\n',samplelengthinfo);
fprintf(fid,'%s\n',samplelengthinfo);

if tvbvar==2
hyperparam1=['AR coefficient on residual variance (gamma):    ' num2str(gamma)];
fprintf('%s\n',hyperparam1);
fprintf(fid,'%s\n',hyperparam1);

hyperparam2=['IG shape on residual variance (alpha0):         ' num2str(alpha0)];
fprintf('%s\n',hyperparam2);
fprintf(fid,'%s\n',hyperparam2);

hyperparam3=['IG scale on residual variance (delta0):         ' num2str(alpha0)];
fprintf('%s\n',hyperparam3);
fprintf(fid,'%s\n',hyperparam3);

end





% display coefficient estimates


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


coeffinfo=['VAR coefficients (beta): posterior estimates'];
fprintf('%s\n',coeffinfo);
fprintf(fid,'%s\n',coeffinfo);


for ii=1:n


fprintf('%s\n','');
fprintf(fid,'%s\n','');
if ii~=1
fprintf('%s\n','');
fprintf(fid,'%s\n','');
end


endoinfo=['Endogenous: ' endo{ii,1}];
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);


coeffheader=fprintf('%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');
coeffheader=fprintf(fid,'%25s %15s %15s %15s %15s\n','','Median','St.dev','Low.bound','Upp.bound');


% handle the endogenous
   for jj=1:n
      for kk=1:p
      values=[B_t_median((ii-1)*k+n*(kk-1)+jj,end) B_t_std((ii-1)*k+n*(kk-1)+jj,end) B_t_lbound((ii-1)*k+n*(kk-1)+jj,end) B_t_ubound((ii-1)*k+n*(kk-1)+jj,end)];
      fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',strcat(endo{jj,1},'(-',int2str(kk),')'),values);
      end
   end


% handle the exogenous
   % if there is no constant:
   if const==0
      % if there is no exogenous at all, obvioulsy, don't display anything
      if m==0
      % if there is no constant but some other exogenous, display them
      else
         for jj=1:m
         values=[B_t_median(ii*k-m+jj,end) B_t_std(ii*k-m+jj,end) B_t_lbound(ii*k-m+jj,end) B_t_ubound(ii*k-m+jj,end)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   % if there is a constant
   else
   % display the results related to the constant
         values=[B_t_median(ii*k-m+1,end) B_t_std(ii*k-m+1,end) B_t_lbound(ii*k-m+1,end) B_t_ubound(ii*k-m+1,end)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n','Constant',values);
      % if there is no other exogenous, stop here
      if m==1
      % if there are other exogenous, display their results
      else
         for jj=1:m-1
         values=[B_t_median(ii*k-m+jj+1,end) B_t_std(ii*k-m+jj+1,end) B_t_lbound(ii*k-m+jj+1,end) B_t_ubound(ii*k-m+jj+1,end)];
         fprintf('%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         fprintf(fid,'%25s %15.3f %15.3f %15.3f %15.3f\n',exo{jj,1},values);
         end
      end
   end


fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display evaluation measures
rssinfo=['Sum of squared residuals: ' num2str(rss(ii,1),'%.2f')];
fprintf('%s\n',rssinfo);
fprintf(fid,'%s\n',rssinfo);


r2info=['R-squared: ' num2str(r2(ii,1),'%.3f')];
fprintf('%s\n',r2info);
fprintf(fid,'%s\n',r2info);


adjr2info=['adj. R-squared: ' num2str(r2bar(ii,1),'%.3f')];
fprintf('%s\n',adjr2info);
fprintf(fid,'%s\n',adjr2info);


end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');



% display VAR stability results
eigmodulus=reshape(eigmodulus,p,n);
stabilityinfo1=['Roots of the characteristic polynomial (modulus):'];
fprintf('%s\n',stabilityinfo1);
fprintf(fid,'%s\n',stabilityinfo1);
for ii=1:p
temp=num2str(eigmodulus(ii,1),'%.3f');
   for jj=2:n
   temp=[temp,'  ',num2str(eigmodulus(ii,jj),'%.3f')];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end
if stationary==1;
stabilityinfo2=['No root lies outside the unit circle.'];
stabilityinfo3=['The estimated VAR model satisfies the stability condition'];
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
else
stabilityinfo2=['Warning: at leat one root lies on or outside the unit circle.'];
stabilityinfo3=['The estimated VAR model will not be stable'];
fprintf('%s\n',stabilityinfo2);
fprintf(fid,'%s\n',stabilityinfo2);
fprintf('%s\n',stabilityinfo3);
fprintf(fid,'%s\n',stabilityinfo3);
end


fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display posterior for sigma
% reshape median value
sigma_display=reshape(sigma_median,n,n)
sigmainfo1=['sigma (residual covariance matrix): posterior estimates'];
fprintf('%s\n',sigmainfo1);
fprintf(fid,'%s\n',sigmainfo1);
% calculate the (integer) length of the largest number in sigma, for formatting purpose
width=length(sprintf('%d',floor(max(abs(bear.vec(sigma_median))))));
% add a separator, a potential minus sign, and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(sigma_display(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end
% notice about use of long-run values
sigmainfo2=['Note: estimates rely on long-run (homoskedastic) values'];
fprintf('%s\n',sigmainfo2);
fprintf(fid,'%s\n',sigmainfo2);


fclose(fid);




% Finally, display the results in terms of graph
if pref.plot
% plot actual vs. fitted
actualfitted=figure('Tag','BEARresults');
set(actualfitted,'Color',[0.9 0.9 0.9]);
set(actualfitted,'name','model estimation: actual vs fitted')
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii)
hold on
plot(decimaldates1,Y(:,ii),'Color',[0 0 0],'LineWidth',2);
plot(decimaldates1,Ytilde(:,ii),'Color',[1 0 0],'LineWidth',2);
hold off
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal');
   if ii==1
   plotlegend=legend('actual','fitted');
   set(plotlegend,'FontName','Times New Roman');
   end
end


% plot the residuals
residuals=figure('Tag','BEARresults');
set(residuals,'Color',[0.9 0.9 0.9]);
set(residuals,'name','model estimation: residuals')
for ii=1:n
subplot(nrows,ncolumns,ii)
plot(decimaldates1,EPStilde(:,ii),'Color',[0 0 0],'LineWidth',2)
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal');
end


% plot the time-varying variance and covariance estimates (if stochastic volatility)
if tvbvar==2
   varcov=figure('Tag','BEARresults');
   set(varcov,'Color',[0.9 0.9 0.9]);
   set(varcov,'name','model estimation: residual variance and covariance')
   for ii=1:n
      for jj=1:ii
      subplot(n,n,n*(ii-1)+jj)
      hold on
      Xpatch=[decimaldates1' fliplr(decimaldates1')];
      Ypatch=[sigma_t_lbound{ii,jj}' fliplr(sigma_t_ubound{ii,jj}')];
      HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
      set(HDpatch,'facealpha',0.6);
      set(HDpatch,'edgecolor','none');
      plot(decimaldates1,sigma_t_median{ii,jj},'Color',[0.4 0.4 1],'LineWidth',2);
      plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
      hold off
      set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
         % top labels
         if jj==ii
         title(['var(' endo{ii,1} ')'],'FontWeight','normal');
         else
         title(['cov(' endo{jj,1} ',' endo{ii,1} ')'],'FontWeight','normal');
         end
      end   
   end
end


end % pref.plot

% finally, save the results on excel

% compute the cell for actual and fitted
% create the cell that will be saved on excel
afcell={};
% build preliminary elements: space between the tables
vertspace=repmat({''},T+3,1);
% loop over variables (horizontal dimension)
for ii=1:n
% create cell of actual/fitted for variable ii
temp=['actual and fitted: ' endo{ii,1}];
af_i=[temp {''} {''};{''} {''} {''};{''} {'sample'} {'fitted'};stringdates1 num2cell(Y(:,ii)) num2cell(Ytilde(:,ii))];
afcell=[afcell af_i vertspace];
end
% trim
afcell=afcell(:,1:end-1);
% write in excel
if pref.results==1
   bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),afcell,'actual fitted','B2');
end

% then compute the cell for the residuals
% create the cell that will be saved on excel
horzspace=repmat({''},1,n);
rescell=[{'residuals'} horzspace;{''} horzspace;{''} endo';stringdates1 num2cell(EPStilde)];
% write in excel
if pref.results==1
    bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),rescell,'resids','B2');
end





% compute the cell for the time varying VAR coefficients
% initiate the cell that will be saved on excel
varcoeffcell=[{''} {'Periods'} stringdates1';repmat({''},1,T+2)];
% then loop over endogenous
for ii=1:n
% create temporary cell
temp={};
% then loop over VAR coefficients for this variable
   for jj=1:n
      for kk=1:p
      temp=[temp;{''} {[endo{jj,1} ' (-' num2str(kk) ')']} num2cell(B_t_median((ii-1)*k+n*(kk-1)+jj,:))];   
      end
   end
   if  m==0
   else
      if const==1
      temp=[temp;{''} {'Constant'} num2cell(B_t_median(ii*k-m+1,:))];
         for jj=2:m
         temp=[temp;{''} exo{jj-1,1} num2cell(B_t_median(ii*k-m+jj,:))];  
         end
      else
         for jj=1:m
         temp=[temp;{''} exo{jj,1} num2cell(B_t_median(ii*k-m+jj,:))];  
         end
      end
   end        
temp{1,1}=['endogenous: ' endo{ii,1}];
temp=[temp;repmat({''},1,T+2)];
varcoeffcell=[varcoeffcell;temp];
end
% write in excel
if pref.results==1
    bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),varcoeffcell,'coeffs time variation','B2');
end



% finally compute the cell for the time varying variance and covariance (if stochastic volatility)
if tvbvar==2
   % create the cell that will be saved on excel
   varcovcell={};
   % build preliminary elements: space between the tables
   horzspace=repmat({''},2,5*n);
   vertspace=repmat({''},T+3,1);
   % loop over variables (vertical dimension)
   for ii=1:n
   tempcell={};
      % loop over shocks (horizontal dimension)
      for jj=1:ii
      % create cell of hd record for the contribution of shock jj in variable ii fluctuation
         % if a sign restriction identification scheme has been used, use the structural shock labels
         if jj==ii
         temp=['variance of ' endo{ii,1} ' residuals'];
         % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
         else
         temp=['covariance between ' endo{jj,1} ' and ' endo{ii,1} 'residuals'];
         end
      vc_ij=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell(sigma_t_lbound{ii,jj}) num2cell(sigma_t_median{ii,jj}) num2cell(sigma_t_ubound{ii,jj})];
      tempcell=[tempcell vc_ij vertspace];
      end
      % complete with blanks (for repeated covariance values)
      for jj=1:n-ii
      tempcell=[tempcell cell(T+3,5)]; 
      end
   varcovcell=[varcovcell;horzspace;tempcell];
   end
   % trim
   varcovcell=varcovcell(3:end,1:end-1);
   % write in excel
   if pref.results==1
      bear.xlswritegeneral(fullfile(pref.results_path, [pref.results_sub '.xlsx']),varcovcell,'time variation','B2');
   end

end






