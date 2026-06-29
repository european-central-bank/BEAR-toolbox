function H = get_H(pars)

if isfield(pars, "Q")
    H = exp(pars.logLambda) .* pars.O.^2 .* pars.Q.^2;
elseif isfield(pars, "O")
    H = exp(pars.logLambda) .* pars.O.^2;
else
    H = exp(pars.logLambda);
end