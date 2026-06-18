%{
%
% Add a vector of ones to the left of the matrix X if the model has an
% intercept.
%
%}

function X = addInterceptWhenNeeded(X, hasIntercept)

    if ~hasIntercept
        return
    end

    X = [ones(size(X, 1), 1), X];

end%

