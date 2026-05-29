function [success]=checksignres_favar(Sj,fj)
 % check here for success only

% if there are no sign restrictions on this shock, don't do anything and automatically count as success
if isempty(Sj)
success=1;
% if there are sign restriction on this shock, check them
else
% check if the restrictions hold
   % if yes, count as success
   if all(Sj*fj>=0)
   success=1;
%    % if the restrictions do not hold, there may still be a possibility by switching the sign of qj
%    elseif all(Sj*(-fj)>=0)
%    qj=-qj;
%    success=1;
   % else, if there is no way to have qj succesful, count as a fail
   else
   success=0;
   end
end


















