
function D = candidateFromFactorConstrained(P, R, randFunc)

    if nargin < 3
        randFunc = @randn;
    end

    n = size(P, 1);

    % Transpose from row-oriented to column-oriented VAR systems
    % Row-oriented means time-t vectors of variables are row vectors
    Pt = transpose(P);
    Rt = transpose(R);

    % Calculations for column-oriented VAR system
    Qt = nan(n, n);

    % Pre-generate random numbers for all shocks
    X = randFunc([n, n]);

    for i = 1 : n
        inx = Rt(:, i) == 0;
        Ri = [Pt(inx, :); transpose(Qt(:, 1:i-1))];

        % Ni = null(Ri);
        % x = randn(size(Ni, 2), 1);
        % Qi = Ni * x / norm(x);

        x = X(:, i);

        if isempty(Ri)
            Qi = x / norm(x);
        else
            Ni = null(Ri);
            Ni_x = transpose(Ni) * x;
            Qi = Ni * (Ni_x / norm(Ni_x));
        end

        Qt(:, i) = Qi;
    end

    if any(isnan(Qt(:)))
        error("Cannot find orthonormal matrix with the given instant zero restrictions.");
    end

    Q = transpose(Qt);

    % Rotate the Cholesky factor matrix to get the candidate D matrix
    % Dt = Pt * Qt;

    D = Q * P;

    % Transpose back to row-oriented VAR systems
    % D = transpose(Dt);

end%

