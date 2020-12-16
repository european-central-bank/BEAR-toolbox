function [ar,lambda1,lambda2,lambda3,lambda4,lambda5,It,Bu,bex,PriorExcel,priorsexogenous,interface,interinfo3]=interface3(pref,interinfo3)














% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;

% set default values
% if user preferences exist, load them, and attribute them

% User preferences
if exist('userpref3.mat','file')==2
load('userpref3.mat')
% if no user preferences have been saved, run the interface with the system preferences
else
ar=0.8;
lambda1=0.1;
lambda2=0.5;
lambda3=1;
lambda4=100;
lambda5=0.001;
It=2000;
Bu=1000;
bex=0;
PriorExcel=0;
priorsexogenous=0;
end



if isempty(interinfo3)
else
ar=interinfo3{1,1};
lambda1=interinfo3{2,1};
lambda2=interinfo3{3,1};
lambda3=interinfo3{4,1};
lambda4=interinfo3{5,1};
lambda5=interinfo3{6,1};
It=interinfo3{7,1};
Bu=interinfo3{8,1};
bex=interinfo3{9,1};   
PriorExcel=interinfo2{10,1};
priorsexogenous=interinfo2{11,1};
end




% PHASE OF FIGURE CREATION


% initiate the figure
fig=figure('units','pixels','position',[500 300 670 390],'name', 'Mean-adjusted BVAR: prior specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');

% Excel reference for the prior
c1=uicontrol('style','text','unit','pixels','position',[13 340 400 16],'String','Prior confidence intervals for exogenous variables: on Excel','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% box of hyperparameters
% general title for the hyperparameter choices
c2=uicontrol('style','text','unit','pixels','position',[13 300 150 16],'String','Hyperparameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c3=uicontrol('style','frame','unit','pixels','position',[13 90 270 205],'ForegroundColor',[0.6 0.6 0.6]);

% ar coefficient
% create the box title
c4=uicontrol('style','text','unit','pixels','position',[20 264 150 16],'String','Autoregressive coefficient','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c5=uicontrol('style','edit','unit','pixels','position',[210 262 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb5);
% default values for ar coefficient
set(c5,'String',ar);

% lambda1
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Overall tightness (&#955;<sub>1</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 232 170 16],gcf);
% create the box
c6=uicontrol('style','edit','unit','pixels','position',[210 230 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb6);
% default values for lambda1
set(c6,'String',lambda1);

% lambda2
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Cross-variable weighting (&#955;<sub>2</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 200 170 16],gcf);
c7=uicontrol('style','edit','unit','pixels','position',[210 198 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb7);
% default values for lambda2
set(c7,'String',lambda2);

% lambda3
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Lag decay (&#955;<sub>3</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 168 170 16],gcf);
c8=uicontrol('style','edit','unit','pixels','position',[210 166 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb8);
% default values for lambda3
set(c8,'String',lambda3);

% lambda4
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Exogenous variable tightness (&#955;<sub>4</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 136 170 16],gcf);
c9=uicontrol('style','edit','unit','pixels','position',[210 134 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb9);
% default values for lambda4
set(c9,'String',lambda4);

% lambda5
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Block exogeneity shrinkage (&#955;<sub>5</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 104 170 16],gcf);
c10=uicontrol('style','edit','unit','pixels','position',[210 102 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb10);
% default values for lambda5
set(c10,'String',lambda5);

% box for estimation options
% general title
c11=uicontrol('style','text','unit','pixels','position',[323 300 190 16],'String','Estimation parameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c12=uicontrol('style','frame','unit','pixels','position',[323 90 300 205],'ForegroundColor',[0.6 0.6 0.6]);

% total number of iterations
% create the box title
c13=uicontrol('style','text','unit','pixels','position',[330 264 190 16],'String','Total number of iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c14=uicontrol('style','edit','unit','pixels','position',[550 262 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb14);
% default number of iterations
set(c14,'String',It);

% burn-in iterations
% create the box title
c15=uicontrol('style','text','unit','pixels','position',[330 232 190 16],'String','Number of burn-in iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c16=uicontrol('style','edit','unit','pixels','position',[550 230 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb16);
% default burn-in
set(c16,'String',Bu);

% block exogeneity
% create the box title
c17=uicontrol('style','text','unit','pixels','position',[330 100 100 16],'String','Block exogeneity','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c18=uibuttongroup('unit','pixels','Position',[498 96 102 28],'Bordertype','none','SelectionChangeFcn',@cb18);
%create each radiobutton in the group
c19=uicontrol(c18,'Style','radiobutton','String','Yes','Position',[7 4 50 18],'FontName','Times New Roman','FontSize',10);
c20=uicontrol(c18,'Style','radiobutton','String','No','Position',[57 4 35 18],'FontName','Times New Roman','FontSize',10);
% default value for choice of block exogeneity
   if bex==0
   set(c18,'SelectedObject',c20);
   elseif bex==1
   set(c18,'SelectedObject',c19);
   end

% Back button
c21=uicontrol('style','pushbutton','unit','pixels','position',[383 30 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb21);

% OK button
c22=uicontrol('style','pushbutton','unit','pixels','position',[468 30 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb22);

% cancel button
c23=uicontrol('style','pushbutton','unit','pixels','position',[553 30 70 25],'String',' Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb23);





movegui(gcf,'center')
% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb5(hObject,callbackdata)
ar=str2num(get(c5,'String'));
end

function cb6(hObject,callbackdata)
lambda1=str2num(get(c6,'String'));
end

function cb7(hObject,callbackdata)
lambda2=str2num(get(c7,'String'));
end

function cb8(hObject,callbackdata)
lambda3=str2num(get(c8,'String'));
end

function cb9(hObject,callbackdata)
lambda4=str2num(get(c9,'String'));
end

function cb10(hObject,callbackdata)
lambda5=str2num(get(c10,'String'));
end

function cb14(hObject,callbackdata)
It=str2num(get(c14,'String'));
end

function cb16(hObject,callbackdata)
Bu=str2num(get(c16,'String'));
end

function cb18(hObject,callbackdata)
   if get(c18,'SelectedObject')==c19
   bex=1;
   elseif get(c18,'SelectedObject')==c20
   bex=0;
   end
end

function cb21(hObject,callbackdata)
validation=1;
close(fig)
end

function cb22(hObject,callbackdata)
% preliminary elements to be able to use Tex interpreter in error messages
messge.Interpreter='tex';
messge.WindowStyle='modal';
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(ar)
   msgbox('Auto-regressive coefficient missing. Please indicate a prior value.');
   elseif isempty(lambda1)
   msgbox('Overall tightness coefficient (\lambda_1) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda2)
   msgbox('Cross-variable weighting coefficient (\lambda_2) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda3)
   msgbox('Lag decay coefficient (\lambda_3) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda4)
   msgbox('Exogenous variable tightness coefficient (\lambda_4) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda5)
   msgbox('Block exogeneity tightness coefficient (\lambda_5) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(It)
   msgbox('Total number of iterations is missing. Please indicate a value.');
   elseif isempty(Bu)
   msgbox('Number of burn-in iterations is missing. Please indicate a value.');
   else
   validation=2;
   close(fig)
   end
end

function cb23(hObject,callbackdata)
validation=3;
close(fig)
end







% PHASE OF INTERFACE VALIDATION AND SAVING OF USER'S PREFERENCES

% stop programme execution until the user pushes Back, OK or cancel
uiwait(fig);
% if Cancel is pushed
if validation==3
msgbox('Data input canceled by the user. Please restart the programme.');
error('User cancellation');
end

% otherwise, pursue the running of the code
% if OK was pushed and user's preferences have been selected, replace the former save file (if any)
if validation==2

   % then if user's preferences have been selected
   if pref.pref==1

   save('userpref3.mat','ar', 'lambda1', 'lambda2', 'lambda3', 'lambda4', 'lambda5', 'It', 'Bu', 'bex','PriorExcel','priorsexogenous')
   % if the user did not want to save pereferences, do not do save anything
   else
   end

end


% indicate which interface is to be opened next, depending on the user's choice
% if back button was pushed, go back to interface 1
if validation==1
interface='interface1';
% if OK button was pushed, go to interface 6
elseif validation==2
interface='interface6';
end


% finally, declare end of the full nested function
end






