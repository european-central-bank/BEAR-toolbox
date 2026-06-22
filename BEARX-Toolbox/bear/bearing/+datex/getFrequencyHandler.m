
function out = getFrequencyHandler(freq)

    arguments
        freq (1, 1) double
    end

    handlers = datex.allFrequencyHandlers();

    for i = 1 : numel(handlers)
        if handlers{i}.Frequency == freq
            out = handlers{i};
            return
        end
    end

    out = NaN;

end%

