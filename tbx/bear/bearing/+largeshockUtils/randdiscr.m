function y = randdiscr(weights, numSample)

arguments
  weights     (1, :) double {mustBeNonnegative}
  numSample
end

prob    = weights / sum(weights);
edges   = [0, cumsum(prob)];

x = rand(1, numSample);
[~, ~, y] = histcounts(x, edges);

end