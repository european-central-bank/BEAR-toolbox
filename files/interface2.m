function [prior,AR_default,lambda1,lambda2,lambda3,lambda4,lambda5,lambda6,lambda7,lambda8,It,Bu,hogs,bex,scoeff,iobs,lrp,PriorExcel,priorsexogenous,interface,interinfo2]=interface2(pref,interinfo2)





% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;

% set default values
% if user preferences exist, load them, and attribute them
if exist('userpref2.mat','file')==2
load('userpref2.mat')
% if no user preferences have been saved, run the interface with the system preferences
else
prior=11;
AR_default=0.8;
lambda1=0.1;
lambda2=0.5;
lambda3=1;
lambda4=100;
lambda5=0.001;
lambda6=1;
lambda7=0.0001;
lambda8=1;
It=2000;
Bu=1000;
hogs=0;
bex=0;
scoeff=0;
iobs=0;
lrp=0;
PriorExcel=0;
priorsexogenous=0;
end

if isempty(interinfo2)
else
prior=interinfo2{1,1};
AR_default=interinfo2{2,1};
lambda1=interinfo2{3,1};
lambda2=interinfo2{4,1};
lambda3=interinfo2{5,1};
lambda4=interinfo2{6,1};
lambda5=interinfo2{7,1};
lambda6=interinfo2{8,1};
lambda7=interinfo2{9,1};
lambda8=interinfo2{16,1};
It=interinfo2{10,1};
Bu=interinfo2{11,1};
hogs=interinfo2{12,1};
bex=interinfo2{13,1};
scoeff=interinfo2{14,1};
iobs=interinfo2{15,1};    
lrp=interinfo2{17,1};
PriorExcel=interinfo2{18,1};
priorsexogenous=interinfo2{19,1};
end



% PHASE OF FIGURE CREATION


% initiate figure
fig=figure('units','pixels','position',[500 340 700 600],'name', 'Bayesian VAR: prior specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');

% prior distribution
% create the box title
c1=uicontrol('style','text','unit','pixels','position',[13 554 150 16],'String','Prior distribution','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c2=uibuttongroup('unit','pixels','Position',[13 419 660 132],'SelectionChangeFcn',@cb2);
%create each radiobutton in the group
c3=uicontrol(c2,'Style','radiobutton','String','Minnesota','Position',[7 95 250 18],'FontName','Times New Roman','FontSize',10);
%c4=uicontrol(c2,'Style','radiobutton','String','Minnesota (diagonal VAR estimates)','Position',[7 82 250 18],'FontName','Times New Roman','FontSize',10);
%c5=uicontrol(c2,'Style','radiobutton','String','Minnesota (full VAR estimates)','Position',[7 57 250 18],'FontName','Times New Roman','FontSize',10);
c6=uicontrol(c2,'Style','radiobutton','String','Normal-diffuse','Position',[7 60 250 18],'FontName','Times New Roman','FontSize',10);
c7=uicontrol(c2,'Style','radiobutton','String','<html> Dummy observations </html>','Position',[7 25 250 18],'FontName','Times New Roman','FontSize',10);
c8=uicontrol(c2,'Style','radiobutton','String','<html> Normal-Wishart </html>','Position',[280 95 285 18],'FontName','Times New Roman','FontSize',10);
%c9=uicontrol(c2,'Style','radiobutton','String','<html> Normal-Wishart (S<sub>0</sub> as identity) </html>','Position',[280 82 285 18],'FontName','Times New Roman','FontSize',10);
%c10=uicontrol(c2,'Style','radiobutton','String','<html> Independent Normal-Wishart (S<sub>0</sub> as univariate AR) </html>','Position',[280 82 285 18],'FontName','Times New Roman','FontSize',10);
c10=uicontrol(c2,'Style','radiobutton','String','<html> Independent Normal-Wishart </html>','Position',[280 60 285 18],'FontName','Times New Roman','FontSize',10);
%c11=uicontrol(c2,'Style','radiobutton','String','<html> Independent Normal-Wishart (S<sub>0</sub> as identity) </html>','Position',[280 32 420 18],'FontName','Times New Roman','FontSize',10);


% title for the hyperparameter box
c12=uicontrol('style','text','unit','pixels','position',[13 374 150 16],'String','Hyperparameters','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c13=uicontrol('style','frame','unit','pixels','position',[13 67 300 300],'ForegroundColor',[0.6 0.6 0.6]);

% AR coefficient
% create the box title
c14=uicontrol('style','text','unit','pixels','position',[20 333 150 16],'String','Autoregressive coefficient','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
labelStr = '<html><font face="Times New Roman" size="3" color="black">Autoregressive coefficient </html>';
c144=uicontrol('style','checkbox','unit','pixels','position',[170 333 100 16],'String','Excel','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb144);
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 333 150 16],gcf);
c15=uicontrol('style','edit','unit','pixels','position',[240 331 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb15);
% default values for AR coefficient
% set choice for having individual AR coefficients
set(c144,'Value',PriorExcel);
if PriorExcel==0
    set(c15,'Enable','on');
else
    set(c15,'Enable','off');
end
set(c15,'String',AR_default);


% lambda1
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Overall tightness (&#955;<sub>1</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 301 150 16],gcf);
% create the box
c16=uicontrol('style','edit','unit','pixels','position',[240 299 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb16);
% default values for lambda1
set(c16,'String',lambda1);

% lambda2
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Cross-variable weighting (&#955;<sub>2</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 269 170 16],gcf);
c17=uicontrol('style','edit','unit','pixels','position',[240 267 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb17);
% default values for lambda2
set(c17,'String',lambda2);

% lambda3
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Lag decay (&#955;<sub>3</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 237 170 16],gcf);
c18=uicontrol('style','edit','unit','pixels','position',[240 235 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb18);
% default values for lambda3
set(c18,'String',lambda3);

% lambda4
% create the box title
c199=uicontrol('style','text','unit','pixels','position',[20 205 170 16],'String','Exogenous variables','HorizontalAlignment','left','FontName','Times New Roman','FontSize',8);
% create a group of radio buttons
c200=uibuttongroup('unit','pixels','Position',[190 203 110 20],'Bordertype','none','SelectionChangeFcn',@cb200);
% create each radiobutton in the group
c201=uicontrol(c200,'Style','radiobutton','String','Excel','Position',[1 6 50 18],'FontName','Times New Roman','FontSize',8);
c202=uicontrol(c200,'Style','radiobutton','String','Default','Position',[62 6 60 18],'FontName','Times New Roman','FontSize',8);
% default value for choice of priors on exogeneous
if priorsexogenous==0
   set(c200,'SelectedObject',c202);
   lambda4=100;
elseif priorsexogenous==1
   set(c200,'SelectedObject',c201);
   lambda4=0.1;
end

% lambda5
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Block exogeneity shrinkage (&#955;<sub>5</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 173 170 16],gcf);
c20=uicontrol('style','edit','unit','pixels','position',[240 171 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb20);
% default values for lambda5
set(c20,'String',lambda5);

% lambda6
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Sum-of-coefficients tightness (&#955;<sub>6</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 141 200 16],gcf);
c21=uicontrol('style','edit','unit','pixels','position',[240 139 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb21);
% default values for lambda6
set(c21,'String',lambda6);

% lambda7
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Dummy initial observation tightness (&#955;<sub>7</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 109 200 16],gcf);
c22=uicontrol('style','edit','unit','pixels','position',[240 107 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb22);
% default values for lambda7
set(c22,'String',lambda7);

% lambda8
% create the box title
labelStr = '<html><font face="Times New Roman" size="3" color="black">Long run prior tightness (&#955;<sub>8</sub>)</font></html>';
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[hcomponent,hcontainer] = javacomponent(jLabel,[20 75 200 16],gcf);
clrp=uicontrol('style','edit','unit','pixels','position',[240 73 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cblrp);
% default values for lambda8
set(clrp,'String',lambda8);

% title for the estimation setting box
% create a general title for the estimation choices
c23=uicontrol('style','text','unit','pixels','position',[360 374 150 16],'String','Options','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c24=uicontrol('style','frame','unit','pixels','position',[353 67 320 301],'ForegroundColor',[0.6 0.6 0.6]);

% total iteration number
% create the box title
c25=uicontrol('style','text','unit','pixels','position',[360 333 190 16],'String','Total number of iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c26=uicontrol('style','edit','unit','pixels','position',[580 331 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb26);
% default number of iterations
set(c26,'String',It);

% burn-in iterations
% create the box title
c27=uicontrol('style','text','unit','pixels','position',[360 301 190 16],'String','Number of burn-in iterations','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c28=uicontrol('style','edit','unit','pixels','position',[580 299 50 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb28);
% default burn-in
set(c28,'String',Bu);

% grid search
% create the box title
c29=uicontrol('style','text','unit','pixels','position',[360 269 165 16],'String','Hyperparameter optimisation','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box title (line 2)
c30=uicontrol('style','text','unit','pixels','position',[360 237 190 16],'String','by grid search (on Excel)','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c31=uibuttongroup('unit','pixels','Position',[538 229 102 28],'Bordertype','none','SelectionChangeFcn',@cb31);
% create each radiobutton in the group
c32=uicontrol(c31,'Style','radiobutton','String','Yes','Position',[12 6 50 18],'FontName','Times New Roman','FontSize',10);
c33=uicontrol(c31,'Style','radiobutton','String','No','Position',[61 6 60 18],'FontName','Times New Roman','FontSize',10);
% default value for choice of gid search
   if hogs==0
   set(c31,'SelectedObject',c33);
   elseif hogs==1
   set(c31,'SelectedObject',c32);
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c17,'Enable','off');
   set(c18,'Enable','off');
   set(c19,'Enable','off');
   set(c21,'Enable','off');
   set(c22,'Enable','off');
   set(clrp,'Enable','off');
   end

% block exogeneity
% create the box title
c34=uicontrol('style','text','unit','pixels','position',[360 205 190 16],'String','Block exogeneity (on Excel)','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c35=uibuttongroup('unit','pixels','Position',[538 197 122 28],'Bordertype','none','SelectionChangeFcn',@cb35);
%create each radiobutton in the group
c36=uicontrol(c35,'Style','radiobutton','String','Yes','Position',[12 6 50 18],'FontName','Times New Roman','FontSize',10);
c37=uicontrol(c35,'Style','radiobutton','String','No','Position',[61 6 60 18],'FontName','Times New Roman','FontSize',10);
% default value for choice of block exogeneity
   if bex==0
   set(c35,'SelectedObject',c37);
   set(c20,'Enable','off');
   elseif bex==1
   set(c35,'SelectedObject',c36);
   end

% dummy extensions
% create the box title
c38=uicontrol('style','text','unit','pixels','position',[360 173 200 16],'String','Dummy observation extensions','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the check boxes
c39=uicontrol('style','checkbox','unit','pixels','position',[360 141 250 16],'String',' Sum-of-coefficients','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb39);
c40=uicontrol('style','checkbox','unit','pixels','position',[360 109 250 16],'String',' Dummy initial observation','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb40);
clrp2=uicontrol('style','checkbox','unit','pixels','position',[360 80 250 18],'String',' Long run priors','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cblrp2);

% default values
set(c39,'Value',scoeff);
set(c40,'Value',iobs);
set(clrp2,'Value',lrp);
if scoeff==0
set(c21,'Enable','off');
end
if iobs==0
set(c22,'Enable','off');
end
if lrp==0
   set(clrp,'Enable','off');
   set(c3,'Enable','on');
   %set(c4,'Enable','on');
   %set(c5,'Enable','on');
   set(c6,'Enable','on');
   set(c7,'Enable','on');
   set(c10,'Enable','on');
   %set(c11,'Enable','on');
   elseif lrp==1
   set(clrp,'Enable','on');
   set(c2,'SelectedObject',c8); % normal wishart
   set(c3,'Enable','off');
   %set(c4,'Enable','off');
   %set(c5,'Enable','off');
   set(c6,'Enable','off');
   set(c7,'Enable','off');
   set(c10,'Enable','off');
   %set(c11,'Enable','off');
end

movegui(gcf,'center')

% default value for prior distribution (has to be done now, and not sooner, since it involves controls created after the prior controls)
   if prior==11
   set(c2,'SelectedObject',c3);
   %elseif prior==12
   %set(c2,'SelectedObject',c4);
   %elseif prior==13
   %set(c2,'SelectedObject',c5);
   elseif prior==21
   set(c2,'SelectedObject',c8);
   set(c17,'Enable','off');
   set(c20,'Enable','off');
   set(c35,'SelectedObject',c37);
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   elseif prior==22
   %set(c2,'SelectedObject',c9);
   %set(c17,'Enable','off');
   %set(c20,'Enable','off');
   %set(c35,'SelectedObject',c37);
   %set(c36,'Enable','off');
   %set(c37,'Enable','off');
   elseif prior==31
   set(c2,'SelectedObject',c10);
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   %elseif prior==32
   %set(c2,'SelectedObject',c11);
   %set(c32,'Enable','off');
   %set(c33,'Enable','off');
   elseif prior==41
   set(c2,'SelectedObject',c6);
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   elseif prior==51
   set(c2,'SelectedObject',c7);
   set(c17,'Enable','off');
   set(c20,'Enable','off');
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   end

% Back button
c41=uicontrol('style','pushbutton','unit','pixels','position',[413 30 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb41);

% OK button
c42=uicontrol('style','pushbutton','unit','pixels','position',[498 30 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb42);

% cancel button
c43=uicontrol('style','pushbutton','unit','pixels','position',[583 30 70 25],'String','Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb43);







% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb2(hObject,callbackdata)
   if get(c2,'SelectedObject')==c3
   prior=11;
      if hogs==0
      set(c17,'Enable','on');
      end
   set(c32,'Enable','on');
   set(c33,'Enable','on');
   set(c36,'Enable','on');
   set(c37,'Enable','on');
   %elseif get(c2,'SelectedObject')==c4
   %prior=12;
   %    if hogs==0
   %    set(c17,'Enable','on');
   %    end
   % set(c32,'Enable','on');
   % set(c33,'Enable','on');
   %set(c36,'Enable','on');
   %set(c37,'Enable','on');
   %elseif get(c2,'SelectedObject')==c5
   %prior=13;
   %  if hogs==0
   %  set(c17,'Enable','on');
   %  end
   %set(c32,'Enable','on');
   %set(c33,'Enable','on');
   %set(c36,'Enable','on');
   %set(c37,'Enable','on');
   elseif get(c2,'SelectedObject')==c6
   prior=41;
     if PriorExcel==0
        set(c15,'Enable','on');
     elseif PriorExcel==1
        set(c15,'Enable','off');
    end
   set(c16,'Enable','on');
   set(c17,'Enable','on');
   set(c18,'Enable','on');
   hogs=0;
   set(c31,'SelectedObject',c33);
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c36,'Enable','on');
   set(c37,'Enable','on');
   elseif get(c2,'SelectedObject')==c7
   prior=51;
    if PriorExcel==0
    set(c15,'Enable','on');
    elseif PriorExcel==1
    set(c15,'Enable','off');
    end
   set(c16,'Enable','on');
   set(c17,'Enable','off');
   set(c18,'Enable','on');
   %set(c19,'Enable','on');
   set(c20,'Enable','off');
   hogs=0;
   set(c31,'SelectedObject',c33);
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   bex=0;
   set(c35,'SelectedObject',c37); 
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   elseif get(c2,'SelectedObject')==c8
   prior=21;
    if PriorExcel==0
    set(c15,'Enable','on');
    elseif PriorExcel==1
    set(c15,'Enable','off');
    end
   set(c17,'Enable','off');
   set(c20,'Enable','off');
   set(c32,'Enable','on');
   set(c33,'Enable','on');
   bex=0;
   set(c35,'SelectedObject',c37);
   set(c36,'Enable','off');
   set(c37,'Enable','off');
   %elseif get(c2,'SelectedObject')==c9
   %prior=22;
   %set(c17,'Enable','off');
   %set(c20,'Enable','off');
   %set(c32,'Enable','on');
   %set(c33,'Enable','on');
   %bex=0;
   %set(c35,'SelectedObject',c37);
   %set(c36,'Enable','off');
   %set(c37,'Enable','off');
   elseif get(c2,'SelectedObject')==c10
   prior=31;
    if PriorExcel==0
    set(c15,'Enable','on');
    elseif PriorExcel==1
    set(c15,'Enable','off');
    end
   set(c16,'Enable','on');
   set(c17,'Enable','on');
   set(c18,'Enable','on');
   %set(c200,'Enable','on');
   hogs=0;
    if PriorExcel==0
    set(c15,'Enable','on');
    elseif PriorExcel==1
    set(c15,'Enable','off');
    end
   set(c31,'SelectedObject',c33);
   set(c32,'Enable','off');
   set(c33,'Enable','off');
   set(c36,'Enable','on');
   set(c37,'Enable','on');
   %elseif get(c2,'SelectedObject')==c11
   %prior=32;
   %if PriorExcel==0
   %set(c15,'Enable','on');
   %elseif PriorExcel==1
   %set(c15,'Enable','off');
 %  end
  % set(c16,'Enable','on');
  % set(c17,'Enable','on');
  % set(c18,'Enable','on');
  % %set(c19,'Enable','on');
 %  hogs=0;
 %  set(c31,'SelectedObject',c33);
 %  set(c32,'Enable','off');
 %  set(c33,'Enable','off');
 %  set(c36,'Enable','on');
 %  set(c37,'Enable','on');
 end
end

function cb15(hObject,callbackdata)
AR_default=str2num(get(c15,'String'));
end

function cb144(hObject,callbackdata)
   PriorExcel=get(c144,'Value');
   if PriorExcel==0
   set(c15,'Enable','on');
   elseif PriorExcel==1
   set(c15,'Enable','off');
   end
end

function cb16(hObject,callbackdata)
lambda1=str2num(get(c16,'String'));
end

function cb17(hObject,callbackdata)
lambda2=str2num(get(c17,'String'));
end

function cb18(hObject,callbackdata)
lambda3=str2num(get(c18,'String'));
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

%function cb19(hObject,callbackdata)
%lambda4=str2num(get(c19,'String'));
%end

function cb20(hObject,callbackdata)
lambda5=str2num(get(c20,'String'));
end

function cb21(hObject,callbackdata)
lambda6=str2num(get(c21,'String'));
end

function cb22(hObject,callbackdata)
lambda7=str2num(get(c22,'String'));
end

function cblrp(hObject,callbackdata)
lambda8=str2num(get(clrp,'String'));
end

function cb26(hObject,callbackdata)
It=str2num(get(c26,'String'));
end

function cb28(hObject,callbackdata)
Bu=str2num(get(c28,'String'));
end

function cb31(hObject,callbackdata)
   if get(c31,'SelectedObject')==c32
   hogs=1;
   set(c15,'Enable','off');
   set(c16,'Enable','off');
   set(c17,'Enable','off');
   set(c18,'Enable','off');
   %set(c19,'Enable','off');
   set(c21,'Enable','off');
   set(c22,'Enable','off');
   set(clrp,'Enable','off');
   elseif get(c31,'SelectedObject')==c33
   hogs=0;
   set(c15,'Enable','on');
   set(c16,'Enable','on');
      % reactivate lambda2 only if the prior is not the normal-Wishart
      %if prior==21||prior==22
      if prior==21
      else
      set(c17,'Enable','on');
      end
   set(c18,'Enable','on');
   %set(c19,'Enable','on');
      % reactivate lambda6 only if the sum of coefficient application is selected
      if scoeff==1
      set(c21,'Enable','on');
      end
      % reactivate lambda7 only if the dummy initial observation application is selected
      if iobs==1
      set(c22,'Enable','on');
      end
      % reactivate lambda8 only if the long run prior application is selected
      if lrp==1
      set(clrp,'Enable','on');
      end
   end
end

function cb35(hObject,callbackdata)
   if get(c35,'SelectedObject')==c36
   bex=1;
   set(c20,'Enable','on');
   elseif get(c35,'SelectedObject')==c37
   bex=0;
   set(c20,'Enable','off');
   end
end

function cb39(hObject,callbackdata)
scoeff=get(c39,'Value');
   if scoeff==0
   set(c21,'Enable','off');
   elseif scoeff==1 && hogs==1
   set(c21,'Enable','off');
   elseif scoeff==1 && hogs==0
   set(c21,'Enable','on');
   end
end

function cb40(hObject,callbackdata)
iobs=get(c40,'Value');
   if iobs==0
   set(c22,'Enable','off');
   elseif iobs==1 && hogs==1
   set(c22,'Enable','off');
   elseif iobs==1 && hogs==0
   set(c22,'Enable','on');
   end
end

function cblrp2(hObject,callbackdata)
lrp=get(clrp2,'Value');
   if lrp==0
   set(clrp,'Enable','off');
   set(c3,'Enable','on');
   %set(c4,'Enable','on');
   %set(c5,'Enable','on');
   set(c6,'Enable','on');
   set(c7,'Enable','on');
   set(c10,'Enable','on');
   %set(c11,'Enable','on');
   elseif lrp==1
   set(clrp,'Enable','on');
   set(c2,'SelectedObject',c8); % normal wishart
   set(c3,'Enable','off');
   %set(c4,'Enable','off');
   %set(c5,'Enable','off');
   set(c6,'Enable','off');
   set(c7,'Enable','off');
   set(c10,'Enable','off');
   %set(c11,'Enable','off');
   end
end

function cb41(hObject,callbackdata)
validation=1;
close(fig)
end

function cb42(hObject,callbackdata)
% preliminary elements to be able to use Tex interpreter in error messages
messge.Interpreter='tex';
messge.WindowStyle='modal';
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(AR_default)
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
   msgbox('Block exogeneity shrinkage coefficient (\lambda_5) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda6)
   msgbox('Sum of coefficient tightness coefficient (\lambda_6) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda7)
   msgbox('Dummy initial observation tightness coefficient (\lambda_7) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(lambda8)
   msgbox('Long run prior tightness coefficient (\lambda_8) is missing. Please indicate a prior value.','Value',messge);
   elseif isempty(It)
   msgbox('Total number of iterations is missing. Please indicate a value.');
   elseif isempty(Bu)
   msgbox('Number of burn-in iterations is missing. Please indicate a value.');
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=2;
   close(fig)
   end
end

function cb43(hObject,callbackdata)
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

   save('userpref2.mat','prior','AR_default','lambda1','lambda2','lambda3','lambda4','lambda5','lambda6','lambda7','lambda8','It','Bu','hogs','bex','scoeff','iobs','lrp','PriorExcel','priorsexogenous');
       
   % if the user did not want to save pereferences, do not do save anything
   else
   end

end



% indicate which interface is to be opened next, depending on the user's choice
% if back button was pushed, go back to interface 1
if validation==1
interface='interface1';
% if OK button was pushed, go to interface 5
elseif validation==2
interface='interface6';
end






% finally, declare end of the full nested function
end













