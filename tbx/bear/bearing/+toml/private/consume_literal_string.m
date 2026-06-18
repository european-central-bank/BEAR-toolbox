function [val, str] = consume_literal_string(str, allow_multiline)
    if nargin < 2
        allow_multiline = false;
    end

    val = [];
    if allow_multiline && startsWith(str, "'''")
        str = str(4:end);
        if startsWith(str, newline)
            str = str(2:end);
        elseif startsWith(str, [char(0xD) newline])
            str = str(3:end);
        end
        [val, str] = terminate_string(str, true);

    elseif startsWith(str, "'")
        str = str(2:end);
        [val, str] = terminate_string(str, false);
    end
    % val = string(val);
end

function [content, rest] = terminate_string(str, is_multiline)
    for idx = 1:numel(str)
        c = str(idx);

        if is_multiline && startsWith(str(idx:end), "'''")
            if startsWith(str(idx:end), "'''''")
                content_end = idx + 1;
            elseif startsWith(str(idx:end), "''''")
                content_end = idx;
            else
                content_end = idx - 1;
            end
            content = str(1:content_end);
            rest = str(content_end+4:end);
            return

        elseif ~is_multiline && str(idx) == "'"
            content = str(1:idx-1);
            rest = str(idx+1:end);
            return

        elseif c == 9
            % tab is okay
        elseif c == 10 && is_multiline
            % line feeds are ok in multiline strings
        elseif c <= 31 || c == 127
            error('toml:ControlCharInString', ...
                sprintf('Encountered control character %d in string.', c));
        end
    end

    error('toml:UnterminatedString', ...
        ['Encountered a string without a closing quote: ', str]);
end
