function l =  loglik_proxy_given_data(IVcut, EPScut, hsigma, Q, bet, signu)

Dinv = Q'/hsigma; %Compute A0inv(:,1);


z = IVcut' - bet*Dinv*EPScut';

l = sum(log(mvnpdf(z', [], signu.^2)));

end

