function [success]=checkmagres(Mj,Mlj,Muj,fj)





% if there are no magnitude restrictions on this shock, don't do anything and automatically count as success
if isempty(Mj)
success=1;
% if there are sign restriction on this shock, check them
else
   % check if the restrictions hold
   % if yes, count as success
   if all((Mj*fj-Mlj).*(Muj-Mj*fj)>=0)
   success=1;
   % else, count as a fail
   else
   success=0;
   end
end
















