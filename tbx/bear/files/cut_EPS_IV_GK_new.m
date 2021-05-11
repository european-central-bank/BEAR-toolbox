function [EPSIV,IV,entry_of_IV_in_Y,txt] = cut_EPS_IV_GK_new(txt, names, EPSdraw, IV, cut1, cut2, cut3, cut4, startdate, enddate, p)
% Load IV and make it comparable with the reduced form errors
date = names(2:end,1);                                   %get the datevector of the VAR

startlocationY_in_Y=find(strcmp(date,startdate));        %location of sample startdate in Y datevector
endlocationY_in_Y=find(strcmp(date,enddate));            %location of sample startdate in Y datevector
date = date(startlocationY_in_Y+p:endlocationY_in_Y,:);  %cut datevector of Y such that it corresponds to the time dates used in the VAR

           
entry_of_Y_in_IV = ismember(txt(:,1),date);               %this index measures if for the entry in the Y vector there is an entry in the IV vecto
%startlocationIV_in_Y = find(strcmp(date,txt(1))); 
entry_of_IV_in_Y = ismember(date,txt);                    %this index measures if for the entry in the IV vector there is an entry in the Y

%cut if necesarry
if ~isempty(cut1) || ~isempty(cut3)
%set to 0 the entrys in entry_of_Y_in_IV that correspond to the periods that we want to cut
cut1locationinIV = find(strcmp(txt,cut1)); 
cut2locationinIV = find(strcmp(txt,cut2)); 
cut3locationinIV = find(strcmp(txt,cut3)); 
cut4locationinIV = find(strcmp(txt,cut4)); 

if ~isempty(cut1locationinIV) && ~isempty(cut2locationinIV) %if both entrys are non empty
    entry_of_Y_in_IV(cut1locationinIV:cut2locationinIV) = 0; %set the entrys between the two dates in the logical vector to 0
end 
    
if ~isempty(cut3locationinIV) && ~isempty(cut4locationinIV) %if both entrys are non empty
    entry_of_Y_in_IV(cut3locationinIV:cut4locationinIV) = 0; %set the entrys between the two dates in the logical vector to 0
end 

%set to 0 the entrys in entry_of_IV_in_Y that correspond to the periods that we want to cut
cut1locationinY = find(strcmp(date,cut1)); 
cut2locationinY = find(strcmp(date,cut2)); 
cut3locationinY = find(strcmp(date,cut3)); 
cut4locationinY = find(strcmp(date,cut4));

if ~isempty(cut1locationinY) && ~isempty(cut2locationinY) %if both entrys are non empty
    entry_of_IV_in_Y(cut1locationinY:cut2locationinY) = 0; %set the entrys between the two dates in the logical vector to 0
end 
    
if ~isempty(cut3locationinY) && ~isempty(cut4locationinY) %if both entrys are non empty
    entry_of_IV_in_Y(cut3locationinY:cut4locationinY) = 0; %set the entrys between the two dates in the logical vector to 0
end 
%
end 

txt = txt(entry_of_Y_in_IV,:);     %cut datevector of IV such that it starts at the same time as Y
IV = IV(entry_of_Y_in_IV,:);       %cut IV such that it starts at the same time as Y    

date = date(entry_of_IV_in_Y,:);
EPSIV = EPSdraw(entry_of_IV_in_Y,:);

% %% Step 2: Cut periods from IV as in GK 
% 
% cut1location=find(strcmp(txt,cut1));
% cut2location=find(strcmp(txt,cut2)); %drop quarter from 2001q1-2001q3 (1 quarter)
% cut3location=find(strcmp(txt,cut3)); 
% cut4location=find(strcmp(txt,cut4)); %drop quarters from 2007q4-2009q2 (5 quarter)
% 
% %IV1 could be an empty vector
% IV1 = IV(1:cut1location,:);
% 
% %test if it is possible to get IV2
% if isempty(cut2location);
% IV2 = IV(1:cut3location,:);
% else 
% IV2 = IV(cut2location:cut3location,:);
% end
% %test if it is possible to get IV3
% if isempty(cut3location);
% IV2 = IV(1:end,:);
% else 
% IV2 = IV2;
% end
% %IV3 can also be an empty vector
% IV3 = IV(cut4location:end,:);
% IV = [IV1;IV2;IV3];
% 
% %%cut reduced form errors
% 
% cut1location=find(strcmp(date,cut1));
% cut2location=find(strcmp(date,cut2)); %drop quarter from 2001q1-2001q3 (1 quarter)
% cut3location=find(strcmp(date,cut3)); 
% cut4location=find(strcmp(date,cut4)); %drop quarters from 2007q4-2009q2 (5 quarter)
% 
% %this could be an empty vector
% EPSdrawcut1 = EPSdraw(1:cut1location,:);
% %test if it is possible to get EPSdrawcut2
% if isempty(cut2location);
% EPSdrawcut2 = EPSdraw(1:cut3location,:);
% else 
% EPSdrawcut2 = EPSdraw(cut2location:cut3location,:);
% end
% 
% if isempty(cut3location);
% EPSdrawcut2 = EPSdraw(1:end,:);
% else 
% EPSdrawcut2 = EPSdrawcut2;
% end
% 
% EPSdrawcut3 = EPSdraw(cut4location:endlocationIV_in_Y,:);
% EPSIV = [EPSdrawcut1;EPSdrawcut2;EPSdrawcut3];

end
