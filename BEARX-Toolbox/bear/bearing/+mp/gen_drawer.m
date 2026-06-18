function [outUnconditionalDrawer, outIdentifierDrawer] = adapterDrawer(this, meta)
        
        %sizes 
        numEn = meta.NumEndogenousColumns;
        numARows = numEn * meta.Order;
        numBRows = numARows + meta.NumExogenousColumns;

        %IRF periods
        IRFperiods = meta.IRFperiods;


    function [drawStruct] = unconditionalDrawer(sampleStruct, forecastHorizon )
    
        %draw beta, omega and sigma and F from their posterior distributions
        
        % draw beta
        beta = sampleStruct.beta;
        B = reshape(beta, numBRows, numEn); 
        As = B(1:numARows, :);
        Cs = B(numARows + 1:end, :);
        Sigma = reshape(sampleStruct.sigma, numEn, numEn);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:forecastHorizon
           drawStruct.As{jj, 1}(:, :) = As;
           drawStruct.Cs{jj, 1}(:, :) = Cs; 
           drawStruct.Sigmas{jj, 1}(:, :) = Sigma; 
        end
    end

    function [drawStruct] = identifierDrawer(sampleStruct)
    
        %draw beta, omega from their posterior distribution  
        % draw beta
        beta = sampleStruct.beta;
        B = reshape(beta, numBRows, numEn);                        
        As = B(1:numARows, :);
        Cs = B(numARows + 1:end, :);

        % then generate forecasts recursively
        % for each iteration ii, repeat the process for periods T+1 to T+h
        for jj = 1:IRFperiods    
               drawStruct.As{jj,1}(:, :) = As;
               drawStruct.Cs{jj,1}(:, :) = Cs; 
        end
       
        drawStruct.Sigma = reshape(sampleStruct.sigma, numEn, numEn);   
    end

    outUnconditionalDrawer = @unconditionalDrawer;
    outIdentifierDrawer = @identifierDrawer;

end