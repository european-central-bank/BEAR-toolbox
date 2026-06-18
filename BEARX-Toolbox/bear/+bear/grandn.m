function [x]=grandn(a,b)



% function [x]=grandn(a,b)
% random number generator from the Gamma (a,b) distribution


% part 1: obtain a random number from Gamma(a,1)

if a>=1
x=gammadrawover1(a);
else
xtilde=gammadrawover1(a+1);
u=rand;
x=xtilde*u^(1/a);
end

% part 2: transform into a draw from G(a,b)
x=x*b;


% auxiliary nested function to draw a Gamma random number when argument 'a' is greater than or equal to 1
function x=gammadrawover1(a)
d=a-1/3;
c=1/((9*d)^0.5);
check=0;
   while check==0
   z=randn;
   u=rand;
   v=(1+c*z)^3;
      if (v>0 && log(u)<0.5*z^2+d-d*v+d*log(v))
      x=d*v;
      check=1;
      else
      check=0;
      end
   end
end


% declare end of general function
end