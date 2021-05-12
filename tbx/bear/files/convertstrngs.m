% as a preliminary task, fix all the strings that may require it
startdate=fixstring(startdate);
enddate=fixstring(enddate);
varendo=fixstring(varendo);
varexo=fixstring(varexo);
datapath=fixstring(pref.datapath);
% FAVAR: additional strings
if favar.FAVAR==1
    favar.plotX=fixstring(favar.plotX);
    if favar.blocks==1 || favar.slowfast==1
        favar.blocknames=fixstring(favar.blocknames);
    end
        if favar.blocks==1
            favar.blocknumpc=fixstring(favar.blocknumpc);
        end
        if favar.IRF.plot==1
            favar.IRF.plotXshock=fixstring(favar.IRF.plotXshock);
        end
    favar.transform_endo=fixstring(favar.transform_endo);
end
if F==1
Fstartdate=fixstring(Fstartdate);
Fenddate=fixstring(Fenddate);
end
if VARtype==4
unitnames=fixstring(unitnames);
end

% first recover the names of the different endogenous variables; 
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

% FAVAR: additional strings 
if favar.FAVAR==1
% favar.plotX
findspace=isspace(favar.plotX);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.plotX)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceplotX=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numplotX=nspaceplotX+1;
% now finally identify the endogenous
favar.pltX=cell(numplotX,1);
for ii=1:numplotX
favar.pltX{ii,1}=favar.plotX(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

if favar.blocks==1 || favar.slowfast==1
findspace=isspace(favar.blocknames);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.blocknames)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceblocknames=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numblocknames=nspaceblocknames+1;
% now finally identify the endogenous
favar.bnames=cell(numblocknames,1);
for ii=1:numblocknames
favar.bnames{ii,1}=favar.blocknames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end
end

if favar.blocks==1
findspace=isspace(favar.blocknumpc);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.blocknumpc)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceblocknumpc=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numblocknumpc=nspaceblocknumpc+1;
% now finally identify the endogenous
favar.bnumpc=cell(numblocknumpc,1);
for ii=1:numblocknumpc
favar.bnumpc{ii,1}=str2num(favar.blocknumpc(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
end
end
        
if favar.IRF.plot==1
findspace=isspace(favar.IRF.plotXshock);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.IRF.plotXshock)+1];
% count the number of endogenous variables
% first count the number of spaces
nspaceplotXshock=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numplotXshock=nspaceplotXshock+1;
% now finally identify the endogenous
favar.IRF.pltXshck=cell(numplotXshock,1);
for ii=1:numplotXshock
favar.IRF.pltXshck{ii,1}=favar.IRF.plotXshock(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end
end
 
findspace=isspace(favar.transform_endo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(favar.transform_endo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspacetransform_endo=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numtransform_endo=nspacetransform_endo+1;
% now finally identify the endogenous
favar.trnsfrm_endo=cell(numtransform_endo,1);
for ii=1:numtransform_endo
favar.trnsfrm_endo{ii,1}=str2num(favar.transform_endo(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
end
        
end


% proceed similarly for exogenous series; note however that it may be empty
% so check first whether there are exogenous variables altogether
if isempty(varexo==1)
exo={};
% if not empty, repeat what has been done with the exogenous
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

% finally, if applicable, recover the names of the different units
if VARtype==4
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
end


