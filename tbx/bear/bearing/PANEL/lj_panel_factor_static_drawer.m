function lj_panel_factor_static_drawer(this, meta)
    
    numCountries = meta.numCountries;
    numEndog     = meta.numEndog;
    numLags      = meta.numLags;
    numExog      = meta.numExog;
    
    %IRF periods
    IRFperiods = meta.IRFperiods;

    function draw = identificationDrawer(sampleStruct)

        % input 
        % smpl - one sample (gibbs sampling) that contains:
        % smpl.beta - one sample of beta gibbs
        % smpl.sigma - one sample of sigma gibbs

        % output
        % draw.A - transformed matrix of parameters in front of transition variables
        % draw.C - tranformed matrix of parameters in front of exogenous and constant
        % draw.Sigma - transformed matrix of variance covariance of shocks
        % Y = (L)Y*A + X*C + eps

        smpl = sampleStruct;
        beta = smpl.beta;
        sigma = smpl.sigma;
        
        % initialization
        A = [];
        C = [];

        Sigma = [];

        % initialize the output
        As = cell(IRFperiods,1);
        Cs = cell(IRFperiods,1);

        k = numCountries*numEndog*numLags+numExog;

        B = reshape(beta,k, numCountries*numEndog);

        B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

        % reshaffle B_draw to map the proper order
        for ee = 1:numCountries
            for kk=1:numLags
                B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
            end
        end

        A = B_reshuffled(1:numEndog*numLags*numCountries,:);
        C = B(numEndog*numLags*numCountries+1:end,:);
        
        Sigma = reshape(sigma,numEndog*numCountries,numEndog*numCountries);

        % pack the output
        for tt = 1:IRFperiods

            As{tt} = A;
            Cs{tt} = C;

        end

        draw = struct();
        draw.A = As;
        draw.C = Cs;
        draw.Sigma = Sigma;

    end

    function draw = unconditionalDrawer(sampleStruct, forecastStart,forecastHorizon)

        smpl = sampleStruct;
        beta = smpl.beta;
        sigma = smpl.sigma;
        
        % initialization
        A = [];
        C = [];

        Sigma = [];

        % initialize the output
        As =cell(forecastHorizon,1);
        Cs = cell(forecastHorizon,1);
        Sigmas  = cell(forecastHorizon,1);

        k = numCountries*numEndog*numLags+numExog;

        B = reshape(beta,k, numCountries*numEndog);

        B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

        % reshaffle B_draw to map the proper order
        for ee = 1:numCountries
            for kk=1:numLags
                B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
            end
        end

        A = B_reshuffled(1:numEndog*numLags*numCountries,:);
        C = B(numEndog*numLags*numCountries+1:end,:);
        
        Sigma = reshape(sigma,numEndog*numCountries,numEndog*numCountries);

        % pack the output
        for tt = 1:forecastHorizon

            As{tt} = A;
            Cs{tt} = C;
            Sigmas{tt} = drawIdent.Sigma;

        end

        draw = struct();
        draw.A = As;
        draw.C = Cs;
        draw.Sigma = Sigmas;

    end

    % return function calls
    this.IdentificationDrawer = @identificationDrawer;

    this.UnconditionalDrawer = @unconditionalDrawer;

end