function q = quantile (x, p, dim, method)
if nargin < 2
    p = [];
end
if nargin < 3
    dim = 1;
end
if nargin < 4
    % Use Matlab compatiblity mode
    method = 5;
end
if (~ (isnumeric (x) || islogical (x)))
    error ('quantile: X must be a numeric vector or matrix');
end
if (isempty (p))
    p = [0.00 0.25, 0.50, 0.75, 1.00];
end
if (~ (isnumeric (p) && isvector (p)))
    error ('quantile: P must be a numeric vector');
end
if (~ (isscalar (dim) && dim == fix (dim)) ...
        || ~(1 <= dim && dim <= ndims (x)))
    error ('quantile: DIM must be an integer and a valid dimension');
end
% Set the permutation vector.
perm = 1:ndims (x);
perm(1) = dim;
perm(dim) = 1;
% Permute dim to the 1st index.
x = permute (x, perm);
% Save the size of the permuted x N-d array.
sx = size (x);
% Reshape to a 2-d array.
x = reshape (x, [sx(1), prod(sx(2:end))]);
% Calculate the quantiles.
q = octave__quantile__ (x, p, method);
% Return the shape to the original N-d array.
q = reshape (q, [numel(p), sx(2:end)]);
% Permute the 1st index back to dim.
q = ipermute (q, perm);
end % function

function inv = octave__quantile__ (x, p, method)
if (isinteger (x) || islogical (x))
    x = double (x);
end
% set shape of quantiles to column vector.
p = p(:);
% Save length and set shape of samples.
% FIXME: does sort guarantee that NaN's come at the end?
x = sort (x);
m = sum (~ isnan (x));
[xr, xc] = size (x);
% Initialize output values.
inv = Inf (class (x)) * (-(p < 0) + (p > 1));
inv = repmat (inv, 1, xc);
% Do the work.
k = find ((p >= 0) & (p <= 1));
if (any (k))
    n = length (k);
    p = p(k);
    % Special case of 1 row.
    if (xr == 1)
        inv(k,:) = repmat (x, n, 1);
        return;
    end
    
    % The column-distribution indices.
    pcd = kron(ones (n, 1), xr*(0:xc-1));
    mm = kron(ones (n, 1), m);
    switch (method)
        case {1, 2, 3}
            switch (method)
                case 1
                    p = max (ceil (kron(p, m)), 1);
                    inv(k,:) = x(p + pcd);
                    
                case 2
                    p = kron(p, m);
                    p_lr = max (ceil (p), 1);
                    p_rl = min (floor (p + 1), mm);
                    inv(k,:) = (x(p_lr + pcd) + x(p_rl + pcd))/2;
                    
                case 3
                    % Used by SAS, method PCTLDEF=2.
                    % http://support.sas.com/onlinedoc/913/getDoc/en/statug.hlp/stdize_sect14.htm
                    t = max (kron(p, m), 1);
                    t = roundb (t);
                    inv(k,:) = x(t + pcd);
            end
            
        otherwise
            switch (method)
                case 4
                    p = kron(p, m);
                    
                case 5
                    % Used by Matlab.
                    p = kron(p, m) + 0.5;
                    
                case 6
                    % Used by Minitab and SPSS.
                    p = kron(p, m+1);
                    
                case 7
                    % Used by S and R.
                    p = kron(p, m-1) + 1;
                    
                case 8
                    % Median unbiased.
                    p = kron(p, m+1/3) + 1/3;
                    
                case 9
                    % Approximately unbiased respecting order statistics.
                    p = kron(p, m+0.25) + 0.375;
                    
                otherwise
                    error ('quantile: Unknown METHOD, ''%d''', method);
            end
            
            % Duplicate single values.
            imm1 = (mm == 1);
            x(2,imm1) = x(1,imm1);
            
            % Interval indices.
            pi = max (min (floor (p), mm-1), 1);
            pr = max (min (p - pi, 1), 0);
            pi = pi + pcd;
            inv(k,:) = (1-pr) .* x(pi) + pr .* x(pi+1);
    end
end

end