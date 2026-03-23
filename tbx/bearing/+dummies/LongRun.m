
classdef (CaseInsensitiveProperties=true) LongRun ...
    < dummies.Base

    properties
        % Lambda  Overall tightness of prior dummies
        Lambda (1, 1) double = 1 % lambda8 in BEAR5

        Table table = table.empty()

        Matrix (:, :) double = []
    end


    methods

        function this = LongRun(varargin)
            if nargin == 0
                return
            end
            this.update(varargin{:});
        end%


        function update(this, options)
            arguments
                this
                options.Lambda (1, 1) double = 1
                options.FileName (1, 1) string = ""
                options.Table table = table.empty()
                options.Matrix (:, :) double = []
            end
            %
            this.Lambda = options.Lambda;
            %
            if options.FileName ~= ""
                this.Table = tablex.readtable(options.FileName);
                return
            end
            if ~isempty(options.Table)
                this.Table = options.Table;
                return
            end
            if ~isempty(options.Matrix)
                this.Matrix = options.Matrix;
                return
            end
        end%


        function H = prepareMatrix(this)
            if ~isempty(this.Table)
                H = this.Table{:,:};
            elseif ~isempty(this.Matrix)
                H = this.Matrix;
            else
                error("Long-run constraint matrix has not been specified.");
            end
            H = double(H);
            H(isnan(H)) = 0;
        end%


        function checkMatrix(this, H, numY)
            if ~isequal(size(H), [numY, numY])
                error("Long-run constraint matrix must be square with size equal to the number of endogenous variables (%g).", numY);
            end
            rankH = rank(H);
            sizeH = size(H, 1);
            if rankH < sizeH
                error("Long-run prior matrix is singular: rank=%g, size=%g.", rankH, sizeH);
            end
        end%


        function dummiesYLX = generate(this, meta, longYX)
            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY] = longYX{:};
            initY = longY(1:order, :);
            %
            H = this.prepareMatrix();
            this.checkMatrix(H, numY);
            invH = inv(H);
            meanY = transpose(mean(initY, 1));
            dummiesY = [];
            for ii = 1 : numY
                add = (H(ii, :) * meanY / lambda) * invH(:, ii);
                dummiesY = [dummiesY, add];
            end
            dummiesL = repmat(dummiesY, 1, order);
            dummiesX = zeros(numY, numX);
            dummiesLX = [dummiesL, dummiesX];
            %
            dummiesYLX = {dummiesY, dummiesLX};
        end%
    end

end

