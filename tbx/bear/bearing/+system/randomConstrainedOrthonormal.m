
function Q = randomConstrainedOrthonormal(P, R)

    if nargin < 2
        R = [];
    elseif ~all(isnan(R(:)) | R(:) == 0)
        error("Invalid instant restrictions matrix; must only contain zeros or NaNs");
    end

    hasRestrictions = ~isempty(R) && any(R(:) == 0);

    numY = size(P, 1);

    if ~hasRestrictions

        X = randn(numY);
        [Q, R] = qr(X);
        Q = Q * diag(diag(sign(R)));

    else

        Q = nan(numY, numY);
        for i = 1 : numY
            inxZeros = R(:, i) == 0;
            Z = [P(inxZeros, :); transpose(Q(:, 1:i-1))];
            B = null(Z);
            v = randn(size(B, 2), 1);
            Q(:, i) = B * v / norm(v);
        end

        if any(isnan(Q(:)))
            error("Cannot find orthonormal matrix with the given instant zero restrictions");
        end

    end

end%

