
%{
%
% Generate random residuals from a multivariate normal distribution with
% zero mean and the specified covariance matrix for each period, or return a
% matrix of zeros.
%
%}

function U = generateResiduals(Sigma, options)

    arguments
        Sigma (:, 1) cell
        options.StochasticResiduals (1, 1) logical = true
    end

    numPeriods = numel(Sigma);
    numU = size(Sigma{1}, 1);
    numPages = size(Sigma{1}, 3);

    U = zeros(numPeriods, numU, numPages);
    if ~options.StochasticResiduals
        return
    end

    for t = 1 : numPeriods
        for i = 1 : numPages
            Sigma_ti = Sigma{t}(:, :, i);
            Sigma_ti = (Sigma_ti + Sigma_ti') / 2;
            P = cholcov(Sigma_ti);
            U(t, :, i) = randn(1, numU) * P;
        end
    end

end%

