function [VARtype,frequency,startdate,enddate,endo,exo,lags,const,pref,interface,interinfo1]=interface1(interinfo1)



% function [VARtype,frequency,startdate,enddate,endo,exo,lags,const,datapath,pref]=interface1
% displays user interface 1 and record user's inputs
% inputs: none 
% outputs: - integer 'VARtype': type of VAR model selected by the user (BVAR, MABVAR, OLS VAR)
%          - integer 'frequency': frequency of the data set
%          - string 'startdate': start date of the sample
%          - string 'enddate': end date of the sample
%          - cell 'endo': list of endogenous variables of the model
%          - cell 'exo': list of exogenous variables of the model
%          - integer 'lags': number of lags included in the model
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - string 'datapath': user-supplied path to excel data spreadsheet
%          - string 'results_sub': user-supplied results spreadsheet
%          - integer 'pref': 0-1 value to determine if a user choices must be saved


% default cancellation value; this will return an error if the user closes
% the window using the upper-right cross rather than the cancel button
validation=2;

% set default values
% if user preferences exist, load them, and attribute them
if exist('userpref1.mat','file')==2
load('userpref1.mat')
% if no user preferences have been saved, run the interface with the default (system) preferences
else
VARtype=1;
frequency=1;
startdate='';
enddate='';
varendo='';
varexo='';
lags='';
const=1;
pref.datapath=fileparts(pwd);
pref.results_sub='results';
pref.results=1;
pref.pref=0;
pref.plot=0;
end


if isempty(interinfo1)
else
VARtype=interinfo1{1,1};
frequency=interinfo1{2,1};
startdate=interinfo1{3,1};
enddate=interinfo1{4,1};
varendo=interinfo1{5,1};
varexo=interinfo1{6,1};
lags=interinfo1{7,1};
const=interinfo1{8,1};
pref.datapath=interinfo1{9,1};
pref.results_sub=interinfo1{10,1};
pref.pref=interinfo1{11,1};
pref.results=interinfo1{12,1};
pref.plot=interinfo1{13,1};
end





% PHASE OF FIGURE CREATION


% initiate figure
fig=figure('units','pixels','position',[500 380 590 624],'name', 'VAR specification','MenuBar','none','Color',[0.938 0.938 0.938],'NumberTitle','off');

c1=uicontrol('style','text','unit','pixels','position',[13 589 565 16],'String','Bayesian Estimation, Analysis and Regression (BEAR) Toolbox 4.5','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c2=uicontrol('style','text','unit','pixels','position',[13 564 565 16],'String','Developed by R. Legrand, A. Dieppe, and B. van Roye','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
c3=uicontrol('style','text','unit','pixels','position',[13 539 565 16],'String','External Development Division, European Central Bank','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);

% VAR type
% create the box title
c4=uicontrol('style','text','unit','pixels','position',[13 487 165 16],'String','VAR type','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c5=uibuttongroup('unit','pixels','Position',[13 325 195 161],'SelectionChangeFcn',@cb5);
% create each radiobutton in the group
c6=uicontrol(c5,'Style','radiobutton','String','Standard OLS VAR','Position',[7 132 150 18],'FontName','Times New Roman','FontSize',10);
c7=uicontrol(c5,'Style','radiobutton','String','Bayesian VAR','Position',[7 108 150 18],'FontName','Times New Roman','FontSize',10);
c8=uicontrol(c5,'Style','radiobutton','String','Mean-adjusted BVAR','Position',[7 84 150 18],'FontName','Times New Roman','FontSize',10);
c9=uicontrol(c5,'Style','radiobutton','String','Panel VAR','Position',[7 60 150 18],'FontName','Times New Roman','FontSize',10);
c31=uicontrol(c5,'Style','radiobutton','String','Stochastic volatility BVAR','Position',[7 36 170 18],'FontName','Times New Roman','FontSize',10);
c36=uicontrol(c5,'Style','radiobutton','String','Time-varying BVAR','Position',[7 12 170 18],'FontName','Times New Roman','FontSize',10);

movegui(gcf,'center')
% default value for VAR type
   if VARtype==1
   set(c5,'SelectedObject',c6);
   elseif VARtype==2
   set(c5,'SelectedObject',c7);
   elseif VARtype==3
   set(c5,'SelectedObject',c8);
   elseif VARtype==4
   set(c5,'SelectedObject',c9);
   elseif VARtype==5
   set(c5,'SelectedObject',c31);
   elseif VARtype==6
   set(c5,'SelectedObject',c36);
   end

% endogenous variables
% create the box title
c10=uicontrol('style','text','unit','pixels','position',[230 487 340 16],'String','Enter the list of endogenous variables, separated by a space','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c11=uicontrol('style','edit','unit','pixels','position',[230 424 340 62],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','Max',2,'CallBack',@cb11);
% default values for endogenous variables
set(c11,'String',varendo);

% exogenous variables
% create the box title
c12=uicontrol('style','text','unit','pixels','position',[230 388 340 16],'String','Enter the list of exogenous variables, separated by a space','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c13=uicontrol('style','edit','unit','pixels','position',[230 325 340 62],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','Max',2,'CallBack',@cb13);
% default values for exogenous variables
set(c13,'String',varexo);

% data frequency
% create the box title
c14=uicontrol('style','text','unit','pixels','position',[13 291 180 16],'String','Data frequency','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c15=uicontrol('Style','popupmenu','String', {'Yearly','Quarterly','Monthly','Weekly','Daily','Undated'},'position',[13 272 180 18],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'CallBack',@cb15);
% default values for the button group
set(c15,'Value',frequency);

% choice for constant
% create the box title
c16=uicontrol('style','text','unit','pixels','position',[230 291 300 16],'String','Include constant in the regression','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create a group of radio buttons
c17=uibuttongroup('unit','pixels','Position',[230 261 150 28],'SelectionChangeFcn',@cb17);
% create each radiobutton in the group
c18=uicontrol(c17,'Style','radiobutton','String','Yes','Position',[7 5 60 18],'FontName','Times New Roman','FontSize',10);
c19=uicontrol(c17,'Style','radiobutton','String','No','Position',[60 5 60 18],'FontName','Times New Roman','FontSize',10);
% default value for const
   if const==1
   set(c17,'SelectedObject',c18);
   elseif const==0
   set(c17,'SelectedObject',c19);
   end
   if VARtype==3
   set(c17,'SelectedObject',c18); 
   set(c18,'Enable','off');
   set(c19,'Enable','off');
   const=1;
   end

% sample start date
% create the box title
c20=uicontrol('style','text','unit','pixels','position',[13 234 180 16],'String','Estimation sample: start date','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c21=uicontrol('style','edit','unit','pixels','position',[13 212 180 21],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','CallBack',@cb21);
% default values for start date
set(c21,'String',startdate);

% lag number
% create the box title
c22=uicontrol('style','text','unit','pixels','position',[230 234 300 16],'String','Number of lags for endogenous variables','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c23=uicontrol('style','edit','unit','pixels','position',[230 212 100 21],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','CallBack',@cb23);
% default values for lag number
set(c23,'String',lags);

% sample end date
% create the box title
c24=uicontrol('style','text','unit','pixels','position',[13 178 180 16],'String','Estimation sample: end date','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c25=uicontrol('style','edit','unit','pixels','position',[13 156 180 21],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','CallBack',@cb25);
% default values for end date
set(c25,'String',enddate);

% data path
% create the box title
c26=uicontrol('style','text','unit','pixels','position',[13 93 300 16],'String','Set path to data','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c27=uicontrol('style','edit','unit','pixels','position',[13 71 560 21],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','CallBack',@cb27);
% default values for data path
set(c27,'String',pref.datapath);

% save of preferences
% create the box
c28=uicontrol('style','checkbox','unit','pixels','position',[13 30 300 16],'String',' Remember my preferences','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@cb28);
% default choice for preference savings
set(c28,'Value',pref.pref);

% OK button
c29=uicontrol('style','pushbutton','unit','pixels','position',[400 25 70 25],'String','OK >>','HorizontalAlignment','center','FontSize',9,'CallBack',@cb29);

% cancel button
c30=uicontrol('style','pushbutton','unit','pixels','position',[480 25 70 25],'String','Cancel','HorizontalAlignment','center','FontSize',9,'CallBack',@cb30);

% results path
% create the box title
c32=uicontrol('style','text','unit','pixels','position',[230 178 300 16],'String','Set results file','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10);
% create the box
c33=uicontrol('style','edit','unit','pixels','position',[230 156 340 21],'BackgroundColor',[1 1 1],'FontName','Times New Roman','FontSize',10,'HorizontalAlignment','left','CallBack',@cb33);
% default values for data path
set(c33,'String',pref.results_sub);

c35=uicontrol('style','checkbox','unit','pixels','position',[13 120 200 16],'String','Output in excel','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@do_resultsb);
set(c35,'Value',pref.results);

do_plot2=uicontrol('style','checkbox','unit','pixels','position',[230 120 200 16],'String','Produce figures','HorizontalAlignment','left','FontName','Times New Roman','FontSize',10,'CallBack',@do_plotb);
set(do_plot2,'Value',pref.plot);

   % PHASE OF DEFINITION OF ALL THE CALLBACK FUNCTIONS


function cb5(hObject,callbackdata)
   if get(c5,'SelectedObject')==c6
   VARtype=1;
   set(c18,'Enable','on');
   set(c19,'Enable','on');
   elseif get(c5,'SelectedObject')==c7
   VARtype=2;
   set(c18,'Enable','on');
   set(c19,'Enable','on');
   elseif get(c5,'SelectedObject')==c8
   VARtype=3;
   const=1;
   set(c17,'SelectedObject',c18);
   set(c18,'Enable','off');
   set(c19,'Enable','off');
   elseif get(c5,'SelectedObject')==c9
   VARtype=4;
   set(c18,'Enable','on');
   set(c19,'Enable','on');
   elseif get(c5,'SelectedObject')==c31
   VARtype=5;
   set(c18,'Enable','on');
   set(c19,'Enable','on');
   elseif get(c5,'SelectedObject')==c36
   VARtype=6;
   set(c18,'Enable','on');
   set(c19,'Enable','on');
   end
end

function cb11(hObject,callbackdata)
varendo=get(c11,'String');
end

function cb13(hObject,callbackdata)
varexo=get(c13,'String');
end

function cb15(hObject,callbackdata)
frequency=get(c15,'Value');
end

function cb17(hObject,callbackdata)
   if get(c17,'SelectedObject')==c18
   const=1;
   elseif get(c17,'SelectedObject')==c19
   const=0;
   end
end

function cb21(hObject,callbackdata)
startdate=get(c21,'String');
end

function cb23(hObject,callbackdata)
lags=str2num(get(c23,'String'));
end

function cb25(hObject,callbackdata)
enddate=get(c25,'String');
end

function cb27(hObject,callbackdata)
pref.datapath=get(c27,'String');
end

function cb28(hObject,callbackdata)
pref.pref=get(c28,'Value');
end

function cb33(hObject,callbackdata)
pref.results_sub=get(c33,'String');
end

function cb29(hObject,callbackdata)
% first check that all required fields have been filled; if not, ask to fill them
   if isempty(varendo)==1
   msgbox('Endogenous variables are missing. Please indicate at least one endogenous variable.');
   elseif isempty(startdate)==1
   msgbox('Start date is missing. Please indicate a start date for the estimation sample.');
   elseif isempty(enddate)==1
   msgbox('End date is missing. Please indicate an end date for the estimation sample.');
   elseif isempty(lags)==1
   msgbox('Lag number is missing. Please indicate the number of lags for the model.');
   % if all the fields are filled, indicate that the user has validated, and close the interface
   else
   validation=1;
   close(fig)
   end
end

function cb30(hObject,callbackdata)
validation=2;
close(fig)
end

function do_resultsb(hObject,callbackdata)
pref.results=get(c35,'Value');
end

function do_plotb(hObject,callbackdata)
pref.plot=get(do_plot2,'Value');
end


% PHASE OF INTERFACE VALIDATION AND SAVING OF USER'S PREFERENCES


% stop programme execution until the user pushes OK or cancel
uiwait(fig);
% if Cancel is pushed
if validation==2
msgbox('Data input canceled by the user. Please restart the programme.');
error('User cancellation');
end


% otherwise, pursue the running of the code
% fix the strings that may require it
startdate=fixstring(startdate);
enddate=fixstring(enddate);
varendo=fixstring(varendo);
varexo=fixstring(varexo);
pref.datapath=fixstring(pref.datapath);
pref.results_sub=fixstring(pref.results_sub);

% if OK was pushed and user's preferences have been selected, replace the former save file (if any)
if pref.pref==1
    
   save('userpref1.mat','VARtype','frequency','startdate','enddate','varendo','varexo','lags','const','pref')
   
% if the user did not want to save pereferences, do not do save anything
else
end





% PHASE OF CONVERSION TO IDENTIFY THE ENDOGENOUS AND EXOGENOUS VARIABLES


% recover the names of the different endogenous variables; 
% to do so, separate the string 'varendo' into individual names
% look for the spaces and identify their locations
findspace=isspace(varendo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(varendo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo=nspace+1;
% now finally identify the endogenous
endo=cell(numendo,1);
for ii=1:numendo
endo{ii,1}=varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

% proceed similarly for exogenous series; note however that it may be empty
% so check first whether there are exogenous variables altogether
if isempty(varexo==1)
exo={};
% if not empty, repeet what has been done with the exogenous
else
findspace=isspace(varexo);
locspace=find(findspace);
delimiters=[0 locspace numel(varexo)+1];
nspace=sum(findspace(:)==1);
numexo=nspace+1;
exo=cell(numexo,1);
   for ii=1:numexo
   exo{ii,1}=varexo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
   end
end



% indicate which interface is to be opened next; this depends on the choice of model
% if standard OLS VAR, directly go to interface 6
if VARtype==1
interface='interface6';
% if Bayesian VAR, go to interface 2
elseif VARtype==2
interface='interface2';
% if mean-adjusted BVAR, go to interface 3
elseif VARtype==3
interface='interface3';
% if panel BVAR, go to interface 4
elseif VARtype==4
interface='interface4';
% if stochastic volatility BVAR, go to interface 5
elseif VARtype==5
interface='interface5';
% if time-varying BVAR, go to interface 6
elseif VARtype==6
interface='interface7';
end



% finally, declare end of the full nested function
end







