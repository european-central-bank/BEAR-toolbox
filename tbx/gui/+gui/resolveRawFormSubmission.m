
function raw = resolveRawFormSubmission(submission)

    arguments
        submission (1, 1) string
    end

    LEAD_CHAR = "?";
    SEPARATOR = "&";
    ASSIGNMENT = "=";

    raw = struct();
    submission = strip(erase(submission, LEAD_CHAR));
    entries = reshape(string(split(submission, SEPARATOR)), 1, []);
    
    for n = entries
        pair = split(n, ASSIGNMENT);
        key = strip(pair(1));
        rawValue = strip(pair(2));
        if ~isfield(raw, key)
            raw.(key) = rawValue;
        else
            raw.(key) = [raw.(key), rawValue];
        end
    end

end%

