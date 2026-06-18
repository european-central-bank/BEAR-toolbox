function y = randind(indMax, numSample, weights)

arguments
  indMax
  numSample
  weights (1, :) double {mustBeNonnegative} = ones(1, indMax)
end

prob    = weights / sum(weights);
cumProb = [0, cumsum(prob)];

x = rand(1, numSample);
y = nan(size(x));
for i = 1 : indMax
  ind = cumProb(i) < x & x <= cumProb(i+1);
  y(ind) = i;
end

end