function [g, badg] = sims_numgrad(fcn,x,varargin)
% function [g badg] = numgrad(fcn,x,varargin)
%
delta = 1e-6;
%delta=1e-2;
n=length(x);
tvec=delta*eye(n);
g=zeros(n,1);
%--------------------old way to deal with variable # of P's--------------
%tailstr = ')';
%stailstr = [];
%for i=nargin-2:-1:1
%   tailstr=[ ',P' num2str(i)  tailstr];
%   stailstr=[' P' num2str(i) stailstr];
%end
%f0 = eval([fcn '(x' tailstr]); % Is there a way not to do this?
%---------------------------------------------------------------^yes
f0 = feval(fcn,x,varargin{:});
%home
% sizex=size(x),sizetvec=size(tvec),x,    % Jinill on 9/6/95
badg=0;
for i=1:n
   scale=1; % originally 1
   % i,tveci=tvec(:,i)% ,plus=x+scale*tvec(:,i) % Jinill Kim on 9/6/95
   if size(x,1)>size(x,2)
      tvecv=tvec(i,:);
   else
      tvecv=tvec(:,i);
   end
   g0 = (feval(fcn,x+scale*tvecv', varargin{:}) - f0) ...
         /(scale*delta);
% -------------------------- special code to essentially quit here
   % absg0=abs(g0) % Jinill on 9/6/95
   if abs(g0)< 1e15
      g(i)=g0;
   else
      g(i)=0;
      badg=1;
      % return
      % can return here to save time if the gradient will never be
      % used when badg returns as true.
   end
end
