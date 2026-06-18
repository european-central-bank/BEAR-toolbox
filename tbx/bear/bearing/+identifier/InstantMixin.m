
classdef (Abstract) InstantMixin < handle

    methods (Abstract)
        choleskator = getCholeskator(this)
        candidator = getCandidator(this)
    end


    methods
        function initializeSampler(this, modelS)
            %[
            meta = modelS.Meta;
            estimator = modelS.ReducedForm.Estimator;
            redSampler = estimator.Sampler;
            numSeparableUnits = meta.NumSeparableUnits;

            % TODO: Refactor
            try
                hasCrossUnitVariationInSigma = estimator.HasCrossUnitVariationInSigma;
            catch
                hasCrossUnitVariationInSigma = false;
            end

            identificationDrawer = estimator.IdentificationDrawer;
            choleskator = this.getCholeskator();
            candidator = this.getCandidator();


            function sample = structSampler()
                sample = redSampler();
                draw = identificationDrawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                % TODO: Refactor and get rid of an if statement

                if hasCrossUnitVariationInSigma
                    Sigma = draw.Sigma;
                    Sigma = (Sigma + pagetranspose(Sigma)) / 2;
                    D = cell(1, numSeparableUnits);
                    for unit = 1 : numSeparableUnits
                        if unit > 1 && isequal(Sigma(:,:,unit), Sigma(:,:,1))
                            D{unit} = D{1};
                            continue
                        end
                        P = choleskator(Sigma(:,:,unit));
                        D{unit} = candidator(P);
                    end
                    D = cat(3, D{:});
                else
                    Sigma = draw.Sigma(:, :, 1);
                    Sigma = (Sigma + transpose(Sigma)) / 2;
                    P = choleskator(Sigma);
                    D = candidator(P);
                    if numSeparableUnits > 1
                        D = repmat(D, 1, 1, numSeparableUnits);
                    end
                end

                sample.IdentificationDraw = draw;
                sample.D = D;
                this.CandidateCounter = this.CandidateCounter + 1;
            end%
            %
            %
            this.Sampler = @structSampler;
            %]
        end%
    end

end

