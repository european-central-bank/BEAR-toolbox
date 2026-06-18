function [keys, str] = consume_key(str, next_token)
  keys = {};

  while true
    [key, str] = consume_single_key(str);
    keys{end+1} = key;
    str = trimstart(str);

    if startsWith(str, '.')
      str = trimstart(str(2:end));
    else
      break
    end
  end

  str = expect(str, next_token);
end

function [key, rest] = consume_single_key(str)
  str = trimstart(str);
  if startsWith(str, '"')
    [key, rest] = consume_basic_string(str);

  elseif startsWith(str, "'")
    [key, rest] = consume_literal_string(str);

  else
    key_end = numel(str);
    for idx = 1:key_end
      if ~is_key_char(str(idx))
        key_end = idx;
        break
      end
    end
    key = str(1:key_end-1);
    rest = str(key_end:end);
    
    if isempty(key)
      error('toml:EmptyBareKey', ...
        'Bare (unquoted) keys cannot be empty.');
    end
  end
end
