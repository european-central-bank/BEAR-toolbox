function [stvol,It,Bu,pick,pickf,bex,AR_default,lambda1,lambda2,lambda3,lambda4,lambda5,gamma,alpha0,delta0,gamma0,zeta0,PriorExcel,priorsexogenous,interface,interinfo5]=interface5(pref,interinfo5)










% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;


% set default values
% if user preferences exist, load them, and attribute them
if exist('userpref5.mat','file')==2
load('userpref5.mat')
% if no user preferences have been saved, run the interface with the default (system) preferences
else
stvol=1;
It=2000;
Bu=1000;
pick=0;
pickf=20;
bex=0;
AR_default=0.8;
lambda1=0.1;
lambda2=0.5;
lambda3=1;
lambda4=100;
lambda5=0.001;
gamma=0.85;
alpha0=0.001;
delta0=0.001;
gamma0=0;
zeta0=10000;
PriorExcel=0;
priorsexogenous=0;
end


% now update information with the cell interinfo5
% this is required to display correct information when using the Back button
if isempty(interinfo5)
else
stvol=interinfo5{1,1};
It=interinfo5{2,1};
Bu=interinfo5{3,1};
pick=interinfo5{4,1};
pickf=interinfo5{5,1};
bex=interinfo5{6,1};
AR_default=interinfo5{7,1};
lambda1=interinfo5{8,1};
lambda2=interinfo5{9,1};
lambda3=interinfo5{10,1};
lambda4=interinfo5{11,1};
lambda5=interinfo5{12,1};
gamma=interinfo5{13,1};
alpha0=interinfo5{14,1};
delta0=interinfo5{15,1};
gamma0=interinfo5{16,1};
zeta0=interinfo5{17,1};
PriorExcel=interinfo5{18,1};
priorsexogenous=interinfo5{19,1};
end




% PHASE OF FIGURE CREATION


% initiate figure
fig=figure('units','pixels','position',[500 200 605 485],'name','Stochastic volatility BVAR: prior specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');


% type of Stochastic volatility BVAR
% create the box title
c1=uicontrol('style','text','unit','pixels','position',[15 450 150 16],'String','Stochastic volatility model','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c2=uibuttongroup('unit','pixels','Position',[15 310 240 135],'SelectionChangeFcn',@cb2);
%create each radiobutton in the group
c3=uicontrol(c2,'Style','radiobutton','String','Standard','Position',[15 105 180 18],'FontName','Times New Roman','FontSize',10);
c4=uicontrol(c2,'Style','radiobutton','String','Random inertia','Position',[15 75 180 18],'FontName','Times New Roman','FontSize',10);
c5=uicontrol(c2,'Style','radiobutton','String','Large BVAR','Position',[15 45 180 18],'FontName','Times New Roman','FontSize',10);
% Estimation option box
c6=uicontrol('style','text','unit','pixels','position',[290 450 250 16],'String','Estimation options','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c7=uicontrol('style','frame','unit','pixels','position',[290 310 300 135],'ForegroundColor',[0.6 0.6 0.6]);
% Iteration box
c8=uicontrol('style','text','unit','pixels','position',[305 415 200 15],'String','Total number of iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c9=uicontrol('style','edit','unit','pixels','position',[525 413 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb9);
% Iteration box
c10=uicontrol('style','text','unit','pixels','position',[305 385 200 15],'String','Number of burn-in iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c11=uicontrol('style','edit','unit','pixels','position',[525 383 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb11);
% replication check box
c12=uicontrol('style','checkbox','unit','pixels','position',[305 355 200 15],'String','','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb12);
c13=uicontrol('style','text','unit','pixels','position',[325 355 200 15],'String','Keep one post-burn draw over','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create edit box
c14=uicontrol('style','edit','unit','pixels','position',[525 353 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb14);
% block exogeneity selection
c15=uicontrol('style','text','unit','pixels','position',[305 325 200 15],'String','Block exogeneity (on Excel)','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c16=uibuttongroup('unit','pixels','Position',[476 323 102 28],'Bordertype','none','SelectionChangeFcn',@cb16);
%create each radiobutton in the group
c17=uicontrol(c16,'Style','radiobutton','String','Yes','Position',[14 4 50 18],'FontName','Times New Roman','FontSize',10);
c18=uicontrol(c16,'Style','radiobutton','String','No','Position',[64 4 35 18],'FontName','Times New Roman','FontSize',10);


% Hyperparameter box
c19=uicontrol('style','text','unit','pixels','position',[15 272 150 16],'String','Hyperparameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c20=uicontrol('style','frame','unit','pixels','position',[15 75 575 195],'ForegroundColor',[0.6 0.6 0.6]);

% AR coefficient on first lag
c21=uicontrol('style','text','unit','pixels','position',[30 240 150 16],'String','Prior AR coefficient','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c144=uicontrol('style','checkbox','unit','pixels','position',[170 240 100 16],'String','Excel','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb144);
c22=uicontrol('style','edit','unit','pixels','position',[230 240 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb22);
set(c144,'Value',PriorExcel);
if PriorExcel==0
    set(c22,'Enable','on');
else
    set(c22,'Enable','off');
end
set(c22,'String',AR_default);

% lambda1 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Overall tightness (&#955;<sub>1</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 210 170 16],gcf);

% create the box
c23=uicontrol('style','edit','unit','pixels','position',[230 208 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb23);
% lambda2 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Cross-variable weighting (&#955;<sub>2</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 180 170 16],gcf);
% create the box
c24=uicontrol('style','edit','unit','pixels','position',[230 178 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb24);

% lambda3 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Lag decay (&#955;<sub>3</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 150 170 16],gcf);
% create the box
c25=uicontrol('style','edit','unit','pixels','position',[230 148 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb25);

% lambda 4
c199=uicontrol('style','text','unit','pixels','position',[30 115 100 20],'String','Exogenous variables','HorizontalAlignment','left','FontName','Times New Roman','FontSize',8);
% create a group of radio buttons
c200=uibuttongroup('unit','pixels','Position',[170 115 120 20],'Bordertype','none','SelectionChangeFcn',@cb200);
% create each radiobutton in the group
c201=uicontrol(c200,'Style','radiobutton','String','Excel','Position',[15 1 50 18],'FontName','Times New Roman','FontSize',8);
c202=uicontrol(c200,'Style','radiobutton','String','Default','Position',[62 1 50 18],'FontName','Times New Roman','FontSize',8);
% default value for choice of priors on exogeneous
if priorsexogenous==0
   set(c200,'SelectedObject',c202);
   lambda4=100;
elseif priorsexogenous==1
   set(c200,'SelectedObject',c201);
   lambda4=0.1;
end
if priorsexogenous==0
   set(c200,'SelectedObject',c202);
   lambda4=100;
elseif priorsexogenous==1
   set(c200,'SelectedObject',c201);
   lambda4=0.1;
end

% create the box
%c26=uicontrol('style','edit','unit','pixels','position',[230 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb26);
% lambda5 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Block exogeneity shrinkage (&#955;<sub>5</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 90 170 16],gcf);
% create the box
c27=uicontrol('style','edit','unit','pixels','position',[230 88 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb27);
% gamma hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">AR coefficient on residual variance (&#947)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 240 190 16],gcf);
% create the box
c28=uicontrol('style','edit','unit','pixels','position',[525 238 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb28);
% alpha0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG shape on residual variance (&#945;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 210 190 16],gcf);
% create the box
c29=uicontrol('style','edit','unit','pixels','position',[525 208 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb29);
% delta0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG scale on residual variance (&#948;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 180 190 16],gcf);
% create the box
c30=uicontrol('style','edit','unit','pixels','position',[525 178 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb30);
% gamma0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black"> Prior mean on inertia (&#947;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 150 190 16],gcf);
% create the box
c31=uicontrol('style','edit','unit','pixels','position',[525 148 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb31);
% zeta0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Prior variance on inertia (&#950;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[325 120 190 16],gcf);
% create the box
c32=uicontrol('style','edit','unit','pixels','position',[525 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb32);


% Back button
c33=uicontrol('style','pushbutton','unit','pixels','position',[350 30 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb33);
% OK button
c34=uicontrol('style','pushbutton','unit','pixels','position',[435 30 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb34);
% cancel button
c35=uicontrol('style','pushbutton','unit','pixels','position',[520 30 70 25],'String',' Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb35);


%centering interface
movegui(gcf,'center')

% DEFAULT VALUES

if stvol==1
set(c2,'SelectedObject',c3);
set(c31,'Enable','off');
set(c32,'Enable','off');
elseif stvol==2
set(c2,'SelectedObject',c4);
set(c28,'Enable','off');
set(c31,'Enable','on');
set(c32,'Enable','on');
elseif stvol==3
set(c2,'SelectedObject',c5);
set(c17,'Enable','off');
set(c18,'Enable','off');
set(c31,'Enable','off');
set(c32,'Enable','off');
end

set(c9,'String',It);
set(c11,'String',Bu);
set(c12,'Value',pick);
if pick==0
set(c14,'Enable','off');
elseif pick==1
set(c14,'Enable','on');
end
set(c14,'String',pickf);
if bex==0
set(c16,'SelectedObject',c18);
set(c27,'Enable','off');
elseif bex==1
set(c16,'SelectedObject',c17);
end

set(c22,'String',AR_default);
set(c23,'String',lambda1);
set(c24,'String',lambda2);
set(c25,'String',lambda3);
%set(c26,'String',lambda4);
set(c27,'String',lambda5);
set(c28,'String',gamma);
set(c29,'String',alpha0);
set(c30,'String',delta0);
set(c31,'String',gamma0);
set(c32,'String',zeta0);



% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb2(hObject,callbackdata)

   if get(c2,'SelectedObject')==c3
   stvol=1;
   set(c17,'Enable','on');
   set(c18,'Enable','on');
      if bex==1
      set(c27,'Enable','on');
      end
   set(c28,'Enable','on');      
   set(c31,'Enable','off');
   set(c32,'Enable','off');

   elseif get(c2,'SelectedObject')==c4
   stvol=2;
   set(c17,'Enable','on');
   set(c18,'Enable','on');
      if bex==1
      set(c27,'Enable','on');
      end
   set(c28,'Enable','off');
   set(c31,'Enable','on');
   set(c32,'Enable','on');
   
   elseif get(c2,'SelectedObject')==c5
   stvol=3;
   bex=0;
   set(c16,'SelectedObject',c18);
   set(c17,'Enable','off');
   set(c18,'Enable','off');
   set(c27,'Enable','off');
   set(c28,'Enable','on');
   set(c31,'Enable','off');
   set(c32,'Enable','off');
   end

end


function cb9(hObject,callbackdata)
It=str2num(get(c9,'String'));
end


function cb11(hObject,callbackdata)
Bu=str2num(get(c11,'String'));
end


function cb12(hObject,callbackdata)
pick=get(c12,'Value');
   if pick==0
   set(c14,'Enable','off');
   elseif pick==1
   set(c14,'Enable','on');
   end
end


function cb14(hObject,callbackdata)
pickf=str2num(get(c14,'String'));
end


function cb16(hObject,callbackdata)
   if get(c16,'SelectedObject')==c17
   bex=1;
   set(c27,'Enable','on');
   elseif get(c16,'SelectedObject')==c18
   bex=0;
   set(c27,'Enable','off');
   end
end


function cb22(hObject,callbackdata)
AR_default=str2num(get(c22,'String'));
end

function cb144(hObject,callbackdata)
   PriorExcel=get(c144,'Value');
   if PriorExcel==0
   set(c22,'Enable','on');
   elseif PriorExcel==1
   set(c22,'Enable','off');
   end
end


function cb23(hObject,callbackdata)
lambda1=str2num(get(c23,'String'));
end


function cb24(hObject,callbackdata)
lambda2=str2num(get(c24,'String'));
end


function cb25(hObject,callbackdata)
lambda3=str2num(get(c25,'String'));
end

function cb200(hObject,callbackdata)
    if get(c200,'SelectedObject')==c201
    priorsexogenous=1;
    lambda4=0.1;
    elseif get(c200,'SelectedObject')==c202
    priorsexogenous=0;
    lambda4=100;
    end
end

%function cb26(hObject,callbackdata)
%lambda4=str2num(get(c26,'String'));
%end

function cb27(hObject,callbackdata)
lambda5=str2num(get(c27,'String'));
end


function cb28(hObject,callbackdata)
gamma=str2num(get(c28,'String'));
end


function cb29(hObject,callbackdata)
alpha0=str2num(get(c29,'String'));
end


function cb30(hObject,callbackdata)
delta0=str2num(get(c30,'String'));
end


function cb31(hObject,callbackdata)
gamma0=str2num(get(c31,'String'));
end


function cb32(hObject,callbackdata)
zeta0=str2num(get(c32,'String'));
end


function cb33(hObject,callbackdata)
validation=1;
close(fig)
end


function cb34(hObject,callbackdata)
% preliminary elements to be able to use Tex interpreter in error messages
messge.Interpreter='tex';
messge.WindowStyle='modal';
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(It)
   msgbox('Total number of iterations is missing. Please indicate a value.');
   elseif isempty(Bu)
   msgbox('Number of burn-in iterations is missing. Please indicate a value.');
   elseif isempty(pickf)
   msgbox('Number of iterations between two retained draws is missing. Please indicate a value.');
   elseif isempty(AR_default)
   msgbox('Auto-regressive coefficient missing. Please indicate a value.');
   elseif isempty(lambda1)
   msgbox('Overall tightness coefficient (\lambda_1) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda2)
   msgbox('Cross-variable weighting coefficient (\lambda_2) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda3)
   msgbox('Lag decay coefficient (\lambda_3) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda4)
   msgbox('Exogenous variable tightness coefficient (\lambda_4) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda5)
   msgbox('Block exogeneity shrinkage coefficient (\lambda_5) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(alpha0)
   msgbox('Inverse Gamma shape parameter on residual variance (\alpha_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(delta0)
   msgbox('Inverse Gamma scale parameter on residual variance (\delta_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(gamma0)
   msgbox('Prior mean on inertia (\gamma_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(zeta0)
   msgbox('Prior variance on inertia (\zeta_0) is missing. Please indicate a value.','Value',messge);
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=2;
   close(fig)
   end
end


function cb35(hObject,callbackdata)
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

   save('userpref5.mat','stvol','It','Bu','pick','pickf','bex','AR_default','lambda1','lambda2','lambda3','lambda4','lambda5','gamma','alpha0','delta0','gamma0','zeta0','PriorExcel','priorsexogenous');

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






