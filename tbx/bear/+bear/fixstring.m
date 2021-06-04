function [fixedstring]=fixstring(string)




% several purposes: 
% - clear possible initial spaces
% - turn possible multiple spaces into single spaces
% - replace irregular spaces (e.g. tab space) with regular spaces
% - suppress possible final spaces
% this guarantees good behaviour of the code





% the first task is to eliminate any possible initial space
% initiate the elimination process
initspace=1;
while initspace==1
% check whether the first character is a space
  % first check that the string is not empty; if it is empty, just return it as an empty string
   if size(string,2)==0
   string='';
   % and indicate there is no more initial space to clear
   initspace=0;
   % if the string is non empty
   elseif size(string,2)>=1
      % check for the first character: if it is a space, clear it
      % if the string contains exactly one character, turn it to empty
      if isspace(string(1,1)) && size(string,2)==1
      string='';  
      % and indicate there is no more initial space to clear
      initspace=0;
      % if the string contains more than one character, clear only the first one
      % and do not turn initspace to 0; this indicates there may still remain initial spaces to clear
      elseif isspace(string(1,1)) && size(string,2)>=1
      string=string(1,2:end);
      % finally, if the first character is not a space
      elseif ~isspace(string(1,1))
      % then don't change the string, but turn initspace to 0 to inidicate there is no more initial space to clear
      initspace=0;
      end
   end
end
      



% once this is done, it is possible to start repairing the string
% initiate the fixed string
fixedstring='';

% count the total number of characters in the string (including spaces)
nchar=size(string,2);

% initiate the count of spaces
spaces=0;

% loop over those characters
for ii=1:nchar
   % check if the character is a space
   % if it is a space
   if isspace(string(1,ii))
   % add one to the count of spaces
   spaces=spaces+1;
   % and check if spaces is larger than 1; 
      % if yes, the previous character was also a space; then don't copy it as it is repeated space
      if spaces>1
      % if spaces is 1 at most, include a normal space in the string
      elseif spaces<=1
      fixedstring=[fixedstring ' '];
      end
   % if the character is not a space, then copy it normally and reset the space count to 0
   else
   fixedstring=[fixedstring string(1,ii)];
   spaces=0;
   end
end


% this new repaired string may now have a final space (no more than one as repeated spaces have been suppressed) that we want to clear
% this will however depend on the size of the repaired string
% if the new string is empty, just leave it as an empty string
if size(fixedstring,2)==0
fixedstring='';
% if it is not empty
else
   % if the final character is not a space, just leave the string as it is (don't do anything)
   if ~isspace(fixedstring(1,end))
   % if the final character is a space, take it away
   elseif isspace(fixedstring(1,end))
      % if there is only one character in fixedstring, turn it into an empty string
      if size(fixedstring,2)==1
      fixedstring='';
      % if there is more than one character, just take away the final one
      elseif size(fixedstring,2)>1
      fixedstring=fixedstring(1,1:end-1);
      end
   end
end

