function [nrmmatrix] = normrnd(mu, sigma, sz1, sz2)
  if nargin<4
    sz2=1;
  end
  if nargin<3
    sz1=1;
  end
  nrmmatrix = mu + sigma*randn(sz1,sz2);
end


