function [score]=crps(ygibbs,yo)





% compute first the dimension of the gibbs sampler draws (normally, 'It' iterations minus 'Bu' discarded burn iterations)
It_Bu=size(ygibbs,1);

% compute the first summation term
sum1=sum(abs(ygibbs-repmat(yo,It_Bu,1)));

% compute the second summation term
 temp=abs(repmat(ygibbs,1,It_Bu)-repmat(ygibbs',It_Bu,1));
 sum2=sum(temp(:));

% eventually compute the score
score=(1/It_Bu)*sum1-(1/(2*It_Bu^2))*sum2;










