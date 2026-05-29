function outTable = FAVARforecast(this, forecastSpan, options)
    arguments
        this
        forecastSpan (1, :) datetime
        %
        options.StochasticResiduals (1, 1) logical = true
        options.IncludeInitial (1, 1) logical = true
    end
    %
    meta = this.Meta;
    forecastStart = forecastSpan(1);
    forecastEnd = forecastSpan(end);
    shortForecastSpan = datex.span(forecastStart, forecastEnd);
    this.checkForecastSpan(forecastStart, forecastEnd);
    forecastStartIndex = datex.diff(forecastStart, meta.ShortStart) + 1;
    %
    forecastHorizon = numel(shortForecastSpan);
    longForecastSpan = datex.longSpanFromShortSpan(shortForecastSpan, meta.Order);
    %
    longYXZ = this.getSomeYXZ(longForecastSpan);
    %
    numPresampled = this.NumPresampled;
    %
    % Multiple-unit output data will be always captured as flat
    numY = meta.NumEndogenousNames+meta.NumFactorNames;
    Y0 = nan(meta.Order, numY, numPresampled);
    Y = nan(forecastHorizon, numY, numPresampled);
    U = nan(forecastHorizon, numY, numPresampled);
    %
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        [y, init, u] = forecast4S( this,...
            sample, longYXZ, forecastStartIndex, forecastHorizon ...
            , stochasticResiduals=options.StochasticResiduals ...
            , hasIntercept=meta.HasIntercept ...
            , order=meta.Order ...
            );
        % Flatten (unfold) multiple-unit data back to 2D
        U(:, :, i) = u(:, :);
        Y(:, :, i) = y(:, :);
        Y0(:, :, i) = init(:, :);
    end
    %
    outSpan = shortForecastSpan;
    if options.IncludeInitial
        Y = [Y0; Y];
        U = [nan(meta.Order, size(U, 2), numPresampled); U];
        outSpan = longForecastSpan;
    end
    %
    endoNames = [meta.FactorNames meta.EndogenousNames ];
    outNames = [endoNames, strcat("resid_", endoNames)];
    outTable = tablex.fromNumericArray([Y, U], outNames, outSpan, variantDim=3);
end%


function [y, init, u] = forecast4S(this, sample, longYXZ, forecastStartIndex, ...
    forecastHorizon, options)
    arguments
        this
        sample
        longYXZ (1, 3) cell
        forecastStartIndex (1, 1) double
        forecastHorizon (1, 1) double
        options.StochasticResiduals (1, 1) logical
        options.HasIntercept (1, 1) logical
        options.Order (1, 1) double {mustBeInteger, mustBePositive}
    end
    %
    draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
    % Multiple-unit data are 3D
    u = system.generateResiduals( ...
        draw.Sigma ...
        , stochasticResiduals=options.StochasticResiduals ...
        );
    [y, init] = forecastFAVAR( ...
        draw.A, draw.C, sample.FY, longYXZ, u ...
        , hasIntercept=options.HasIntercept ...
        , order=options.Order ...
        );
end%

function [Y, initY] = forecastFAVAR(A, C, FY, longYXZ, U, options)

    arguments
        A (:, 1) cell
        C (:, 1) cell
        FY
        longYXZ (1, 3) cell
        U (:, :, :) double
        options.HasIntercept % (1, 1) logical
        options.Order % (1, 1) double {mustBeInteger, mustBePositive}
    end

    hasIntercept = options.HasIntercept;
    order = options.Order;

    horizon = numel(A);
    [~, longX, ~] = longYXZ{:};
    numY = size(A{1}, 2);
    numUnits = size(A{1}, 3);

    X = longX(order+1:end, :);
    X = system.addInterceptWhenNeeded(X, hasIntercept);

    initY = FY(1:order, :, :);

    if numel(C) ~= horizon || size(U, 1) ~= horizon || size(X, 1) ~= horizon
        error("Invalid dimensions of input data");
    end

    Y = cell(1, numUnits);
    for n = 1 : numUnits
        Y{n} = nan(horizon, numY);
        lt = system.reshapeInit(initY(:, :, n));
        for t = 1 : horizon
            yt = lt * A{t}(:, :, n) + X(t, :) * C{t}(:, :, n) + U(t, :, n);
            lt = [yt, lt(:, 1:end-numY)];
            Y{n}(t, :) = yt;
        end
    end
    Y = cat(3, Y{:});

end%