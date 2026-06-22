function [success,qj,okay,kk]=checksignres_inc_other_shocks(qj,fj,Scell,okay,IRFt,n)

if IRFt==4
kk=1;
elseif IRFt==6
kk=2; % first IV shock is okay
end

check=0;
while check==0
        Sjcheck=Scell{1,kk};
        if isempty(Sjcheck) && okay(kk,1)==0 %if we get a not yet filled unrestricted column 
            okay(kk,1)=1; %switch okay vector to 1
            success=1;
            check=1;
            qj=qj;
        elseif ~isempty(Sjcheck) && all(Sjcheck*fj>=0) && okay(kk,1)==0 
            okay(kk,1)=1; %switch okay vector to 1
            success=1;
            check=1;
            qj=qj;
        elseif ~isempty(Sjcheck) && all(Sjcheck*(-fj)>=0) && okay(kk,1)==0 
            okay(kk,1)=1; %switch okay vector to 1
            success=1;
            check=1;
            qj=-qj;
         else
            check=0;
            kk=kk+1;
       end
         if kk>n %if kk > n stop the loop as it failed 
            success=0;
            check=1;
         end
end

