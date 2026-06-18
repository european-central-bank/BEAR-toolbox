
% function [draw]=iwdraw(S,alpha)
% creates a random draw from an inverse Wishart distribution with scale matrix S and degrees of freedom alpha
% inputs:  - matrix 'C': stabilized lowe Chol factor of scale matrix for sigma
%          - integer 'alpha': degrees of freedom for sigma
% outputs: - matrix 'draw': random draw from the inverse Wishart distribution



function draw = iwdraw2(C, alpha, fixed)

    if nargin < 3
        fixed = false;
    end

    numY = size(C, 1);

    if fixed
        Zt_Z = alpha * eye(numY);
    else
        % draw the matrix Z of alpha multivariate standard normal vectors
        Z = randn(alpha, numY);
        Zt_Z = Z' * Z;
    end

    % obtain the draw
    draw = (C / Zt_Z) * C';

end%

