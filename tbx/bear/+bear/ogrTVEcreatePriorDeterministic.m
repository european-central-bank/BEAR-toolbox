function [m0, C0] = ogrTVEcreatePriorDeterministic(Y, X, p, bounds, trendCount, numRegimes,...
    regimes, estimStart, f)

counter = 1;
q = size(X, 2);
m0 = zeros(q, 1);
C0 = zeros(q, q);
nvar = size(Y, 2);

for i = 1:nvar

        nT = trendCount(i);
        nR = numRegimes(i);

        if nR == 1
            
            ix = counter:counter + nT - 1;
            
            if nT/nR == 1 && ~isempty(bounds{i}{1})
            
                bds = bounds{i}{1};
                lb = bds(1);
                ub = bds(2);
                m0(ix) = (lb + ub)/2;
                C0(ix, ix) = ((ub - lb) / (1.96*2))^2;

            else

                [m0(ix), C0(ix, ix)] = bear.OLSPriorTheta(Y(:,i), X(:, ix), f); 

            end
    
            counter = counter + nT;
    
        else

            for r = 1:nR

                ix = counter:counter + nT/nR - 1;
                reg = regimes(r);
                span = reg{1}{1};
                fh = datex.Backend.getFrequencyHandlerFromDatetime(span);
                timeVals = fh.serialFromDatetime(span) -  (fh.serialFromDatetime(estimStart) - p) + 1;
                timeVals = timeVals((timeVals > 0) & (timeVals <= size(Y, 1))); 

                if nT/nR == 1 && ~isempty(bounds{i}{r})
                    
                    bds = bounds{i}{r};
                    lb = bds(1);
                    ub = bds(2);
                    m0(ix) = (lb + ub)/2;
                    C0(ix, ix) = ((ub - lb) / (1.96*2))^2;
                
                else

                    [m0(ix), C0(ix, ix)] = bear.OLSPriorTheta(Y(timeVals, i), X(timeVals, ix), f);
                
                end

                counter = counter + nT/nR;

            end

        end
end