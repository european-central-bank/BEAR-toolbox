function []=algoinfo(checkiter,Qsuccess,elapsedtime,It,Bu);



% compute first the acceptance rate
accrate=Qsuccess/checkiter;

% compute elapsed time (in days, hours, and minutes)
days=floor(elapsedtime/86400);
hours=floor((elapsedtime-days*86400)/3600);
minutes=floor((elapsedtime-days*86400-hours*3600)/60);

% compute estimated remaining time
if Qsuccess~=0
remainingtime=((It-Bu)/Qsuccess)*elapsedtime-elapsedtime;
remainingdays=floor(remainingtime/86400);
remaininghours=floor((remainingtime-remainingdays*86400)/3600);
remainingminutes=floor((remainingtime-remainingdays*86400-remaininghours*3600)/60);
else
remainingtime=inf;
remainingdays=inf;
remaininghours=inf;
remainingminutes=inf;
end





% Phase of figure creation

% first declare the 'No' variable; it will abort the code if the 'No' button is pressed by the user on the GUI, or if the window is closed
No=1;
% initiate figure
fig=figure('units','pixels','position',[500 380 480 330],'name', 'Sign restriction algorithm','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');
% row 1 of text
temp=[num2str(checkiter) ' iterations of the sign restriction algorithm have been performed.'];
c1=uicontrol('style','text','unit','pixels','position',[13 290 600 16],'String',temp,'HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 2 of text
temp=[num2str(Qsuccess) ' out of ' num2str(checkiter) ' iterations were succesfull, implying an acceptance rate of ' num2str(100*accrate,'% .3f') ' %.'];
c2=uicontrol('style','text','unit','pixels','position',[13 260 600 16],'String',temp,'HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 3 of text
c3=uicontrol('style','text','unit','pixels','position',[13 230 600 16],'String','The elapsed algorithm time to obtain these results is:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 4 of text
temp=[num2str(days) ' days, ' num2str(hours) ' hours, and ' num2str(minutes) ' minutes.'];
c4=uicontrol('style','text','unit','pixels','position',[13 200 600 16],'String',temp,'HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 5 of text
temp=[num2str(It-Bu) ' successful iterations are requested.'];
c5=uicontrol('style','text','unit','pixels','position',[13 170 600 16],'String',temp,'HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 6 of text
c6=uicontrol('style','text','unit','pixels','position',[13 140 600 16],'String','Consequently, the approximate time remaining to complete the algorithm is:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% row 7 of text
if Qsuccess~=0
temp=[num2str(remainingdays) ' days, ' num2str(remaininghours) ' hours, and ' num2str(remainingminutes) ' minutes.'];
c7=uicontrol('style','text','unit','pixels','position',[13 110 600 16],'String',temp,'HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
elseif Qsuccess==0
c7=uicontrol('style','text','unit','pixels','position',[13 110 600 16],'String','Infinity','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
end
% row 8 of text
c8=uicontrol('style','text','unit','pixels','position',[13 80 600 16],'String','Do you want to continue to run the algorithm?','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Yes button
c9=uicontrol('style','pushbutton','unit','pixels','position',[280 30 70 25],'String',' YES','HorizontalAlignment','center','FontSize',9,'CallBack',@cb9);
% No button
c10=uicontrol('style','pushbutton','unit','pixels','position',[360 30 70 25],'String',' NO','HorizontalAlignment','center','FontSize',9,'CallBack',@cb10);





% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS

function cb9(hObject,callbackdata)
No=0;
close(fig)
end
function cb10(hObject,callbackdata)
close(fig)
end




% consequence of the choice: stop the code, or continue

% stop programme execution until the user chooses either yes or no
uiwait(fig);
if No==1
msgbox('Algorithm stopped by the user. Please restart the program.');
error('User cancellation');
end



% declare end of general nested function
end

