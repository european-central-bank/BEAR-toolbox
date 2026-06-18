
classdef PresampleMixin < handle

    properties (Dependent)
        NumPresampled
    end


    methods
        function info = presample(this, numToPresample, options)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative}
                options.Progress (1, 1) logical = true
            end
            %
            this.resetPresampled(numToPresample);
            sampler = this.Sampler;
            if isempty(sampler)
                error("Sampler must be initialized before presampling.");
            end
            %
            progressMessage = sprintf("Presampling from posterior (%s) [%g]", this.Estimator.ShortClassName, numToPresample);
            progressBar = progress.Bar(progressMessage, numToPresample, active=options.Progress);
            initSampleCount = this.SampleCounter;
            initCandidateCount = this.CandidateCounter;
            for i = 1 : numToPresample
                sample = sampler();
                this.storePresampled(i, sample);
                progressBar.increment();
            end
            info = struct();
            info.SampleCount = double(this.SampleCounter - initSampleCount);
            info.CandidateCount = double(this.CandidateCounter - initCandidateCount);
            info.CandidateSuccessRate = numToPresample / info.CandidateCount;
            info.SampleSuccessRate = numToPresample / info.SampleCount;
        end%

        function out = get.NumPresampled(this)
            out = numel(this.Presampled);
        end%
    end

end

