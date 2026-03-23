function valid = stable(~, ~, cand, ~, ~)

compB   = utils.companion(cand.Bdyn);
eigs    = eig(compB);
maxEig  = max(abs(eigs));
valid   = maxEig <= 1;

end