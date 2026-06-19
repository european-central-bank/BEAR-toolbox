function lj_panel_factor_dynamic_drawer(this, meta)

    numCountries = meta.numCountries;
    numEndog = meta.numEndog;
    numLags = meta.numLags;
    numExog = meta.numExog;
    
    %IRF periods
    IRFperiods = meta.IRFperiods;

    rho = this.Settings.rho;
    gama = this.Settings.gamma;
    EstimationSpan = this.EstimationSpan;

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

        % identify the final period for which we are creating a path
        finalp = numel(EstimationSpan);

        % read the input
        smpl = sampleStruct;
        B = smpl.B;
        sigma = smpl.sigma(:,finalp);
        thetabar = smpl.thetabar;
        Xi = smpl.Xi;
        theta=smpl.theta(:,finalp);
        % zeta=smpl.Zeta(finalp);

        % initiate the record draws
        As = cell(IRFperiods,1);
        Cs = cell(IRFperiods,1);

        % number of factors
        numFactors = size(thetabar,1);

        % reshape B
        B = reshape(B,numFactors,numFactors);
        % obtain its choleski factor as the square of each diagonal element
        cholB = diag(diag(B).^0.5);

        Sigma = reshape(sigma,numCountries*numEndog,numCountries*numEndog);

        % generate forecasts recursively
        % for each iteration jj, repeat the process for periods T+1 to T+IRFperiods
        for jj=1:IRFperiods

            % update theta
            % draw the vector of shocks eta
            eta=cholB*mvnrnd(zeros(numFactors,1),eye(numFactors))';
            % update theta from its AR process
            theta=(1-rho)*thetabar+rho*theta+eta;

            % reconstruct B matrix
            beta_temp = Xi*theta;
            B_draw = reshape(beta_temp,numCountries*numEndog*numLags+numExog,numCountries*numEndog);

            B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

            % reshaffle B_draw to map the proper order
            for ee = 1:numCountries
                for kk=1:numLags
                    B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B_draw((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
                end
            end

            % obtain A and C
            As{jj} = B_reshuffled(1:numCountries*numEndog*numLags,:);
            Cs{jj} = B_draw(numCountries*numEndog*numLags+1:end,:);
            % repeat until values are obtained for T+IRFperiods

        end

        draw = struct();
        draw.A = As;
        draw.C = Cs;
        draw.Sigma = Sigma;
      
    end

    function draw = unconditionalDrawer(sampleStruct, forecastStart,forecastHorizon)

        % identify the final period for which we are creating a path
        finalp = numel(EstimationSpan) - datex.diff(EstimationSpan(end), forecastStart) - 1;

        % read the input
        smpl = sampleStruct;
        B = smpl.B;
        sigmatilde = smpl.sigmatilde;
        thetabar = smpl.thetabar;
        Xi = smpl.Xi;
        theta = smpl.theta(:,finalp);
        phi = smpl.phi;
        zeta = smpl.Zeta(finalp);

        % initiate the record draws
        As = cell(forecastHorizon,1);
        Cs = cell(forecastHorizon,1);
        Sigmas = cell(forecastHorizon,1);

        % number of factors
        numFactors = size(thetabar,1);

        % reshape matrices
        B = reshape(...
                  B,...
                  numFactors,...
                  numFactors);

        sigmatilde = reshape(...
                    sigmatilde,...
                    numCountries*numEndog,...
                    numCountries*numEndog);

        % obtain its choleski factor as the square of each diagonal element
        cholB = diag(diag(B).^0.5);
        
        % generate forecasts recursively
        % for each iteration jj, repeat the process for periods T+1 to T+forecastHorizon
        for jj=1:forecastHorizon
            
            % update theta
            % draw the vector of shocks eta
            eta = cholB*mvnrnd(zeros(numFactors,1),eye(numFactors))';
            % update theta from its AR process
            theta = (1-rho)*thetabar + rho*theta + eta;

            % reconstruct B matrix
            beta_temp = Xi*theta;
            
            B_draw = reshape(...
                    beta_temp,...
                    numCountries*numEndog*numLags+numExog,...
                    numCountries*numEndog);
      
            B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

            % reshaffle B_draw to map the proper order
            for ee = 1:numCountries
                for kk = 1:numLags
                    B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B_draw((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
                end
            end

            % obtain A and C
            As{jj} = B_reshuffled(1:numCountries*numEndog*numLags,:);
            Cs{jj} = B_draw(numCountries*numEndog*numLags+1:end,:);
      
            % update sigma
            % draw the shock upsilon
            ups = normrnd(0,phi);
            % update zeta from its AR process
            zeta = gama*zeta+ups;
            % recover sigma
            sigma = exp(zeta)*sigmatilde;
      
            % recover sigma_t and draw the residuals
            Sigmas{jj} = sigma;
      
            % repeat until values are obtained for T+forecastHorizon
        end

        draw = struct();
        draw.A = As;
        draw.C = Cs;
        draw.Sigma = Sigmas;
    end

    function draw = historicalDrawer(sampleStruct)

        estimationSize = numel(EstimationSpan);

        % read the input
        smpl = sampleStruct;
        Xi = smpl.Xi;      
        sigmatilde = smpl.sigmatilde;  

        % reshape matrices
        sigmatilde = reshape(...
                    sigmatilde,...
                    numCountries*numEndog,...
                    numCountries*numEndog);

        % initiate the record draws
        As = cell(estimationSize,1);
        Cs = cell(estimationSize,1);
        Sigmas = cell(estimationSize,1);

        for tt = 1:estimationSize
            theta = smpl.theta(:,tt);
            zeta = smpl.Zeta(tt);

            % reconstruct B matrix
            beta_temp = Xi*theta;

            B_draw = reshape(...
                    beta_temp,...
                    numCountries*numEndog*numLags+numExog,...
                    numCountries*numEndog);
      
            B_reshuffled = zeros(numCountries*numEndog*numLags+numExog,numCountries*numEndog);

            % reshaffle B_draw to map the proper order
            for ee = 1:numCountries
                for kk = 1:numLags
                    B_reshuffled((ee-1)*numEndog*numLags+(kk-1)*numEndog+1:(ee-1)*numEndog*numLags+kk*numEndog,:) = B_draw((kk-1)*numCountries*numEndog+(ee-1)*numEndog+1:(kk-1)*numCountries*numEndog+ee*numEndog,:);
                end
            end

            % obtain A and C
            As{tt} = B_reshuffled(1:numCountries*numEndog*numLags,:);
            Cs{tt} = B_draw(numCountries*numEndog*numLags+1:end,:);

            % recover sigma
            sigma = exp(zeta)*sigmatilde;
      
            % recover sigma_t and draw the residuals
            Sigmas{tt} = sigma;
        end

        draw = struct();
        draw.A = As;
        draw.C = Cs;
        draw.Sigma = Sigmas;

    end

    this.IdentificationDrawer = @identificationDrawer;

    this.UnconditionalDrawer = @unconditionalDrawer;

    this.HistoricalDrawer = @historicalDrawer;

end