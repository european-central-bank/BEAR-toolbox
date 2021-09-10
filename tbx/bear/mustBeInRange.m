function mustBeInRange(prop, lower, upper)
% if verLessThan('MATLAB', '9.9')
%     mustBeInRange(prop, lower, upper)
% else
    mustBeGreaterThanOrEqual(prop, lower)
    mustBeLessThanOrEqual(prop, upper) 
% end
end