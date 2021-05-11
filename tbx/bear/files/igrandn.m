function [x]=igrandn(a,b)


% first draw from gamma(a,1/b)
y=grandn(a,1/b);
% then convert to inverse gamma
x=1/y;
