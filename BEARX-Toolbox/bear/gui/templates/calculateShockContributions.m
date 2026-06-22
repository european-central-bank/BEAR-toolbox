
%% Calculate shock contributions to historical paths

% Calculate the contributions
contribTbl = structModel.calculateContributions();

% Condense the results to percentiles and flatten the 3D table to 2D table
contribPctTbl = tablex.apply(contribTbl, percentilesFunc);
contribPctTbl = tablex.flatten(contribPctTbl);

% Condense the results to median and flatten the 3D table to 2D table
contribMedTbl = tablex.apply(contribTbl, medianFunc);

