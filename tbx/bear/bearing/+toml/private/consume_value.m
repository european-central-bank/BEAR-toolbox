function [val, str] = consume_value(str)
  str = trimstart(str);
  
  if isempty(str)
    error('toml:MissingValue', ...
      'Expected a value, found end of input.');

  elseif startsWith(str, '[')
    str = str(2:end);
    val = {};
    expecting_comma = false;
    while ~isempty(str)
      str = consume_comment(str);

      if startsWith(str, ']')
        break
      elseif expecting_comma
        str = expect(str, ',');
        expecting_comma = false;
      elseif startsWith(str, ',')
        error('toml:LeadingComma', ...
          'Comma found before in array without an element before it.');
      elseif ~startsWith(str, '#')
        [item, str] = consume_value(str);
        val{end+1} = item;
        expecting_comma = true;
      end
    end

    str = expect(str, ']');
    
    if numel(val) > 1 && ...
      (all(cellfun(@(e) isa(e, 'int64'), val)) || ...
        all(cellfun(@(e) isa(e, 'uint64'), val)) || ...
        all(cellfun(@(e) isa(e, 'double'), val))) && ...
        all(cellfun(@isscalar, val))
      val = cell2mat(val);
    end
    
  elseif startsWith(str, '{')
    str = str(2:end);
    val = containers.Map();
    first = true;
    while ~isempty(str)
      str = trimstart(str);
      if startsWith(str, '}')
        break
      end
      if ~first
        str = expect(str, ',');
      end
      [key_seq, str] = consume_key(str, '=');
      [item, str] = consume_value(str);
      val = set_nested_field(val, key_seq, item);
      first = false;
    end
    str = expect(str, '}');

  elseif startsWith(str, 'true')
    val = true;
    str = str(5:end);
  elseif startsWith(str, 'false')
    val = false;
    str = str(6:end);
    
  elseif startsWith(str, "'")
    [val, str] = consume_literal_string(str, true);
  elseif startsWith(str, '"')
    [val, str] = consume_basic_string(str, true);

  elseif startsWith(str, '+')
    [val, str] = consume_signed_value(str(2:end), 1);
  elseif startsWith(str, '-')
    [val, str] = consume_signed_value(str(2:end), -1);
    
  elseif startsWith(str, "inf")
    val = Inf;
    str = str(4:end);
  elseif startsWith(str, "nan")
    val = NaN;
    str = str(4:end);
    
  elseif startsWith(str, "0b")
    [digits, str] = consume_integer(str(3:end), 2);
    val = uint64(bin2dec(strrep(digits, '_', '')));
  elseif startsWith(str, "0o")
    [digits, str] = consume_integer(str(3:end), 8);
    val = uint64(base2dec(strrep(digits, '_', ''), 8));
  elseif startsWith(str, "0x")
    [digits, str] = consume_integer(str(3:end), 16);
    val = uint64(hex2dec(strrep(digits, '_', '')));
    
  elseif isstrprop(str(1), 'digit')
    [digits, str] = consume_integer(str, 10);
    
    % date
    if numel(digits) == 4 && startsWith(str, '-')
      [month, str] = consume_integer(str(2:end), 10);
  
      if numel(month) ~= 2 || month(1) > '1' || (month(1) == '1' && month(2) > '2') || all(month == '00')
        error('toml:InvalidMonth', 'Invalid month in date object.');
      end

      str = expect(str, '-');
      [day, str] = consume_integer(str, 10);
  
      if numel(day) ~= 2 || day(1) > '3' || (day(1) == '3' && day(2) > '1') || all(day == '00')
        error('toml:InvalidDay', 'Invalid day in date object.');
      end

      val = [digits '-' month '-' day];
      
      if startsWith(str, 'T') || startsWith(str, 't') || ...
         (strncmp(str, ' ', 1) && numel(str) > 1 && isstrprop(str(2), 'digit'))
        [time_str, str] = consume_time(str(2:end));
        val = [val 'T' time_str];
        
        if startsWith(str, 'Z') || startsWith(str, 'z')
          val = [val 'Z'];
          str = str(2:end);
        elseif startsWith(str, '+') || startsWith(str, '-')
          sign = str(1);
          [hour, str] = consume_integer(str(2:end), 10);
          str = expect(str, ':');
          [minute, str] = consume_integer(str, 10);
          val = [val sign hour ':' minute];
        end
      end

    % time
    elseif numel(digits) == 2 && startsWith(str, ':')
      [val, str] = consume_time(str, digits);

    % number
    else
      [val, str] = terminate_number(digits, str, 1);
    end

  else
    error('toml:UnexpectedValue', ...
      ['Encountered an unknown value: ', str]);
  end
end

function [num, str] = consume_signed_value(str, signum)
  if isempty(str)
    error('toml:SignWithNoValue', ...
      'Sign operator was found without a value.');
  elseif startsWith(str, '0b') || startsWith(str, '0o') || startsWith(str, '0x')
    error('toml:SignOnNonBase10', ...
      'Encountered a plus/minus sign on an unsigned int value.');
  elseif startsWith(str, '+') || startsWith(str, '-')
    error('toml:MultipleSigns', ...
      'Encountered multiple plus/minus signs in a row.');

  elseif startsWith(str, 'inf')
    num = Inf * signum;
    str = str(4:end);
  elseif startsWith(str, 'nan')
    num = NaN * signum;
    str = str(4:end);
  elseif isstrprop(str(1), 'digit')
    [digits, str] = consume_integer(str, 10);
    [num, str] = terminate_number(digits, str, signum);

  else
    error('toml:InvalidSign', ...
      'Encountered a plus/minus sign on a non-numeric value.');
  end
end

function [digits, str] = consume_integer(str, base)
  switch base
    case 2
      c_valid = @(c) c == '0' || c == '1';
    case 8
      c_valid = @(c) c >= '0' && c <= '7';
    case 10
      c_valid = @(c) c >= '0' && c <= '9';
    case 16
      c_valid = @(c) (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
  end

  digits = str;
  for idx = 1:numel(str)
    if startsWith(str(idx:end), '__')
      error('toml:DoubleUnderscore', ...
        'Double underscore encountered in numeric literal.');
    end

    if ~c_valid(str(idx)) && str(idx) ~= '_'
      digits = str(1:idx-1);
      break
    end
  end
  
  if startsWith(digits, '_')
    error('toml:LeadingUnderscore', ...
      'Numbers cannot have a leading underscore.');
  elseif endsWith(digits, '_')
    error('toml:TrailingUnderscore', ...
      'Numbers cannot have a trailing underscore.');
  elseif isempty(digits)
    error('toml:NoDigits', ...
      'Expected at least one digit.');
  end
  
  str = str(numel(digits)+1:end);
end

function [val, str] = consume_time(str, hour)
  if nargin < 2
    [hour, str] = consume_integer(str, 10);
  end
  
  if numel(hour) ~= 2 || hour(1) > '2' || (hour(1) == '2' && hour(2) > '3')
    error('toml:InvalidHour', 'Invalid hour in time object.');
  end

  str = expect(str, ':');
  [minute, str] = consume_integer(str, 10);

  if numel(minute) ~= 2 || minute(1) > '5'
    error('toml:InvalidMinute', 'Invalid minute in time object.');
  end

  str = expect(str, ':');
  [second, str] = consume_integer(str, 10);
  
  if numel(second) ~= 2 || second(1) > '6' || (second(1) == '6' && second(2) > '0')
    error('toml:InvalidSecond', 'Invalid second in time object.');
  end

  val = [hour ':' minute ':' second];
  
  if startsWith(str, '.')
    [sub_second, str] = consume_integer(str(2:end), 10);
    val = [val '.' sub_second(1:min(6, numel(sub_second)))];
  end
end

function [val, str] = terminate_number(digits, str, signum)
  if startsWith(digits, '0') && numel(digits) > 1
    error('toml:LeadingZero', ...
      'Encountered a numeric literal with a leading zero.');
  end

  has_fractional = false;
  has_exponent = false;

  % float with fractional
  if startsWith(str, '.')
    has_fractional = true;
    [frac_part, str] = consume_integer(str(2:end), 10);
    digits = [digits '.' frac_part];
  end

  % float with exponential
  if startsWith(str, 'e') || startsWith(str, 'E')
    has_exponent = true;
    str = str(2:end);
    digits = [digits 'e'];

    if startsWith(str, '+')
      str = str(2:end);
    elseif startsWith(str, '-')
      digits = [digits '-'];
      str = str(2:end);
    end

    [exp_part, str] = consume_integer(str, 10);
    digits = [digits exp_part];
  end

  val = str2num(strrep(digits, '_', '')) * signum;

  if ~has_fractional && ~has_exponent
    if numel(digits) > 1 && digits(1) == '0'
      error('toml:LeadingZero', ...
        'Encountered integer value with a leading zero.');
    end
    val = int64(val);
  end
end
