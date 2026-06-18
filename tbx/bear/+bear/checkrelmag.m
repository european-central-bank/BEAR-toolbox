function [success]=checkrelmag(stackedirfmatmagn,columnS,columnW,rowS,rowW,n,mperiods,nrelmagnresX)
 %compute structural impact matrix


maxperiods = max(mperiods); %%determine maximum of magnitude restriction periods 
not_fullfilled = 0; %%initiate not fullfilled vector
kk=1; %%iniate kk scalar (used for cutting IRFs)
for jj=1:maxperiods+1 %%loop over the periods where the magnitude restrictions apply                
IRF = stackedirfmatmagn(kk:nrelmagnresX*jj,1:n); %%extract the IRFs for this period 
kk=kk+nrelmagnresX;
for mr=1:length(columnS) %loop restrictions
    magrescheckS = (IRF(rowS(1,mr), columnS(1,mr))); %extract element of IRF that is supposed to be larger
    magrescheckW = (IRF(rowW(1,mr), columnW(1,mr))); %extract element of IRF that is supposed to be smaller    
    SignS = sign(magrescheckS); %now check the sign of "stronger" column, which is by construction identical to the restriction
    if SignS==1||SignS==0 %%if the value has positive sign or the values are equal (highly unlikely)
    check = magrescheckS < magrescheckW; %check = 1 (magnitude restrictions are not fullfilled) (Weaker < Stronger = not fullfilled)
    else %if the restriction imposed was such that magrescheckS (Stronger) is negative, the restriction is not fullfilled, if Stronger > Weaker  
    check = magrescheckS >  magrescheckW;  %check = 1 if stronger falls by less than weaker (weaker can be positive)
    end %end of check function
    not_fullfilled=not_fullfilled+check; 
end %end of loop over shocks
end %end of loop over periods
 


if not_fullfilled>0 %if magnitude restrictions are not fullfiled
    success=0; %set success to 0
else 
    success=1; %otherwhise set success to 0
end 
    
   