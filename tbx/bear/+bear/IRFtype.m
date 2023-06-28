classdef IRFtype < uint8
    %IRFTYPE structural identification
    
    enumeration
        Reduced    (1) % none (reduced-form)
        Cholesky   (2) % Cholesky
        Triangular (3) % triangular factorisation
        Sign       (4) % sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions
        IV         (5) % IV identification
        IV_Sign    (6) % IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions
    end

end