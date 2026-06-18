function [val, str] = consume_basic_string(str, allow_multiline)
  if nargin < 2
    allow_multiline = false;
  end

  val = [];
  if allow_multiline && startsWith(str, '"""')
    str = str(4:end);
    while true
      if startsWith(str, newline)
        str = str(2:end);
      elseif startsWith(str, [char(0xD) newline])
        str = str(3:end);
      else
        break
      end
    end
    [val, str] = terminate_string(str, true);

  elseif startsWith(str, '"')
    [val, str] = terminate_string(str(2:end), false);
  end

  % val = string(val);
end

function [content, str] = terminate_string(str, is_multiline)
  pieces = {};
  while true
    if isempty(str)
      error('toml:EndOfInput', 'Did not expect input to end.');

    elseif startsWith(str, '\')
      str = str(2:end);
      if isempty(str)
        error('toml:EndOfInput', 'Did not expect input to end.');

      elseif is_multiline && ~any_non_whitespace_chars_before_newline(str)
        while isspace(str(1))
          str = str(2:end);
          if isempty(str)
            error('toml:EndOfInput', 'Did not expect input to end.');
          end
        end

      else
        c = str(1);
        str = str(2:end);
        switch c
          case { '\', '"' }
            pieces{end+1} = c;
          case { 'b', 't', 'r', 'f', 'n' }
            pieces{end+1} = sprintf(['\' c]);
          case { 'u', 'U' }
            num_digits = 4;
            if c == 'U'
              num_digits = 8;
            end
            [code_point, str] = get_hex_digits(str, num_digits);
            code_point = uint32(hex2dec(code_point));
            % still run this even in matlab, to validate code point
            utf8_validated = utf8ify(code_point);
            if is_octave()
              pieces{end+1} = utf8_validated;
            elseif code_point <= uint32(0xFFFF)
              pieces{end+1} = char(code_point);
            else
              pieces{end+1} = char([bitshift(code_point, -16), bitand(uint32(0xFFFF), code_point)]);
            end
          otherwise
            error('toml:ReservedEscapeSequence', ...
              ['Encountered reserved escape sequence `\\', c, '` in string.']);
        end
      end
    elseif is_multiline && startsWith(str, '"""')
      if startsWith(str, '"""""')
        pieces{end+1} = '""';
        str = str(6:end);
      elseif startsWith(str, '""""')
        pieces{end+1} = '"';
        str = str(5:end);
      else
        str = str(4:end);
      end
      break
    elseif ~is_multiline && startsWith(str, '"')
      str = str(2:end);
      break
    elseif ~is_multiline && startsWith(str, newline)
      error('toml:LineBreakInBasicString', ...
        'Encountered a line break in a single-line string.');
    elseif str(1) <= 8 || (str(1) >= 11 && str(1) <= 31) || str(1) == 127
      error('toml:ControlCharInBasicString', ...
        sprintf('Encountered control character `%d` in a string.', str(1)));
    else
      pieces{end+1} = str(1);
      str = str(2:end);
    end
  end
  
  content = strjoin(pieces, '');
end

function are_there = any_non_whitespace_chars_before_newline(str)
  are_there = false;
  for idx = 1:numel(str)
    if str(idx) == newline || startsWith(str(idx:end), [char(0xD) newline])
      return
    elseif ~isspace(str(idx))
      are_there = true;
      return
    end
  end
end

function [digits, str] = get_hex_digits(str, count)
  digits = '';
  for idx = 1:numel(str)
    c = str(idx);
    if ~((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')) || idx == count+1
      digits = str(1:idx-1);
      str = str(idx:end);
      break
    end
  end

  if numel(digits) ~= count
    error('toml:InvalidUnicode', ...
      sprintf('Expected %d hex digits for escape, got %d', count, numel(digits)));
  end
end

function str = utf8ify(num)
  continued = @(num) bitor(uint32(0b10000000), bitand(uint32(0b00111111), num));

  % check that it is scalar
  if (num > 0xD7FF && num < 0xE000) || num > 0x10FFFF
    error('toml:NonScalarCodepoint', ...
      ['Non-scalar Unicode codepoint: `' sprintf('%X', num) '`']);
  end

  if num < 0x80
    str = char(num);
  elseif num < 0x800
    num = uint32(num);
    str = char([ ...
      bitor(uint32(0b11000000), bitshift(num, -6)), ...
      continued(num) ...
    ]);
  elseif num < 0x10000
    num = uint32(num);
    str = char([ ...
      bitor(uint32(0b11100000), bitshift(num, -12)), ...
      continued(bitshift(num, -6)), ...
      continued(num) ...
    ]);
  elseif num < 0x110000
    num = uint32(num);
    str = char([ ...
      bitor(uint32(0b11110000), bitshift(num, -18)), ...
      continued(bitshift(num, -12)), ...
      continued(bitshift(num, -6)), ...
      continued(num) ...
    ]);
  else
    error('toml:InvalidCodePoint', ...
      'Encountered a Unicode code point that is not in the valid range.');
  end
end
