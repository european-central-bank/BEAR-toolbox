function []=panel5fprint(Units,N,n,endo,rss,r2,r2bar,RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates,stringdates3,Fstartdate,Fcenddate,Fcperiods,fid)





% preliminary tasks: reshape
RMSE=reshape(RMSE,Fcperiods,n,N);
MAE=reshape(MAE,Fcperiods,n,N);
MAPE=reshape(MAPE,Fcperiods,n,N);
Ustat=reshape(Ustat,Fcperiods,n,N);
CRPS_estimates=reshape(CRPS_estimates,Fcperiods,n,N);
S1_estimates=reshape(S1_estimates,Fcperiods,n,N);
S2_estimates=reshape(S2_estimates,Fcperiods,n,N);



% because all the evaluation criteria are unit-specific, loop over units
for ii=1:N


% start with the name of the unit

unitinfo=['Unit: ' Units{ii,1}];
fprintf('%s\n',unitinfo);
fprintf(fid,'%s\n',unitinfo);
fprintf('%s\n','');
fprintf(fid,'%s\n','');


   % loop over endogenous variables
   for jj=1:n

   endoinfo=['Endogenous: ' endo{jj,1}];
   fprintf('%s\n',endoinfo);
   fprintf(fid,'%s\n',endoinfo);
   fprintf('%s\n','');
   fprintf(fid,'%s\n','');




   % in-sample evaluation criteria

   Sevalinfo='In-sample evaluation:';
   fprintf('%s\n',Sevalinfo);
   fprintf(fid,'%s\n',Sevalinfo);

   rssinfo=['Sum of squared residuals: ' num2str(rss(jj,1,ii),'%.2f')];
   fprintf('%s\n',rssinfo);
   fprintf(fid,'%s\n',rssinfo);

   r2info=['R-squared: ' num2str(r2(jj,1,ii),'%.3f')];
   fprintf('%s\n',r2info);
   fprintf(fid,'%s\n',r2info);

   adjr2info=['adj. R-squared: ' num2str(r2bar(jj,1,ii),'%.3f')];
   fprintf('%s\n',adjr2info);
   fprintf(fid,'%s\n',adjr2info);

   fprintf('%s\n','');
   fprintf(fid,'%s\n','');




   % forecast evaluation criteria

   Fevalinfo='Forecast evaluation:';
   fprintf('%s\n',Fevalinfo);
   fprintf(fid,'%s\n',Fevalinfo);

   finfo1=['Evaluation conducted over ' num2str(Fcperiods) ' periods (from ' Fstartdate ' to ' Fcenddate ').'];
   fprintf('%s\n',finfo1);
   fprintf(fid,'%s\n',finfo1);

   temp='fprintf(''%12s';
      for kk=1:Fcperiods-1
      temp=[temp ' %10s'];
      end
   temp=[temp ' %10s\n'','''''];
      for kk=1:Fcperiods
      temp=[temp ',''' stringdates3{kk,1} ''''];
      end
   temp=[temp ');'];
   eval(temp);
   temp='fprintf(fid,''%12s';
      for kk=1:Fcperiods-1
      temp=[temp ' %10s'];
      end
   temp=[temp ' %10s\n'','''''];
      for kk=1:Fcperiods
      temp=[temp ',''' stringdates3{kk,1} ''''];
      end
   temp=[temp ');'];
   eval(temp);
   
   label='RMSE:       ';
   values=RMSE(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='MAE:        ';
   values=MAE(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='MAPE:       ';
   values=MAPE(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='Theil''s U:  ';
   values=Ustat(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='CRPS:       ';
   values=CRPS_estimates(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='Log score 1:';
   values=S1_estimates(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   label='Log score 2:';
   values=S2_estimates(1:Fcperiods,jj,ii)';
   temp='fprintf(''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);
   temp='fprintf(fid,''%12s';
   for kk=1:Fcperiods-1
   temp=[temp ' %10.3f'];
   end
   temp=[temp ' %10.3f\n'''];
   temp=[temp ',label,values);'];
   eval(temp);

   fprintf('%s\n','');
   fprintf(fid,'%s\n','');
   fprintf('%s\n','');
   fprintf(fid,'%s\n','');

   end

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

end














