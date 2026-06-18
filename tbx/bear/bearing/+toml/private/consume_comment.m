function out = consume_comment(in)
  out = trimstart(in, true);

  if startsWith(out, '#')
    out = out(2:end);

    if ~isempty(out)
      for idx = 1:numel(out)
        c = out(idx);
        if c == newline || (c == char(0xD) && idx < numel(out) && out(idx+1) == newline)
          out = trimstart(out(idx:end), true);
          return
        elseif c == 9
          % tabs are okay
        elseif c <= 31 || c == 127
          error('toml:ControlCharInComment', ...
            sprintf('Encountered control character %d in comment.', c));
        end
      end

      out = '';
    end
  end
end