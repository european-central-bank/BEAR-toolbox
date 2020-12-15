function [IRF,F,FEVD,HD,CF,IRFt,Feval,CFt,IRFperiods,Fstartdate,Fenddate,Fendsmpl,cband,IRFband,Fband,FEVDband,HDband,window_size,evaluation_size,hstep, pref, interface,interinfo6]=interface6(pref,enddate,frequency,VARtype,panel,interinfo6)











% default cancellation value this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=3;

% set default values
% if user preferences exist, load them, and attribute them
% if exist('userpref6.m','file')==2
% run userpref6
if exist('userpref6.mat','file')==2
load('userpref6.mat')
% if no user preferences have been saved, run the interface with the system preferences
else
IRF=1;
F=1;
FEVD=0;
HD=0;
CF=0;
IRFt=1;
Feval=1;
CFt=1;
IRFperiods=20;
Fstartdate='';
Fenddate='';
Fendsmpl=1;
cband=0.95;
IRFband=0.95;
Fband=0.95;
FEVDband=0.95;
HDband=0.95;
window_size=0;
evaluation_size=0.5;
hstep=1;
end



% now update information with the cell interinfo4
% this is required to display correct information when using the Back button
if isempty(interinfo6)
else   
IRF=interinfo6{1,1};
F=interinfo6{2,1};
FEVD=interinfo6{3,1};
HD=interinfo6{4,1};
CF=interinfo6{5,1};
IRFt=interinfo6{6,1};
Feval=interinfo6{7,1};
CFt=interinfo6{8,1};
IRFperiods=interinfo6{9,1};
Fstartdate=interinfo6{10,1};
Fenddate=interinfo6{11,1};
Fendsmpl=interinfo6{12,1};
cband=interinfo6{13,1};
IRFband=interinfo6{14,1};
Fband=interinfo6{15,1};
FEVDband=interinfo6{16,1};
HDband=interinfo6{17,1};   
window_size=interinfo6{18,1}; 
evaluation_size=interinfo6{19,1}; 
hstep=interinfo6{20,1}; 
end




% PHASE OF FIGURE CREATION

% initiate figure
fig=figure('units','pixels','position',[500 380 740 600],'name', 'Model options','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');

% box: application options
c1=uicontrol('style','text','unit','pixels','position',[13 570 150 16],'String','Application options:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c2=uicontrol('style','frame','unit','pixels','position',[13 390 352 176],'ForegroundColor',[0.6 0.6 0.6]);

% IRFs
% create the box title
c3=uicontrol('style','text','unit','pixels','position',[20 540 220 16],'String','Impulse response functions:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c4=uibuttongroup('unit','pixels','Position',[260 535 104 30],'Bordertype','none','SelectionChangeFcn',@cb4);
% create each radiobutton in the group
c5=uicontrol(c4,'Style','radiobutton','String','Yes','Position',[7 5 50 16],'FontName','Times New Roman','FontSize',10);
c6=uicontrol(c4,'Style','radiobutton','String','No','Position',[57 5 35 16],'FontName','Times New Roman','FontSize',10);

% forecasts
% create the box title
c7=uicontrol('style','text','unit','pixels','position',[20 505 220 16],'String','Unconditional forecasts:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c8=uibuttongroup('unit','pixels','Position',[260 500 104 30],'Bordertype','none','SelectionChangeFcn',@cb8);
% create each radiobutton in the group
c9=uicontrol(c8,'Style','radiobutton','String','Yes','Position',[7 5 50 18],'FontName','Times New Roman','FontSize',10);
c10=uicontrol(c8,'Style','radiobutton','String','No','Position',[57 5 35 18],'FontName','Times New Roman','FontSize',10);

% forecast error variance decomposition
% create the box title
c11=uicontrol('style','text','unit','pixels','position',[20 470 220 16],'String','Forecasts error variance decomposition:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c12=uibuttongroup('unit','pixels','Position',[260 465 104 30],'Bordertype','none','SelectionChangeFcn',@cb12);
% create each radiobutton in the group
c13=uicontrol(c12,'Style','radiobutton','String','Yes','Position',[7 5 50 18],'FontName','Times New Roman','FontSize',10);
c14=uicontrol(c12,'Style','radiobutton','String','No','Position',[57 5 35 18],'FontName','Times New Roman','FontSize',10);
% default value for FEVD

% historical decomposition
% create the box title
c15=uicontrol('style','text','unit','pixels','position',[20 435 220 16],'String','Historical decomposition:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c16=uibuttongroup('unit','pixels','Position',[260 430 104 30],'Bordertype','none','SelectionChangeFcn',@cb16);
% create each radiobutton in the group
c17=uicontrol(c16,'Style','radiobutton','String','Yes','Position',[7 5 50 18],'FontName','Times New Roman','FontSize',10);
c18=uicontrol(c16,'Style','radiobutton','String','No','Position',[57 5 35 18],'FontName','Times New Roman','FontSize',10);
% default value for historical decomposition

% conditional forecasts
% create the box title
c19=uicontrol('style','text','unit','pixels','position',[20 400 220 16],'String','Conditional forecasts:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c20=uibuttongroup('unit','pixels','Position',[260 395 104 30],'Bordertype','none','SelectionChangeFcn',@cb20);
% create each radiobutton in the group
c21=uicontrol(c20,'Style','radiobutton','String','Yes','Position',[7 5 50 18],'FontName','Times New Roman','FontSize',10);
c22=uicontrol(c20,'Style','radiobutton','String','No','Position',[57 5 35 18],'FontName','Times New Roman','FontSize',10);
% default value for forecasts

% box: estimation options
c23=uicontrol('style','text','unit','pixels','position',[13 360 150 16],'String','Estimation options:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c24=uicontrol('style','frame','unit','pixels','position',[13 15 352 340],'ForegroundColor',[0.6 0.6 0.6]);

% structural identification
c25=uicontrol('style','text','unit','pixels','position',[20 330 150 16],'String','Structural identification:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c26=uibuttongroup('unit','pixels','Position',[20 255 330 70],'Bordertype','none','SelectionChangeFcn',@cb26);
% create each radiobutton in the group
c27=uicontrol(c26,'Style','radiobutton','String','None','Position',[0 50 100 18],'FontName','Times New Roman','FontSize',10);
c28=uicontrol(c26,'Style','radiobutton','String','Choleski factorisation','Position',[160 50 150 18],'FontName','Times New Roman','FontSize',10);
c29=uicontrol(c26,'Style','radiobutton','String','Triangular factorisation','Position',[0 25 150 18],'FontName','Times New Roman','FontSize',10);
c30=uicontrol(c26,'Style','radiobutton','String','Sign restrictions','Position',[160 25 150 18],'FontName','Times New Roman','FontSize',10);
if VARtype==1
    c301=uicontrol(c26,'Style','radiobutton','String','Proxy SVAR','Position',[0 0 150 18],'FontName','Times New Roman','FontSize',10);
    c302=uicontrol(c26,'Style','radiobutton','String','Proxy SVAR + Sign restrictions','Position',[160 0 150 18],'FontName','Times New Roman','FontSize',10);
end
% forecast evaluation
c31=uicontrol('style','text','unit','pixels','position',[20 220 150 16],'String','Forecast evaluation:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
%c32=uibuttongroup('unit','pixels','Position',[260 220 104 30],'Bordertype','none','SelectionChangeFcn',@cb32);
c32=uibuttongroup('unit','pixels','Position',[260 220 104 30],'Bordertype','none','SelectionChangeFcn',@cb32);
% create each radiobutton in the group
c33=uicontrol(c32,'Style','radiobutton','String','Yes','Position',[7 5 50 18],'FontName','Times New Roman','FontSize',10);
c34=uicontrol(c32,'Style','radiobutton','String','No','Position',[57 5 35 18],'FontName','Times New Roman','FontSize',10);

% forecast step ahead evaluation
c69=uicontrol('style','text','unit','pixels','position',[20 190 300 20],'String','Forecast step ahead evaluation:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c70=uicontrol('style','edit','unit','pixels','position',[280 190 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb70);

% forecast iteration window_size
c67=uicontrol('style','text','unit','pixels','position',[20 160 300 20],'String','Rolling window (0 for full sample):','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c68=uicontrol('style','edit','unit','pixels','position',[280 160 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb68);

% forecast iteration Evaluation size
c71=uicontrol('style','text','unit','pixels','position',[20 130 300 20],'String','Evaluation size (percent of Forecast window):','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c72=uicontrol('style','edit','unit','pixels','position',[280 130 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb72);


% type of conditional forecasts
c35=uicontrol('style','text','unit','pixels','position',[20 100 250 20],'String','Type of conditional forecasts:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c36=uibuttongroup('unit','pixels','Position',[20 30 330 60],'Bordertype','none','SelectionChangeFcn',@cb36);
% create each radiobutton in the group
c37=uicontrol(c36,'Style','radiobutton','String','Standard (all shocks)','Position',[0 40 150 18],'FontName','Times New Roman','FontSize',10);
c38=uicontrol(c36,'Style','radiobutton','String','Standard (shock-specific)','Position',[160 40 165 18],'FontName','Times New Roman','FontSize',10);
c39=uicontrol(c36,'Style','radiobutton','String','Tilting (median)','Position',[0 0 150 18],'FontName','Times New Roman','FontSize',10);
c40=uicontrol(c36,'Style','radiobutton','String','Tilting (interval)','Position',[160 0 165 18],'FontName','Times New Roman','FontSize',10);

% box: period options
% box title
c41=uicontrol('style','text','unit','pixels','position',[423 570 150 16],'String','Period options:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c42=uicontrol('style','frame','unit','pixels','position',[423 390 304 176],'ForegroundColor',[0.6 0.6 0.6]);

% IRF periods
% create the box title
c43=uicontrol('style','text','unit','pixels','position',[430 540 220 16],'String','IRF periods:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c44=uicontrol('style','edit','unit','pixels','position',[650 538 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb44);

% forecast, initial period
% create the box title
c45=uicontrol('style','text','unit','pixels','position',[430 505 220 16],'String','Forecasts: start date (in-sample)','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c46=uicontrol('style','edit','unit','pixels','position',[650 503 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb46);

% forecast, end period
% create the box title
c47=uicontrol('style','text','unit','pixels','position',[430 470 220 16],'String','Forecasts: end date','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c48=uicontrol('style','edit','unit','pixels','position',[650 468 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb48);

% start forecast at end of the sample: yes/no
% create the box title
c49=uicontrol('style','text','unit','pixels','position',[430 435 220 16],'String','Start forecasts after last sample period:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c50=uicontrol('style','checkbox','unit','pixels','position',[694 433 20 20],'String','','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb50);

% predicted exogenous variables
c51=uicontrol('style','text','unit','pixels','position',[430 400 250 16],'String','Predicted exogenous variables: on Excel','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% box: credibility level options
c52=uicontrol('style','text','unit','pixels','position',[423 360 150 16],'String','Confidence/credibility level options:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% frame around the box
c53=uicontrol('style','frame','unit','pixels','position',[423 76 304 280],'ForegroundColor',[0.6 0.6 0.6]);

% VAR coefficients confidence level
% create the box title
c54=uicontrol('style','text','unit','pixels','position',[430 330 220 16],'String','VAR coefficients:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c55=uicontrol('style','edit','unit','pixels','position',[650 328 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb55);

% IRFs confidence level
% create the box title
c56=uicontrol('style','text','unit','pixels','position',[430 295 220 16],'String','Impulse response functions:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c57=uicontrol('style','edit','unit','pixels','position',[650 293 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb57);

% forecasts confidence level
% create the box title
c58=uicontrol('style','text','unit','pixels','position',[430 260 220 16],'String','Forecasts:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c59=uicontrol('style','edit','unit','pixels','position',[650 258 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb59);

% FEVD confidence level
% create the box title
c60=uicontrol('style','text','unit','pixels','position',[430 225 250 16],'String','Forecast error variance decomposition:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c61=uicontrol('style','edit','unit','pixels','position',[650 223 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb61);

% historical decomposition confidence level
% create the box title
c62=uicontrol('style','text','unit','pixels','position',[430 190 220 16],'String','Historical decomposition:','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c63=uicontrol('style','edit','unit','pixels','position',[650 188 60 20],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','center','CallBack',@cb63);

% Back button
c64=uicontrol('style','pushbutton','unit','pixels','position',[487 25 70 25],'String','<< Back','HorizontalAlignment','center','FontSize',9,'CallBack',@cb64);

% OK button
c65=uicontrol('style','pushbutton','unit','pixels','position',[572 25 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb65);

% cancel button
c66=uicontrol('style','pushbutton','unit','pixels','position',[657 25 70 25],'String','Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb66);

movegui(gcf,'center')

% default values

if IRF==1
set(c4,'SelectedObject',c5);
elseif IRF==0
set(c4,'SelectedObject',c6);
end

if F==1
set(c8,'SelectedObject',c9);
elseif F==0
set(c8,'SelectedObject',c10);
end

if FEVD==1
set(c12,'SelectedObject',c13);
elseif FEVD==0
set(c12,'SelectedObject',c14);
end

if HD==1
set(c16,'SelectedObject',c17);
elseif HD==0
set(c16,'SelectedObject',c18);
end

if CF==1
set(c20,'SelectedObject',c21);
%set(c32,'Enable','off');
%Feval=0;
elseif CF==0
set(c20,'SelectedObject',c22);
end

% default value for structural identification
   if IRFt==1
   set(c26,'SelectedObject',c27);
   elseif IRFt==2
   set(c26,'SelectedObject',c28);
   elseif IRFt==3
   set(c26,'SelectedObject',c29);
   elseif IRFt==4
   set(c26,'SelectedObject',c30);
   if VARtype==1
   elseif IRFt==5
   set(c26,'SelectedObject',c301);
   elseif IRFt==6
   set(c26,'SelectedObject',c302);
   end
   end

% default value for forecast evaluation
   if Feval==1
   set(c32,'SelectedObject',c33);
   elseif Feval==0
   set(c32,'SelectedObject',c34);
   end

% default value for conditional forecast type
   if CFt==1
   set(c36,'SelectedObject',c37);
   elseif CFt==2
   set(c36,'SelectedObject',c38);
   elseif CFt==3
   set(c36,'SelectedObject',c39);
   elseif CFt==4
   set(c36,'SelectedObject',c40);
   end

% default values for IRF periods
set(c44,'String',IRFperiods);

% default values for forecast start date
set(c46,'String',Fstartdate);

% default values for forecast end date
set(c48,'String',Fenddate);

% default choice for starting forecast at the end of the sample
if window_size>0 
    Fendsmpl=1;  
end

set(c50,'Value',Fendsmpl);

% default values for VAR coefficients confidence level
set(c55,'String',cband);

% default values for IRFs confidence level
set(c57,'String',IRFband);

% default values for forecast confidence level
set(c59,'String',Fband);

% default values for FEVD confidence level
set(c61,'String',FEVDband);

% default values for Historical decomposition confidence level
set(c63,'String',HDband);

% default values for FEVD confidence level
set(c68,'String',window_size);

% default values for FEVD confidence level
set(c72,'String',evaluation_size);

% default values for FEVD confidence level
set(c70,'String',hstep);

% default value interractions between buttons:

% if IRFs are not selected, disactivate FEVD, historical decomposition, structural identification, IRF periods, IRFs confidence level, FEVD confidence level and historical decomposition confidence level as they all depend on IRFs
   if IRF==0
   FEVD=0;
   set(c12,'SelectedObject',c14);
   set(c13,'Enable','off');
   set(c14,'Enable','off');  
   HD=0;
   set(c16,'SelectedObject',c18);
   set(c17,'Enable','off');
   set(c18,'Enable','off'); 
   set(c27,'Enable','off');
   set(c28,'Enable','off');
   set(c29,'Enable','off');
   set(c30,'Enable','off');
   set(c301,'Enable','off');
   set(c302,'Enable','off');
   set(c44,'Enable','off');
   set(c57,'Enable','off');
   set(c61,'Enable','off');
   set(c63,'Enable','off');
   end

% if forecast is not selected, disactivate forecast evaluation
   if F==0
   set(c32,'SelectedObject',c34);
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   end

% deal with the interraction of IRFs and forecasts for conditional forecasts
% standard methodology requires IRFs, tilting requires forecasts
% if both IRFs and forecasts are disactivated, then disactivate conditional forecasts
if (IRF==0 && F==0)
CF=0;
set(c20,'SelectedObject',c22);
set(c21,'Enable','off');
set(c22,'Enable','off');
set(c37,'Enable','off');
set(c38,'Enable','off');
set(c39,'Enable','off');
set(c40,'Enable','off');
% if only IRFs are disactivated, tilting is possible: disactivate only the standard methodology
elseif (IRF==0 && F==1)
CFt=3;
set(c37,'Enable','off');
set(c38,'Enable','off');
set(c36,'SelectedObject',c39);
% if only forecasts are disactivated, standard methodology is possible: disactivate only tilting
elseif (IRF==1 && F==0)
CFt=1;
set(c39,'Enable','off');
set(c40,'Enable','off');
set(c36,'SelectedObject',c37);
end

% if both forecast and conditional forecasts are not selected, also disactivate forecast start date, forecast end date, start of forecasts after the last period, and forecast confidence level
   if F==0 && CF==0
   set(c46,'Enable','off');
   set(c48,'Enable','off');
   set(c50,'Enable','off');
   set(c59,'Enable','off');
   end

% if FEVD is not selected, disactivate FEVD confidence level
   if FEVD==0
   set(c61,'Enable','off');   
   end

% if historical decomposition is not selected, disactivate HD confidence level
   if HD==0
   set(c63,'Enable','off');   
   end  
   
% if conditional forecasts are not selected, disactivate the choice of conditional forecast type
   if CF==0
   set(c37,'Enable','off');
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   %
   end
   
  
% if structural decomposition is set to 'none', disactivate FEVD and HD as they require an orthogonalised identification
   if IRFt==1
   FEVD=0;
   set(c12,'SelectedObject',c14);
   set(c13,'Enable','off');
   set(c14,'Enable','off');
   HD=0;
   set(c16,'SelectedObject',c18);
   set(c17,'Enable','off');
   set(c18,'Enable','off');
      % also, depending on the VAR type, conditional forecasts can be affected
      % if the model is the BVAR, mean-adjusted BVAR or stochastic volatility BVAR, disactivate conditional forecasts only if unconditional forecasts are also turned off (for then tilting is also unavailable)
      if (VARtype==2 || VARtype==3 || VARtype==5) && F==0
      CF=0;
      set(c20,'SelectedObject',c22);
      set(c21,'Enable','off');
      set(c22,'Enable','off');
      set(c37,'Enable','off');
      set(c38,'Enable','off');
      % else if the model is the panel VAR, disactivate conditional forecasts
      elseif VARtype==4
      CF=0;
      set(c20,'SelectedObject',c22);
      set(c21,'Enable','off');
      set(c22,'Enable','off');  
      set(c37,'Enable','off');
      set(c38,'Enable','off');
      end
   end

% if 'start forecasts after last period' is activated, disactivate forecast start date
   if Fendsmpl==1
   set(c46,'Enable','off');
   end
   
% potential disactivations according to the type of VAR

% if OLS, disactivate conditional forecasts, sign restrictions, type of conditional forecasts, and credibility levels for FEVD and HD
if VARtype==1
% disactivate conditional forecasts
CF=0;
set(c20,'SelectedObject',c22);
set(c19,'Visible','off');
set(c20,'Visible','off');
set(c21,'Visible','off');
set(c22,'Visible','off');
set(c21,'Enable','inactive');
set(c22,'Enable','inactive');
% disactivate type of conditional forecasts
set(c35,'Visible','off');
set(c36,'Visible','off');
set(c37,'Visible','off');
set(c38,'Visible','off');
set(c39,'Visible','off');
set(c40,'Visible','off');
set(c37,'Enable','inactive');
set(c38,'Enable','inactive');
set(c39,'Enable','inactive');
set(c40,'Enable','inactive');
% disactivate confidence level for FEVD
set(c60,'Visible','off');
set(c61,'Visible','off');
set(c61,'Enable','inactive');
% disactivate confidence level for HD
set(c62,'Visible','off');
set(c63,'Visible','off');
set(c63,'Enable','inactive');

% if the BVAR, mean-adjusted BVAR or stochastic volatility BVAR models are selected, all the options can apply: don't disactivate anything

% if the model is the panel BVAR, some features have to be disactivated
elseif VARtype==4
% disactivate tilting as a possible type of conditional forecasts
if CF==1 && (CFt==3 || CFt==4)
CFt=1;
set(c36,'SelectedObject',c37);
end
set(c39,'Visible','off');
set(c40,'Visible','off');
set(c39,'Enable','inactive');
set(c40,'Enable','inactive');
   % if the model is the OLS mean group estimator, also eliminate all the non-OLS applications
   if panel==1
   % disactivate conditional forecasts
   CF=0;
   set(c20,'SelectedObject',c22);
   set(c19,'Visible','off');
   set(c20,'Visible','off');
   set(c21,'Visible','off');
   set(c22,'Visible','off');
   set(c21,'Enable','inactive');
   set(c22,'Enable','inactive');  
   % disactivate type of conditional forecasts
   set(c35,'Visible','off');
   set(c36,'Visible','off');
   set(c37,'Visible','off');
   set(c38,'Visible','off');
   set(c39,'Visible','off');
   set(c40,'Visible','off');
   set(c37,'Enable','inactive');
   set(c38,'Enable','inactive');
   set(c39,'Enable','inactive');
   set(c40,'Enable','inactive');
   % disactivate confidence level for FEVD
   set(c60,'Visible','off');
   set(c61,'Visible','off');
   set(c61,'Enable','inactive');
   % disactivate confidence level for HD
   set(c62,'Visible','off');
   set(c63,'Visible','off');
   set(c63,'Enable','inactive');
   end 
end





% PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS

function cb4(hObject,callbackdata)
   % if 'yes' is selected
   if get(c4,'SelectedObject')==c5
   IRF=1;
   % if a structural decomposition is selected, re-activate FEVD, HD, and conditional forecasts
      if IRFt~=1
      set(c13,'Enable','on');
      set(c14,'Enable','on');  
      set(c17,'Enable','on');
      set(c18,'Enable','on');     
      set(c21,'Enable','on');
      set(c22,'Enable','on'); 
      end
   % reactivate the selection of structural decomposition
   set(c27,'Enable','on');
   set(c28,'Enable','on');
   set(c29,'Enable','on');
   set(c30,'Enable','on');
   set(c301,'Enable','on');
   set(c302,'Enable','on');
   % if on top of that conditional forecasts are selected, reactivate the standard methodology
      if IRFt~=1 && CF==1
      set(c37,'Enable','on');
      set(c38,'Enable','on');
      end
   % reactivate IRF periods
   set(c44,'Enable','on');
   % reactivate IRF credibility level
   set(c57,'Enable','on');
   % else, if 'no' is selected
   elseif get(c4,'SelectedObject')==c6
   IRF=0;
   % disactivate FEVD, HD
   FEVD=0;
   set(c12,'SelectedObject',c14);
   set(c13,'Enable','off');
   set(c14,'Enable','off');
   HD=0;
   set(c16,'SelectedObject',c18); 
   set(c17,'Enable','off');
   set(c18,'Enable','off');
   % if forecast is disactivated, also disactivate conditional forecasts
      if F==0
      CF=0;
      set(c20,'SelectedObject',c22);     
      set(c21,'Enable','off');
      set(c22,'Enable','off');
      end
   % disactivate the structural decomposition
   set(c27,'Enable','off');
   set(c28,'Enable','off');
   set(c29,'Enable','off');
   set(c30,'Enable','off');
   set(c301,'Enable','off');
   set(c302,'Enable','off');
   % disactivate the standard type of conditional forecasts
   set(c37,'Enable','off');
   set(c38,'Enable','off');
   % if forecast is disactivated, conditional forecasts is disactivated as well: hence, disactivate all the forecasts periods
   set(c46,'Enable','off');
   set(c48,'Enable','off');
   set(c50,'Enable','off');
   % disactivate IRF periods
   set(c44,'Enable','off');
   % disactivate IRF credibility level
   set(c57,'Enable','off');
   end
end

function cb8(hObject,callbackdata)
   % if 'yes' is selected
   if get(c8,'SelectedObject')==c9
   F=1;
   % activate conditional forecasts (only for BVAR, mean-adjusted BVAR and stochastic volatility BVAR which can use tilting)
      if VARtype==2 || VARtype==3 || VARtype==5
      set(c21,'Enable','on');
      set(c22,'Enable','on');
      end
   % activate forecast evaluation
   set(c33,'Enable','on');
   set(c34,'Enable','on');
   set(c68,'Enable','on');
   set(c70,'Enable','on');
   % if conditional forecast is activated, activate tilting
      if CF==1
      set(c39,'Enable','on');    
      set(c40,'Enable','on');
      end
   % re-activate the relevant forecast period options
   set(c48,'Enable','on');
      if Fendsmpl==1
      set(c50,'Enable','on');
      elseif Fendsmpl==0
      set(c50,'Enable','on');
      set(c46,'Enable','on');
      end
   % re-activate forecast confidence level
   set(c59,'Enable','on');
   % else, if 'no' is selected
   elseif get(c8,'SelectedObject')==c10
   F=0;
   % disactivate conditional forecasts for BVAR, mean-adjusted BVAR and stochastic volatility BVAR if there is no structural identification (for then neither the standard nor the tilting methodology are available)
      if (VARtype==2 || VARtype==3 || VARtype==5) && (IRFt==1)
      CF=0;
      set(c20,'SelectedObject',c22);
      set(c21,'Enable','off');
      set(c22,'Enable','off');
      end
   % disactivate forecast evaluation
   set(c33,'Enable','off');
   set(c34,'Enable','off');
   set(c68,'String',0);
   window_size=0;
   set(c68,'Enable','off');
   set(c70,'Enable','off');
   set(c72,'Enable','off');
   
   % disactivate tilting
   set(c39,'Enable','off');    
   set(c40,'Enable','off');
   % disactivate all the forecast period options
   set(c46,'Enable','off');
   set(c48,'Enable','off');
   set(c50,'Enable','off');
   % if conditional forecasts is disactivated as well, disactivate forecasts confidence level
      if CF==0
      set(c59,'Enable','off');
      end
   end
end

function cb12(hObject,callbackdata)
   % if 'yes' is selected
   if get(c12,'SelectedObject')==c13   
   FEVD=1;
   % re-activate FEVD confidence level
   set(c61,'Enable','on');
   % else, if 'no' is selected
   elseif get(c12,'SelectedObject')==c14 
   FEVD=0;
   % disactivate FEVD confidence level
   set(c61,'Enable','off');
   end
end

function cb16(hObject,callbackdata)
   % if 'yes' is selected
   if get(c16,'SelectedObject')==c17   
   HD=1;
   % re-activate HD confidence level
   set(c63,'Enable','on');
   % else, if 'no' is selected
   elseif get(c16,'SelectedObject')==c18 
   HD=0;
   % disactivate HD confidence level
   set(c63,'Enable','off');
   end
end


function cb20(hObject,callbackdata)
   % if 'yes' is selected
   if get(c20,'SelectedObject')==c21   
   CF=1;
   Feval=0;
   % re-activate FEVD confidence level
%   set(c32,'Enable','off');
%   set(c66,'Enable','off');  
%   set(c68,'Enable','off');  
%   set(c70,'Enable','off');  
%   set(c72,'Enable','off');  
   % re-activate the type of conditional forecasts compatible with the other options selected
   % if IRFs are activated and a structural decomposition is selected, re-activate the standard methodology
      if (IRF==1 && IRFt~=1)
      set(c37,'Enable','on');  
      set(c38,'Enable','on');
      end
   % if forecasts are activated, re-activate tilting
      if F==1
      set(c39,'Enable','on');  
      set(c40,'Enable','on');
      end
   % re-activate the forecast period options   
   if Fendsmpl==0
   set(c46,'Enable','on');
   end
   set(c48,'Enable','on');
   set(c50,'Enable','on');
   % re-activate forecasts confidence level
   set(c59,'Enable','on');
   % else, if 'no' is selected
   elseif get(c20,'SelectedObject')==c22   
   CF=0;
   % disactivate the type of conditional forecasts
   set(c37,'Enable','off');  
   set(c38,'Enable','off');
   set(c39,'Enable','off');
   set(c40,'Enable','off');
   % if forecasts are also disactivated, disactivate all the forecast period options
      if F==0
      set(c46,'Enable','off');
      set(c48,'Enable','off');
      set(c50,'Enable','off');  
      end
   % if forecasts are also disactivated, disactivate the forecast confidence level
      if F==0
      set(c59,'Enable','off');
      end
   end
end


function cb26(hObject,callbackdata)
   % if 'none' is selected
   if get(c26,'SelectedObject')==c27
   IRFt=1;
   % disactivate FEVD and HD
   FEVD=0;
   set(c12,'SelectedObject',c14);
   set(c13,'Enable','off');
   set(c14,'Enable','off');
   HD=0;
   set(c16,'SelectedObject',c18);
   set(c17,'Enable','off');
   set(c18,'Enable','off');
   % if the model is the BVAR, mean-adjusted BVAR or stochastic volatility BVAR, and forecast is disactivated, also disactivate conditional forecasts
      if (VARtype==2 || VARtype==3 || VARtype==5) && F==0
      CF=0;
      set(c20,'SelectedObject',c22);
      set(c21,'Enable','off');
      set(c22,'Enable','off');
      end
   % else if the model is the BVAR, mean-adjusted BVAR or stochastic volatility BVAR, and forecast is activated, tilting is still possible
      if (VARtype==2 || VARtype==3 || VARtype==5) && (F==1 && CF==1)
      set(c36,'SelectedObject',c39);
      set(c37,'Enable','off');
      set(c38,'Enable','off');
      end
   % if the model is the panel VAR, disactivate conditional forecasts as tandard is the only available methodology
      if VARtype==4
      CF=0;
      set(c20,'SelectedObject',c22);
      set(c21,'Enable','off');
      set(c22,'Enable','off');
      end
   % else, if any structural decomposition is applied
   elseif get(c26,'SelectedObject')==c28 || get(c26,'SelectedObject')==c29 || get(c26,'SelectedObject')==c30 || get(c26,'SelectedObject')==c301 || get(c26,'SelectedObject')==c302
      if get(c26,'SelectedObject')==c28
      IRFt=2;
      elseif get(c26,'SelectedObject')==c29
      IRFt=3;
      elseif get(c26,'SelectedObject')==c30
      IRFt=4;
      elseif get(c26,'SelectedObject')==c301
      IRFt=5;
      elseif get(c26,'SelectedObject')==c302
      IRFt=6;
      end 
   % reactivate FEVD, HD and conditional forecasts
   set(c13,'Enable','on');
   set(c14,'Enable','on');
   set(c17,'Enable','on');
   set(c18,'Enable','on');
   set(c21,'Enable','on');
   set(c22,'Enable','on');
   % if conditional forecast is activated, re-activate the standard methodology
      if CF==1
      set(c37,'Enable','on');
      set(c38,'Enable','on');
      end
   end
end

function cb32(hObject,callbackdata)
   if get(c32,'SelectedObject')==c33   
   Feval=1;
   set(c68,'Enable','on');
   set(c70,'Enable','on');
   set(c72,'Enable','on');
   elseif get(c32,'SelectedObject')==c34 
   Feval=0;
   window_size=0;
    set(c68,'String',0);
    set(c68,'Enable','off');
    set(c70,'Enable','off');
    set(c72,'Enable','off');
   end
end

function cb36(hObject,callbackdata)
   if get(c36,'SelectedObject')==c37
   CFt=1;
   elseif get(c36,'SelectedObject')==c38
   CFt=2;
   elseif get(c36,'SelectedObject')==c39
   CFt=3;
   elseif get(c36,'SelectedObject')==c40
   CFt=4;
   end
end

function cb44(hObject,callbackdata)
IRFperiods=str2num(get(c44,'String'));
end

function cb46(hObject,callbackdata)
Fstartdate=get(c46,'String');
end

function cb48(hObject,callbackdata)
Fenddate=get(c48,'String');
end

function cb50(hObject,callbackdata)
Fendsmpl=get(c50,'Value');
   if Fendsmpl==1
   set(c46,'Enable','off');
   elseif Fendsmpl==0
   set(c46,'Enable','on');
   end
end

function cb55(hObject,callbackdata)
cband=str2num(get(c55,'String'));
end

function cb57(hObject,callbackdata)
IRFband=str2num(get(c57,'String'));
end

function cb59(hObject,callbackdata)
Fband=str2num(get(c59,'String'));
end

function cb61(hObject,callbackdata)
FEVDband=str2num(get(c61,'String'));
end

function cb63(hObject,callbackdata)
HDband=str2num(get(c63,'String'));
end

function cb64(hObject,callbackdata)
validation=1;
close(fig)
end

function cb68(hObject,callbackdata)
window_size=str2num(get(c68,'String'));
    if window_size>0
        set(c50,'Value',1);
        Fendsmpl=1;
        pref.plot=0;
    end
end

function cb72(hObject,callbackdata)
evaluation_size=str2num(get(c72,'String'));
end


function cb70(hObject,callbackdata)
hstep=str2num(get(c70,'String'));
    if hstep<0
        set(c70,'String',1);
        hstep=1;
    end
end    

function cb65(hObject,callbackdata)
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(IRFperiods) && IRF==1
   msgbox('IRF periods is missing. Please indicate a value.');
   elseif isempty(Fstartdate) && Fendsmpl==0 && F==1
   msgbox('Start date for forecast is missing. Please indicate a start date, or select the option to start forecast after the last sample period.');
   elseif isempty(Fenddate)==1 && F==1
   msgbox('End date for forecast is missing. Please indicate an end date.');
   elseif isempty(Fstartdate) && Fendsmpl==0 && CF==1
   msgbox('Start date for forecast is missing. Please indicate a start date, or select the option to start forecast after the last sample period.');
   elseif isempty(Fenddate)==1 && CF==1
   msgbox('End date for forecast is missing. Please indicate an end date.');
   elseif isempty(cband)
   msgbox('Confidence level for VAR coefficients is missing. Please indicate a value.');
   elseif isempty(IRFband) && IRF==1
   msgbox('Confidence level for impulse response functions is missing. Please indicate a value.');
   elseif isempty(Fband) && F==1
   msgbox('Confidence level for forecasts is missing. Please indicate a value.');
   elseif isempty(Fband) && CF==1
   msgbox('Confidence level for forecasts is missing. Please indicate a value.');
   elseif isempty(FEVDband) && FEVD==1
   msgbox('Confidence level for forecasterror variance decomposition is missing. Please indicate a value.');
   elseif isempty(HDband) && HD==1
   msgbox('Confidence level for historical decomposition is missing. Please indicate a value.');
   elseif isempty(window_size) 
   window_size=0;
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=2;
   close(fig)
   end
end

function cb66(hObject,callbackdata)
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
if window_size>0;
   Fendsmpl=1; 
end
% fix any string that may require it
Fstartdate=fixstring(Fstartdate);
Fenddate=fixstring(Fenddate);

   % then if user's preferences have been selected
   if pref.pref==1
  
   save('userpref6.mat','IRF','F','FEVD','HD','CF','IRFt','Feval','CFt','IRFperiods','Fstartdate','Fenddate','Fendsmpl','cband','IRFband','Fband','FEVDband','HDband','window_size','evaluation_size', 'hstep');
   
   % if the user did not want to save pereferences, do not do save anything
   else
   end


   % PHASE OF INFORMATION CONVERSION

   % the only task that remains is to convert the information "start forecast after last sample period" (if chosen) into a date
   if Fendsmpl==1
      % if data is yearly
      if frequency==1
      Fstartdate=[num2str(str2num(enddate(1,1:end-1))+1) 'y'];
      % if data is quarterly
      elseif frequency==2
      % first identify the year and quarter of the sample end date
      endyear=str2num(enddate(1,1:4));
      endquarter=str2num(enddate(1,6));
      % then increment by one quarter
         if endquarter<=3
         Fstartdate=[num2str(endyear) 'q' num2str(endquarter+1)];
         elseif endquarter==4
         Fstartdate=[num2str(endyear+1) 'q1'];
         end
      % if data is monthly
      elseif frequency==3
      % first identify the year and month of the sample end date
      temp=enddate;
      temp(1,5)=' ';
      [endyear,endmonth]=strtok(temp);
      endyear=str2num(endyear);
      endmonth=str2num(endmonth);
      % then increment by one month
         if endmonth<=11
         Fstartdate=[num2str(endyear) 'm' num2str(endmonth+1)];
         elseif endmonth==12
         Fstartdate=[num2str(endyear+1) 'm1'];
         end
      % if data is weekly
      elseif frequency==4
      % first identify the year and week of the sample end date
      temp=enddate;
      temp(1,5)=' ';
      [endyear,endweek]=strtok(temp);
      endyear=str2num(endyear);
      endweek=str2num(endweek);
      % then increment by one week
         if endweek<=51
         Fstartdate=[num2str(endyear) 'w' num2str(endweek+1)];
         else
         Fstartdate=[num2str(endyear+1) 'w1'];
         end
      % if data is daily
      elseif frequency==5
      % first identify the year and day of the sample end date
      temp=enddate;
      temp(1,5)=' ';
      [endyear,endday]=strtok(temp);
      endyear=str2num(endyear);
      endday=str2num(endday);
      % then increment by one day
         if endday<=260
         Fstartdate=[num2str(endyear) 'd' num2str(endday+1)];
         else
         Fstartdate=[num2str(endyear+1) 'd1'];
         end
      % finally, if data is unddated
      elseif frequency==6
      Fstartdate=[num2str(str2num(enddate(1,1:end-1))+1) 'u'];
      end
   end
end


% indicate which interface is to be opened next, depending on the user's choice
% if back button was pushed, go back to previous interface, which can be interface 1, 2, 3, 4 or 5
if validation==1
   if VARtype==1
   interface='interface1';
   elseif VARtype==2
   interface='interface2';
   elseif VARtype==3
   interface='interface3';
   elseif VARtype==4
   interface='interface4';
   elseif VARtype==5
   interface='interface5';
   elseif VARtype==6
   interface='interface7';
   end
% if OK button was pushed, this is the end of the interface phase
elseif validation==2
interface='over';
end



% finally, declare end of the full nested function
end






