function Sigma = randiwish(cholInvScale, df, cholInvFlag, invFlag)

arguments
  cholInvScale
  df
  cholInvFlag   (1,1) logical = true
  invFlag       (1,1) logical = true
end

nVars = size(cholInvScale, 1);

X = randn(nVars, df);
if cholInvFlag    
  A = cholInvScale * X;
end
AAt = A*A';

if invFlag
  Sigma = inv(AAt);
end

end