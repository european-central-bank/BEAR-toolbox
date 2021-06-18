classdef IRFtype < uint8
    %IRFTYPE structural identification
    
    enumeration
        None        (1) % None
        Cholesky    (2) % Cholesky
        Triangular  (3) % triangular factorisation
        Sign        (4) % sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions
        IV          (5) % IV identification
        IV_and_Sign (6) % IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions
    end

end