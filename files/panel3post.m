function [omegabarb betabar]=panel3post(h,Xbar,y,lambda1,bbar,sigeps)


% compute omegabarb
term1=((1/lambda1)*speye(h)+Xbar'*Xbar);
omegabarb=sigeps*(term1\speye(h));

% compute betabar
term2=(Xbar'*y+(1/lambda1)*bbar);
betabar=term1\term2;



























































