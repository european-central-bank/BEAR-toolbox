% Computes a rotation of the PC factors consistent with a recursive assumption with the policy instrument
% 
% Syntax:
% 
% Fr = facrot(F,Ffast,Fslow)
% 
% where:      F:      Unrestricted PC estimates (from all the dataset)
%             Ffast:  Factors assumed to be fast moving (e.g. policy instrument)
%             Fslow:  Proxy of the slow moving factors
%             
%             
% Bernanke, Boivin and Eliasz (2002)
% 12/17/02

function Fr = favar_facrot(F,Ffast,Fslow)

k1=size(Ffast,2);

b=favar_olssvd(F,[ones(size(Ffast,1),1) Ffast Fslow]);
Fr = F - Ffast*b(2:k1+1,:);
