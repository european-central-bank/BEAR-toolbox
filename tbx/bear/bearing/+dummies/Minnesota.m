
classdef (CaseInsensitiveProperties=true) Minnesota ...
    < dummies.Base

    properties
        % Lambda  Tightness of the overall Minnesota prior
        Lambda (1, 1) double = 0.1 % lambda1

        % LagDecay  Decay factor for lagged coefficients
        LagDecay (1, 1) double = 1 % lambda3

        % Autoregression  Autoregressive coefficients for each endogenous variable
        Autoregression (:, :) double = 0.8 % ar

        % Exogenous  True or false for including exogenous variables in dummy observations
        Exogenous (:, :) logical = false %priorexogenous

        % ExogenousLambda  Tightness of exogenous dummy observations
        ExogenousLambda (:, :) double = 100 % lambda4, exogenous tightness
    end


    methods

        function this = Minnesota(varargin)
            if nargin == 0
                return
            end
            this.update(varargin{:});
        end%


        function update(this, options)
            arguments
                this
                options.Lambda (1, 1) double = 0.1
                options.LagDecay (1, 1) double = 1
                options.Autoregression (:, :) double = 0.8
                options.ExogenousLambda (:, :) double = 100
                options.Exogenous (:, :) logical = false
            end
            this.Lambda = options.Lambda;
            this.LagDecay = options.LagDecay;
            this.Autoregression = options.Autoregression;
            this.ExogenousLambda = options.ExogenousLambda;
            this.Exogenous = options.Exogenous;
        end%


        function dummiesYLX = generate(this, meta, longYX)
            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;

            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numX);
            end
            if isscalar(this.ExogenousLambda)
                this.ExogenousLambda = repmat(this.ExogenousLambda, numY, numX);
            end
            if isscalar(this.Autoregression)
                this.Autoregression = repmat(this.Autoregression, numY, 1);
            end

            order = meta.Order;
            const = meta.HasIntercept;

            lambda1 = this.Lambda;
            lambda3 = this.LagDecay;
            lambda4 = this.ExogenousLambda;
            ar = this.Autoregression;
            priorexo = this.Exogenous;

            [longY] = longYX{:};

            %variance from univariate OLS for priors
            arvar = bear.arloop(longY, const, order, numY);

            dummiesY = [
                diag(ar(1:numY, 1) .* arvar / lambda1)
                zeros(numY * (order-1), numY)
                (priorexo ./ (lambda1 .* lambda4))'
                diag(arvar)
            ];

            Jp = diag((1 : order) .^ lambda3);

            if numX ~= 0
                dummiesLX = [
                    kron(Jp, diag(arvar/lambda1)), zeros(numY*order, numX)
                    zeros(numX, numY*order), diag(1./(lambda1*lambda4(1, :)))
                    zeros(numY, numY*order), zeros(numY, numX)
                ];
            else
                dummiesLX = [
                    kron(Jp, diag(arvar/lambda1))
                    zeros(numY, numY*order)
                ];
            end

            dummiesYLX = {dummiesY, dummiesLX};
        end%

    end

end

