function lj_panel_bayesian_drawer(this, meta)

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
        % A - transformed matrix of parameters in front of transition variables
        % C - tranformed matrix of parameters in front of exogenous and constant
        % Sigma - transformed matrix of variance covariance of shocks
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

        beta_temp = reshape(...
                    beta,...
                    numEndog*numLags+numExog,...
                    numEndog...
                    );

        sigma_temp = reshape(...
                    sigma,...
                    numEndog,...
                    numEndog...
                    );

        a_temp = beta_temp(1:numEndog*numLags,:);

        c_temp = beta_temp(numEndog*numLags+1:end,:);

        % iterate over countries
        for ii = 1:numCountries
      
            % Pack in blocks
            A = blkdiag(A, a_temp);

            C = [C, c_temp];

            Sigma = blkdiag(Sigma,sigma_temp);

        end

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
        As = cell(forecastHorizon,1);
        Cs = cell(forecastHorizon,1);
        Sigmas  = cell(forecastHorizon,1);

        beta_temp = reshape(...
                    beta,...
                    numEndog*numLags+numExog,...
                    numEndog...
                    );

        sigma_temp = reshape(...
                    sigma,...
                    numEndog,...
                    numEndog...
                    );

        a_temp = beta_temp(1:numEndog*numLags,:);

        c_temp = beta_temp(numEndog*numLags+1:end,:);

        % iterate over countries
        for ii = 1:numCountries
      
            % Pack in blocks
            A = blkdiag(A, a_temp);

            C = [C, c_temp];

            Sigma = blkdiag(Sigma,sigma_temp);

        end

        % pack the output
        for tt = 1:forecastHorizon

            As{tt} = A;
            Cs{tt} = C;
            Sigmas{tt} = Sigma;

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