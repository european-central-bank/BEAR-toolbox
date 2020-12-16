function [tvbvar,It,Bu,pick,pickf,alltirf,gamma,alpha0,delta0,ar,PriorExcel,priorsexogenous,lambda4,interface,interinfo7]=interface7(pref,interinfo7)










% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;


% set default values
if exist('userpref7.mat','file')==2
load('userpref7.mat')
% if no user preferences have been saved, run the interface with the default (system) preferences
else
tvbvar=1;
It=2000;
Bu=1000;
pick=0;
pickf=20;
alltirf=0;
gamma=0.85;
alpha0=0.001;
delta0=0.001;
ar=0;
PriorExcel=0;
priorsexogenous=0;
lambda4=100;
end


% now update information with the cell interinfo7
% this is required to display correct information when using the Back button
if isempty(interinfo7)
else
tvbvar=interinfo7{1,1};
It=interinfo7{2,1};
Bu=interinfo7{3,1};
pick=interinfo7{4,1};
pickf=interinfo7{5,1};
alltirf=interinfo7{6,1};
gamma=interinfo7{7,1};
alpha0=interinfo7{8,1};
delta0=interinfo7{9,1};
ar=interinfo7{10,1};
PriorExcel=interinfo7{11,1};
priorsexogenous=interinfo7{12,1};
end




% PHASE OF FIGURE CREATION


% initiate figure
fig=figure('units','pixels','position',[500 200 605 365],'name','Time-varying BVAR: prior specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');
% type of Stochastic volatility BVAR
% create the box title
c1=uicontrol('style','text','unit','pixels','position',[15 330 150 16],'String','Time-varying model','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c2=uibuttongroup('unit','pixels','Position',[15 190 240 135],'SelectionChangeFcn',@cb2);
%create each radiobutton in the group
c3=uicontrol(c2,'Style','radiobutton','String','VAR coefficients','Position',[15 105 180 18],'FontName','Times New Roman','FontSize',10);
c4=uicontrol(c2,'Style','radiobutton','String','General','Position',[15 75 180 18],'FontName','Times New Roman','FontSize',10);

% Estimation option box
c5=uicontrol('style','text','unit','pixels','position',[290 330 250 16],'String','Estimation options','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c6=uicontrol('style','frame','unit','pixels','position',[290 190 300 135],'ForegroundColor',[0.6 0.6 0.6]);
% Iteration box
c7=uicontrol('style','text','unit','pixels','position',[305 295 200 15],'String','Total number of iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c8=uicontrol('style','edit','unit','pixels','position',[525 293 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb8);
% Burn-in box
c9=uicontrol('style','text','unit','pixels','position',[305 265 200 15],'String','Number of burn-in iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c10=uicontrol('style','edit','unit','pixels','position',[525 263 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb10);
% replication check box
c11=uicontrol('style','checkbox','unit','pixels','position',[305 235 200 15],'String','','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb11);
c12=uicontrol('style','text','unit','pixels','position',[325 235 200 15],'String','Keep one post-burn draw over','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create edit box
c13=uicontrol('style','edit','unit','pixels','position',[525 233 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb13);
% replication check box
c22=uicontrol('style','checkbox','unit','pixels','position',[305 205 200 15],'String','','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb22);
c23=uicontrol('style','text','unit','pixels','position',[325 205 200 15],'String','IRFs for all sample periods','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Hyperparameter box
c14=uicontrol('style','text','unit','pixels','position',[15 156 150 16],'String','Hyperparameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c15=uicontrol('style','frame','unit','pixels','position',[15 75 575 75],'ForegroundColor',[0.6 0.6 0.6]);
% gamma hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">AR coefficient on residual variance (&#947)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 120 190 16],gcf);
% create the box
c16=uicontrol('style','edit','unit','pixels','position',[230 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb16);
% alpha0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG shape on residual variance (&#945;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 120 190 16],gcf);
% create the box
c17=uicontrol('style','edit','unit','pixels','position',[525 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb17);
% delta0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG scale on residual variance (&#948;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 90 190 16],gcf);
% create the box
c18=uicontrol('style','edit','unit','pixels','position',[525 88 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb18);
% Back button
c19=uicontrol('style','pushbutton','unit','pixels','position',[350 30 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb19);
% OK button
c20=uicontrol('style','pushbutton','unit','pixels','position',[435 30 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb20);
% cancel button
c21=uicontrol('style','pushbutton','unit','pixels','position',[520 30 70 25],'String',' Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb21);




% DEFAULT VALUES

if tvbvar==1
set(c2,'SelectedObject',c3);
set(c11,'Enable','off');
set(c13,'Enable','off');
set(c16,'Enable','off');
set(c17,'Enable','off');
set(c18,'Enable','off');
elseif tvbvar==2
set(c2,'SelectedObject',c4);
set(c11,'Enable','on');
set(c13,'Enable','on');
set(c16,'Enable','on');
set(c17,'Enable','on');
set(c18,'Enable','on');
end
set(c8,'String',It);
set(c10,'String',Bu);
set(c11,'Value',pick);
set(c13,'String',pickf);
if pick==0
set(c13,'Enable','off');
elseif pick==1
set(c13,'Enable','on');
end
set(c22,'Value',alltirf);
set(c16,'String',gamma);
set(c17,'String',alpha0);
set(c18,'String',delta0);




% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb2(hObject,callbackdata)

   if get(c2,'SelectedObject')==c3
   tvbvar=1;
   pick=0;
   set(c11,'Value',pick);
   set(c11,'Enable','off');
   set(c13,'Enable','off');
   set(c16,'Enable','off');
   set(c17,'Enable','off');
   set(c18,'Enable','off');

   elseif get(c2,'SelectedObject')==c4
   tvbvar=2;
   set(c11,'Enable','on');
   set(c13,'Enable','on');
   set(c16,'Enable','on');
   set(c17,'Enable','on');
   set(c18,'Enable','on');
   end

end


function cb8(hObject,callbackdata)
It=str2num(get(c8,'String'));
end


function cb10(hObject,callbackdata)
Bu=str2num(get(c10,'String'));
end


function cb11(hObject,callbackdata)
pick=get(c11,'Value');
   if pick==0
   set(c13,'Enable','off');
   elseif pick==1
   set(c13,'Enable','on');
   end
end


function cb13(hObject,callbackdata)
pickf=str2num(get(c13,'String'));
end


function cb22(hObject,callbackdata)
alltirf=get(c22,'Value');
end


function cb16(hObject,callbackdata)
gamma=str2num(get(c16,'String'));
end


function cb17(hObject,callbackdata)
alpha0=str2num(get(c17,'String'));
end


function cb18(hObject,callbackdata)
delta0=str2num(get(c18,'String'));
end


function cb19(hObject,callbackdata)
validation=1;
close(fig)
end


function cb20(hObject,callbackdata)
% preliminary elements to be able to use Tex interpreter in error messages
messge.Interpreter='tex';
messge.WindowStyle='modal';
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(It)
   msgbox('Total number of iterations is missing. Please indicate a value.');
   elseif isempty(Bu)
   msgbox('Number of burn-in iterations is missing. Please indicate a value.');
   elseif isempty(pickf)
   elseif isempty(gamma)
   msgbox('Autoregressive coefficient on residual variance (\gamma) is missing. Please indicate a value.','Value',messge);
   msgbox('Number of iterations between two retained draws is missing. Please indicate a value.');
   elseif isempty(alpha0)
   msgbox('Inverse Gamma shape parameter on residual variance (\alpha_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(delta0)
   msgbox('Inverse Gamma scale parameter on residual variance (\delta_0) is missing. Please indicate a value.','Value',messge);
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=2;
   close(fig)
   end
end


function cb21(hObject,callbackdata)
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

   % if user's preferences have been selected
   if pref.pref==1
   save('userpref7.mat','tvbvar','It','Bu','pick','pickf','alltirf','gamma','alpha0','delta0','ar','PriorExcel','priorsexogenous','lambda4');
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



% declare end of nested function
end






