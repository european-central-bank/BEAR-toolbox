function [y] = favar_transx(x,tcode)
%% Transform  x
% Stock & Watson (2016)
%   Return Series with same dimension and corresponding dates
%   Missing values where not calculated
%   -- Tcodes:
%            1 Level
%            2 First Difference
%            3 Second Difference
%            4 Log-Level
%            5 Log-First-Difference
%            6 Log-Second-Difference
% 		     7 First difference of percent change: (x(t)/x(t-1)-1)-(x(t-1)/x(t-2)-1), FRED-MD data (McCracken & Ng)
% 

small=1.0e-06;

n=size(x,1);
y=NaN*zeros(n,1);

 if tcode==1
  y=x;

 elseif tcode==2
  y(2:n)=x(2:n)-x(1:n-1);

 elseif tcode==3
  y(3:n)=x(3:n)-2*x(2:n-1)+x(1:n-2);

 elseif tcode==4
  if min(x) < small
   y=NaN;
  else
   x=log(x);
   y=x;
  end
 
 elseif tcode==5
  if min(x) < small
   y = NaN;
  else
   x=log(x);
   y(2:n)=x(2:n)-x(1:n-1);
  end
 
 elseif tcode==6
  if min(x) < small
   y = NaN;
  else
   x=log(x);
   y(3:n)=x(3:n)-2*x(2:n-1)+x(1:n-2);
  end
  
  elseif tcode==7
  if min(x) < small
   y = NaN;
  else
   y1(2:n)=(x(2:n)-x(1:n-1))./x(1:n-1);
   y(3:n)=y1(3:n)-y1(2:n-1);
  end
 else
  y = NaN;
 end