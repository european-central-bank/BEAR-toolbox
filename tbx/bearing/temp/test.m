
clear

horizon = 10;
numT = horizon + 1;
numY = 3;

A = diag([0.8, -0.3, 1]);
B = [A; rand(11, numY)];
BB = repmat({B}, numT, 1);
D = rand(numY, numY);

Y = simulateFiniteVMA(BB, D, order=1);

