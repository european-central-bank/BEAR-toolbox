function [panel,Units,It,Bu,pick,pickf,ar,lambda1,lambda2,lambda3,lambda4,s0,v0,alpha0,delta0,gama,rho,a0,b0,psi,interface,interinfo4]=interface4(pref,interinfo4)


% keyboard

% global do_plot do_plot2





% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;

% set default values
% if user preferences exist, load them, and attribute them
if exist('userpref4.mat','file')==2
load('userpref4.mat')
% if no user preferences have been saved, run the interface with the default (system) preferences
else
panel=1;
unitnames='';
It=2000;
Bu=1000;
pick=0;
pickf=20;
ar=0.8;
lambda1=0.1;
lambda2=0.5;
lambda3=1;
lambda4=100;
s0=0.001;
v0=0.001;
alpha0=1000;
delta0=1;
gama=0.85;
a0=1000;
b0=1;
rho=0.75;
psi=0.1;
do_plot=0;
end


% now update information with the cell interinfo4
% this is required to display correct information when using the Back button
if isempty(interinfo4)
else
panel=interinfo4{1,1};
unitnames=interinfo4{2,1};
It=interinfo4{3,1};
Bu=interinfo4{4,1};
pick=interinfo4{5,1};
pickf=interinfo4{6,1};
ar=interinfo4{7,1};
lambda1=interinfo4{8,1};
lambda2=interinfo4{9,1};
lambda3=interinfo4{10,1};
lambda4=interinfo4{11,1};
s0=interinfo4{12,1};
v0=interinfo4{13,1};
alpha0=interinfo4{14,1};
delta0=interinfo4{15,1};
gama=interinfo4{16,1};
a0=interinfo4{17,1};
b0=interinfo4{18,1};
rho=interinfo4{19,1};
psi=interinfo4{20,1};
end




% PHASE OF FIGURE CREATION


% initiate figure
fig=figure('units','pixels','position',[500 200 615 695],'name', 'Panel VAR: prior specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');


% Panel VAR type
% create the box title
c1=uicontrol('style','text','unit','pixels','position',[15 660 150 16],'String','Panel model','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c2=uibuttongroup('unit','pixels','Position',[15 485 270 170],'SelectionChangeFcn',@cb2);
%create each radiobutton in the group
c3=uicontrol(c2,'Style','radiobutton','String','Mean group estimator (OLS)','Position',[15 140 180 18],'FontName','Times New Roman','FontSize',10);
c4=uicontrol(c2,'Style','radiobutton','String','Pooled estimator','Position',[15 115 180 18],'FontName','Times New Roman','FontSize',10);
c5=uicontrol(c2,'Style','radiobutton','String','Random effect (Zellner-Hong)','Position',[15 90 180 18],'FontName','Times New Roman','FontSize',10);
c6=uicontrol(c2,'Style','radiobutton','String','Random effect (hierarchical)','Position',[15 65 180 18],'FontName','Times New Roman','FontSize',10);
c7=uicontrol(c2,'Style','radiobutton','String','Static structural factor','Position',[15 40 180 18],'FontName','Times New Roman','FontSize',10);
c8=uicontrol(c2,'Style','radiobutton','String','Dynamic structural factor','Position',[15 15 180 18],'FontName','Times New Roman','FontSize',10);


% Property box
c9=uicontrol('style','text','unit','pixels','position',[320 660 150 16],'String','Properties','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c10=uicontrol('style','frame','unit','pixels','position',[320 485 280 170],'ForegroundColor',[0.6 0.6 0.6]);
% title 1
c11=uicontrol('style','text','unit','pixels','position',[335 625 200 16],'String','Panel VAR properties applying','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% title 2
c12=uicontrol('style','text','unit','pixels','position',[335 600 200 16],'String','to the selected model:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Property 1
c13=uicontrol('style','text','unit','pixels','position',[335 575 200 16],'String','1. Cross-sectional heterogeneity','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Property 2
c14=uicontrol('style','text','unit','pixels','position',[335 550 200 16],'String','2. Dynamic interdependencies','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Property 3
c15=uicontrol('style','text','unit','pixels','position',[335 525 200 16],'String','3. Static interdependencies','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% Property 4
c16=uicontrol('style','text','unit','pixels','position',[335 500 200 16],'String','4. Dynamic heterogeneity','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);


% Unit box
c17=uicontrol('style','text','unit','pixels','position',[15 447 250 16],'String','Enter the list of units, separated by a space','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c18=uicontrol('style','edit','unit','pixels','position',[15 340 270 105],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','Max',2,'CallBack',@cb18);


% Estimation option box
c19=uicontrol('style','text','unit','pixels','position',[320 447 250 16],'String','Estimation options','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c20=uicontrol('style','frame','unit','pixels','position',[320 335 280 110],'ForegroundColor',[0.6 0.6 0.6]);
% Iteration box
c21=uicontrol('style','text','unit','pixels','position',[335 415 200 15],'String','Total number of iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c22=uicontrol('style','edit','unit','pixels','position',[535 413 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb22);
% Iteration box
c23=uicontrol('style','text','unit','pixels','position',[335 385 200 15],'String','Number of burn-in iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c24=uicontrol('style','edit','unit','pixels','position',[535 383 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb24);
% replication check box
c25=uicontrol('style','checkbox','unit','pixels','position',[335 355 200 16],'String','','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb25);
c26=uicontrol('style','text','unit','pixels','position',[355 355 200 15],'String','Keep one post-burn draw over','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create edit box
c27=uicontrol('style','edit','unit','pixels','position',[535 353 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb27);


% Hyperparameter box
c28=uicontrol('style','text','unit','pixels','position',[15 302 150 16],'String','Hyperparameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% frame around the box
c29=uicontrol('style','frame','unit','pixels','position',[15 75 585 225],'ForegroundColor',[0.6 0.6 0.6]);
% AR coefficient on first lag
c30=uicontrol('style','text','unit','pixels','position',[30 270 150 16],'String','Prior AR coefficient','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c31=uicontrol('style','edit','unit','pixels','position',[210 268 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb31);
% lambda1 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Overall tightness (&#955;<sub>1</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 240 170 16],gcf);
% create the box
c32=uicontrol('style','edit','unit','pixels','position',[210 238 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb32);
% lambda2 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Cross-variable weighting (&#955;<sub>2</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 210 170 16],gcf);
% create the box
c33=uicontrol('style','edit','unit','pixels','position',[210 208 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb33);
% lambda3 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Lag decay (&#955;<sub>3</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 180 170 16],gcf);
% create the box
c34=uicontrol('style','edit','unit','pixels','position',[210 178 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb34);
% lambda4 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Exogenous variable tightness (&#955;<sub>4</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 150 170 16],gcf);
% create the box
c35=uicontrol('style','edit','unit','pixels','position',[210 148 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb35);
% s0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG shape on overall tightness (s<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 120 170 16],gcf);
% create the box
c36=uicontrol('style','edit','unit','pixels','position',[210 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb36);
% v0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG scale on overall tightness (v<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[30 90 170 16],gcf);
% create the box
c37=uicontrol('style','edit','unit','pixels','position',[210 88 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb37);
% alpha0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG shape on residual variance (&#945;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 270 190 16],gcf);
% create the box
c38=uicontrol('style','edit','unit','pixels','position',[535 268 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb38);
% delta0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG scale on residual variance (&#948;<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 240 190 16],gcf);
% create the box
c39=uicontrol('style','edit','unit','pixels','position',[535 238 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb39);
% gamma hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">AR coefficient on residual variance (&#947)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 210 190 16],gcf);
% create the box
c40=uicontrol('style','edit','unit','pixels','position',[535 208 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb40);
% a0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG shape on factor variance (a<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 180 190 16],gcf);
% create the box
c41=uicontrol('style','edit','unit','pixels','position',[535 178 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb41);
% b0 hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">IG scale on factor variance (b<sub>0</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 150 190 16],gcf);
% create the box
c42=uicontrol('style','edit','unit','pixels','position',[535 148 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb42);
% rho hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">AR coefficient on factors (&#961)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 120 190 16],gcf);
% create the box
c43=uicontrol('style','edit','unit','pixels','position',[535 118 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb43);
% psi hyperparameter
labelStr = '<html><font face="Times New Roman" size="3" color="black">Variance of Metropolis draw (&#968)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[335 90 190 16],gcf);
% create the box
c44=uicontrol('style','edit','unit','pixels','position',[535 88 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb44);

% Back button
c45=uicontrol('style','pushbutton','unit','pixels','position',[360 30 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb45);

% OK button
c46=uicontrol('style','pushbutton','unit','pixels','position',[445 30 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb46);

% cancel button
c47=uicontrol('style','pushbutton','unit','pixels','position',[530 30 70 25],'String',' Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb47);

%centering interface
movegui(gcf,'center')

% DEFAULT VALUES


if panel==1
set(c2,'SelectedObject',c3);
set(c13,'Enable','off');
set(c14,'Enable','off');
set(c15,'Enable','off');
set(c16,'Enable','off');
set(c22,'Enable','off');
set(c24,'Enable','off');
set(c25,'Enable','off');
set(c27,'Enable','off');
set(c31,'Enable','off');
set(c32,'Enable','off');
set(c33,'Enable','off');
set(c34,'Enable','off');
set(c35,'Enable','off');
set(c36,'Enable','off');
set(c37,'Enable','off');
set(c38,'Enable','off');
set(c39,'Enable','off');
set(c40,'Enable','off');
set(c41,'Enable','off');
set(c42,'Enable','off');
set(c43,'Enable','off');
set(c44,'Enable','off');

elseif panel==2
set(c2,'SelectedObject',c4);
set(c13,'Enable','off');
set(c14,'Enable','off');
set(c15,'Enable','off');
set(c16,'Enable','off');
set(c33,'Enable','off');
set(c36,'Enable','off');
set(c37,'Enable','off');
set(c38,'Enable','off');
set(c39,'Enable','off');
set(c40,'Enable','off');
set(c41,'Enable','off');
set(c42,'Enable','off');
set(c43,'Enable','off');
set(c44,'Enable','off');

elseif panel==3
set(c2,'SelectedObject',c5);
set(c14,'Enable','off');
set(c15,'Enable','off');
set(c16,'Enable','off');
set(c25,'Enable','off');
set(c27,'Enable','off');
set(c31,'Enable','off');
set(c33,'Enable','off');
set(c34,'Enable','off');
set(c35,'Enable','off');
set(c36,'Enable','off');
set(c37,'Enable','off');
set(c38,'Enable','off');
set(c39,'Enable','off');
set(c40,'Enable','off');
set(c41,'Enable','off');
set(c42,'Enable','off');
set(c43,'Enable','off');
set(c44,'Enable','off');

elseif panel==4
set(c2,'SelectedObject',c6);
set(c14,'Enable','off');
set(c15,'Enable','off');
set(c16,'Enable','off');
set(c31,'Enable','off');
set(c32,'Enable','off');
set(c38,'Enable','off');
set(c39,'Enable','off');
set(c40,'Enable','off');
set(c41,'Enable','off');
set(c42,'Enable','off');
set(c43,'Enable','off');
set(c44,'Enable','off');

elseif panel==5
set(c2,'SelectedObject',c7);
set(c16,'Enable','off');
set(c31,'Enable','off');
set(c32,'Enable','off');
set(c33,'Enable','off');
set(c34,'Enable','off');
set(c35,'Enable','off');
set(c36,'Enable','off');
set(c37,'Enable','off');
set(c40,'Enable','off');
set(c41,'Enable','off');
set(c42,'Enable','off');
set(c43,'Enable','off');
set(c44,'Enable','off');

elseif panel==6
set(c2,'SelectedObject',c8);
set(c31,'Enable','off');
set(c32,'Enable','off');
set(c33,'Enable','off');
set(c34,'Enable','off');
set(c35,'Enable','off');
set(c36,'Enable','off');
set(c37,'Enable','off');

end


set(c18,'String',unitnames);
set(c22,'String',It);
set(c24,'String',Bu);
set(c25,'Value',pick);
if pick==0
set(c27,'Enable','off');
elseif pick==1
set(c27,'Enable','on');
end
set(c27,'String',pickf);
set(c31,'String',ar);
set(c32,'String',lambda1);
set(c33,'String',lambda2);
set(c34,'String',lambda3);
set(c35,'String',lambda4);
set(c36,'String',s0);
set(c37,'String',v0);
set(c38,'String',alpha0);
set(c39,'String',delta0);
set(c40,'String',gama);
set(c41,'String',a0);
set(c42,'String',b0);
set(c43,'String',rho);
set(c44,'String',psi);


% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb2(hObject,callbackdata)

   if get(c2,'SelectedObject')==c3
   panel=1;
   set(c13,'Enable','off');
   set(c14,'Enable','off');
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c22,'Enable','off');
   set(c24,'Enable','off');
   pick=0;
   set(c25,'Value',pick);
   set(c25,'Enable','off');
   set(c27,'Enable','off');
   set(c31,'Enable','off');
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   set(c35,'Enable','off');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   set(c41,'Enable','off');
   set(c42,'Enable','off');
   set(c43,'Enable','off');
   set(c44,'Enable','off');

   elseif get(c2,'SelectedObject')==c4
   panel=2;
   set(c13,'Enable','off');
   set(c14,'Enable','off');
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c22,'Enable','on');
   set(c24,'Enable','on');
   pick=0;
   set(c25,'Value',pick);
   set(c25,'Enable','off');
   set(c27,'Enable','off');
   set(c31,'Enable','on');
   set(c32,'Enable','on');
   set(c33,'Enable','off');
   set(c34,'Enable','on');
   set(c35,'Enable','on');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   set(c41,'Enable','off');
   set(c42,'Enable','off');
   set(c43,'Enable','off');
   set(c44,'Enable','off');

   elseif get(c2,'SelectedObject')==c5
   panel=3;
   set(c13,'Enable','on');
   set(c14,'Enable','off');
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c22,'Enable','on');
   set(c24,'Enable','on');
   pick=0;
   set(c25,'Value',pick);
   set(c25,'Enable','off');
   set(c27,'Enable','off');
   set(c31,'Enable','off');
   set(c32,'Enable','on');
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   set(c35,'Enable','off');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   set(c41,'Enable','off');
   set(c42,'Enable','off');
   set(c43,'Enable','off');
   set(c44,'Enable','off');
   
   elseif get(c2,'SelectedObject')==c6
   panel=4;
   set(c13,'Enable','on');
   set(c14,'Enable','off');
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c22,'Enable','on');
   set(c24,'Enable','on');
   set(c25,'Enable','on');
      if pick==0
      set(c27,'Enable','off');
      elseif pick==1
      set(c27,'Enable','on');
      end
   set(c31,'Enable','off');
   set(c32,'Enable','off');
   set(c33,'Enable','on');
   set(c34,'Enable','on');
   set(c35,'Enable','on');
   set(c36,'Enable','on');
   set(c37,'Enable','on');
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   set(c41,'Enable','off');
   set(c42,'Enable','off');
   set(c43,'Enable','off');
   set(c44,'Enable','off');
   
   elseif get(c2,'SelectedObject')==c7
   panel=5;
   set(c13,'Enable','on');
   set(c14,'Enable','on');
   set(c15,'Enable','on');
   set(c16,'Enable','off');
   set(c22,'Enable','on');
   set(c24,'Enable','on');
   set(c25,'Enable','on');
      if pick==0
      set(c27,'Enable','off');
      elseif pick==1
      set(c27,'Enable','on');
      end
   set(c31,'Enable','off');
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   set(c35,'Enable','off');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   set(c38,'Enable','on');
   set(c39,'Enable','on');
   set(c40,'Enable','off');
   set(c41,'Enable','off');
   set(c42,'Enable','off');
   set(c43,'Enable','off');
   set(c44,'Enable','off');
   
   elseif get(c2,'SelectedObject')==c8
   panel=6;
   set(c13,'Enable','on');
   set(c14,'Enable','on');
   set(c15,'Enable','on');
   set(c16,'Enable','on');
   set(c22,'Enable','on');
   set(c24,'Enable','on');
   set(c25,'Enable','on');
      if pick==0
      set(c27,'Enable','off');
      elseif pick==1
      set(c27,'Enable','on');
      end
   set(c31,'Enable','off');
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   set(c35,'Enable','off');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   set(c38,'Enable','on');
   set(c39,'Enable','on');
   set(c40,'Enable','on');
   set(c41,'Enable','on');
   set(c42,'Enable','on');
   set(c43,'Enable','on');
   set(c44,'Enable','on');
   end
   
end


function cb18(hObject,callbackdata)
unitnames=get(c18,'String');
end


function cb22(hObject,callbackdata)
It=str2num(get(c22,'String'));
end


function cb24(hObject,callbackdata)
Bu=str2num(get(c24,'String'));
end


function cb25(hObject,callbackdata)
pick=get(c25,'Value');
   if pick==0
   set(c27,'Enable','off');
   elseif pick==1
   set(c27,'Enable','on');
   end
end


function cb27(hObject,callbackdata)
pickf=str2num(get(c27,'String'));
end


function cb31(hObject,callbackdata)
ar=str2num(get(c31,'String'));
end


function cb32(hObject,callbackdata)
lambda1=str2num(get(c32,'String'));
end


function cb33(hObject,callbackdata)
lambda2=str2num(get(c33,'String'));
end


function cb34(hObject,callbackdata)
lambda3=str2num(get(c34,'String'));
end


function cb35(hObject,callbackdata)
lambda4=str2num(get(c35,'String'));
end


function cb36(hObject,callbackdata)
s0=str2num(get(c36,'String'));
end


function cb37(hObject,callbackdata)
v0=str2num(get(c37,'String'));
end


function cb38(hObject,callbackdata)
alpha0=str2num(get(c38,'String'));
end


function cb39(hObject,callbackdata)
delta0=str2num(get(c39,'String'));
end


function cb40(hObject,callbackdata)
gama=str2num(get(c40,'String'));
end


function cb41(hObject,callbackdata)
a0=str2num(get(c41,'String'));
end


function cb42(hObject,callbackdata)
b0=str2num(get(c42,'String'));
end


function cb43(hObject,callbackdata)
rho=str2num(get(c43,'String'));
end


function cb44(hObject,callbackdata)
psi=str2num(get(c44,'String'));
end


function cb45(hObject,callbackdata)
validation=1;
close(fig)
end


function cb46(hObject,callbackdata)
% preliminary elements to be able to use Tex interpreter in error messages
messge.Interpreter='tex';
messge.WindowStyle='modal';
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(unitnames)
   msgbox('Units are missing. Please indicate at least one unit name.');
   elseif isempty(It)
   msgbox('Total number of iterations is missing. Please indicate a value.');
   elseif isempty(Bu)
   msgbox('Number of burn-in iterations is missing. Please indicate a value.');
   elseif isempty(pickf)
   msgbox('Number of iterations between two retained draws is missing. Please indicate a value.');
   elseif isempty(ar)
   msgbox('Auto-regressive coefficient missing. Please indicate a value.');
   elseif isempty(lambda1)
   msgbox('Overall tightness coefficient (\lambda_1) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda2)
   msgbox('Cross-variable weighting coefficient (\lambda_2) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda3)
   msgbox('Lag decay coefficient (\lambda_3) is missing. Please indicate a value.','Value',messge);
   elseif isempty(lambda4)
   msgbox('Exogenous variable tightness coefficient (\lambda_4) is missing. Please indicate a value.','Value',messge);
   elseif isempty(s0)
   msgbox('Inverse Gamma shape parameter on overall tightness (\s_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(v0)
   msgbox('Inverse Gamma scale parameter on overall tightness (\v_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(alpha0)
   msgbox('Inverse Gamma shape parameter on residual variance (\alpha_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(delta0)
   msgbox('Inverse Gamma scale parameter on residual variance (\delta_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(gama)
   msgbox('Autoregressive coefficient on residual variance (\gamma) is missing. Please indicate a value.','Value',messge);
   elseif isempty(a0)
   msgbox('Inverse Gamma shape parameter on factor variance (\a_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(b0)
   msgbox('Inverse Gamma scale parameter on factor variance (\b_0) is missing. Please indicate a value.','Value',messge);
   elseif isempty(rho)
   msgbox('Autoregressive coefficient on factor variance (\rho) is missing. Please indicate a value.','Value',messge);
   elseif isempty(psi)
   msgbox('Variance of the Metropolis-Hastings draw (\psi) is missing. Please indicate a value.','Value',messge);
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=2;
   close(fig)
   end
end

function cb47(hObject,callbackdata)
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

% first fix the strings that may require it
unitnames=fixstring(unitnames);
% then recover the names of the different units; to do so, separate the string 'unitnames' into individual names
% look for the spaces and identify their locations
findspace=isspace(unitnames);
locspace=find(findspace);
% use this to set the delimiters: each unit string is located between two delimiters
delimiters=[0 locspace numel(unitnames)+1];
% count the number of units
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two unit names, so there is one unit more than the number of spaces
numunits=nspace+1;
% now finally identify the units
Units=cell(numunits,1);
for ii=1:numunits
Units{ii,1}=unitnames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end 

   % then if user's preferences have been selected
   if pref.pref==1

   save('userpref4.mat','panel','Units','unitnames', 'It','Bu','pick','pickf','ar','lambda1','lambda2','lambda3','lambda4','s0','v0','alpha0','delta0','gama','rho','a0','b0','psi')
   
   % if the user did not want to save preferences, do not do save anything
   else
   end


else
Units=[];

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






