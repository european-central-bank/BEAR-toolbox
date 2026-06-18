% DECODE convert TOML to native MATLAB datatypes
%
%   DECODE(toml_str) returns the MATLAB representation of the
%   TOML-formatted data in `toml_str`. If it is invalid TOML, an
%   appropriate exception will be raised.
%
%   See also TOML.READ

function obj_out = decode(toml_str)
  obj_out = containers.Map();
  location_stack = {};
  array_locations = {};
  table_locations = {};
  immutable_locations = {};

  while true
    toml_str = consume_comment(toml_str);
    if isempty(toml_str)
      break
    end

    if startsWith(toml_str, '[[') % array
      toml_str = toml_str(3:end);
      [location_stack, toml_str] = consume_key(toml_str, ']]');
      location_stack = adjust_key_stack(obj_out, location_stack);

      check_stack_for_conflict(immutable_locations, location_stack, 1);
      try
        existing_val = get_nested_field(obj_out, location_stack);
        location_stack{end+1} = length(existing_val) + 1;
        obj_out = set_nested_field(obj_out, location_stack, containers.Map());
      catch e
        array_locations{end+1} = location_stack;
        location_stack{end+1} = 1;
        obj_out = set_nested_field(obj_out, location_stack, containers.Map());
      end

      toml_str = expect_line_break_or_comment_or_eof(toml_str);

    elseif startsWith(toml_str, '[') % table
      toml_str = toml_str(2:end);
      [location_stack, toml_str] = consume_key(toml_str, ']');
      location_stack = adjust_key_stack(obj_out, location_stack);

      check_stack_for_conflict(immutable_locations, location_stack, 1);
      check_stack_for_conflict(array_locations, location_stack);
      check_stack_for_conflict(table_locations, location_stack);
      table_locations{end+1} = location_stack;

      obj_out = set_nested_field(obj_out, location_stack, containers.Map());
      toml_str = expect_line_break_or_comment_or_eof(toml_str);

    elseif startsWith(toml_str, '"') || startsWith(toml_str, "'") || is_key_char(toml_str(1)) % key / value pair
      [key_seq, toml_str] = consume_key(toml_str, '=');
      [value_fix, toml_str] = consume_value(toml_str);
      this_location = [location_stack key_seq];

      check_stack_for_conflict(immutable_locations, this_location);
      check_stack_for_conflict(array_locations, this_location, numel(location_stack) + 1);
      check_stack_for_conflict(table_locations, this_location, numel(location_stack) + 1);
      for depth = 1:numel(key_seq)
        immutable_locations{end+1} = [location_stack, key_seq(1:depth)];
      end

      obj_out = set_nested_field(obj_out, this_location, value_fix);
      toml_str = expect_line_break_or_comment_or_eof(toml_str);
      
    elseif ~startsWith(toml_str, '#')
      error('toml:UnexpectedStatement', ...
        ['Found unrecognized statement: ' toml_str]);
    end
  end
end

function check_stack_for_conflict(stacks, current, min_depth)
  if nargin < 3
    min_depth = numel(current);
  end

  for idx = 1:numel(stacks)
    for depth = min_depth:numel(current)
      if isequal(stacks{idx}, current(1:depth))
        error('toml:NameCollision', ...
          ['Assigning to existing location `' strjoin(cellfun(@num2str, current, 'uniformoutput', false), '.') '`']);
      end
    end
  end
end
