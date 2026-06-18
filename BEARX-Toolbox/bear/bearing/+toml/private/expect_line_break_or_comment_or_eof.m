function str = expect_line_break_or_comment_or_eof(str)
  for idx = 1:numel(str)
    c = str(idx);
    if c == newline || c == 0xD || ~isspace(c)
      str = str(idx:end);
      break
    end
  end

  if isempty(str)
    % cool
  elseif startsWith(str, '#')
    str = consume_comment(str);
  elseif startsWith(str, newline)
    str = str(2:end);
  elseif startsWith(str, [char(0xD) newline])
    str = str(3:end);
  else
    error('toml:ExpectedLineBreak', ...
      ['Expected newline (LF or CRLF) but found `' str '`']);
  end
end
