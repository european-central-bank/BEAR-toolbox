function out = trimstart(s, allow_newline)
  if nargin < 2
    allow_newline = false;
  end
  
  for idx = 1:numel(s)
    if isspace(s(idx))
      if s(idx) == newline && ~allow_newline
        error('toml:UnexpectedLineBreak', ...
          "Encountered a newline where it wasn't expected.");
      elseif s(idx) == char(0xD) && ~startsWith(s(idx+1:end), newline)
        error('toml:CarriageReturnWithoutNewline', ...
          "Encountered a carriage return without a corresponding newline.");
      end
    else
      out = s(idx:end);
      return
    end
  end

  out = '';
end
