function []=panelfprint(n,endo,RMSE,MAE,MAPE,Ustat,CRPS_estimates,S1_estimates,S2_estimates,stringdates3,Fstartdate,Fcenddate,Fcperiods,fid)










% print the results and display them



Fevalinfo='Forecast evaluation:';
fprintf('%s\n',Fevalinfo);
fprintf(fid,'%s\n',Fevalinfo);


fprintf('%s\n','');
fprintf(fid,'%s\n','');


% display the results


finfo1=['Evaluation conducted over ' num2str(Fcperiods) ' periods (from ' Fstartdate ' to ' Fcenddate ').'];
fprintf('%s\n',finfo1);
fprintf(fid,'%s\n',finfo1);

% loop over endogenous variables
for ii=1:n


fprintf('%s\n','');
fprintf(fid,'%s\n','');


endoinfo=['Endogenous: ' endo{ii,1}];
fprintf('%s\n',endoinfo);
fprintf(fid,'%s\n',endoinfo);


temp='fprintf(''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10s'];
   end
temp=[temp ' %10s\n'','''''];
   for jj=1:Fcperiods
   temp=[temp ',''' stringdates3{jj,1} ''''];
   end
temp=[temp ');'];
eval(temp);
temp='fprintf(fid,''%12s';
   for jj=1:Fcperiods-1
   temp=[temp ' %10s'];
   end
temp=[temp ' %10s\n'','''''];
   for jj=1:Fcperiods
   temp=[temp ',''' stringdates3{jj,1} ''''];
   end
temp=[temp ');'];
eval(temp);
   
   
label='RMSE:       ';
values=RMSE(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='MAE:        ';
values=MAE(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='MAPE:       ';
values=MAPE(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='Theil''s U:  ';
values=Ustat(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='CRPS:       ';
values=CRPS_estimates(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='Log score 1:';
values=S1_estimates(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


label='Log score 2:';
values=S2_estimates(1:Fcperiods,ii)';
temp='fprintf(''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);
temp='fprintf(fid,''%12s';
for jj=1:Fcperiods-1
temp=[temp ' %10.3f'];
end
temp=[temp ' %10.3f\n'''];
temp=[temp ',label,values);'];
eval(temp);


end















