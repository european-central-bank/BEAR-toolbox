% SET_NESTED_FIELD set a value somewhere in a Map
%
%   SET_NESTED_FIELD(obj, indx, val) sets the location denoted by `indx`
%   (a pointer sequence into `obj`) in `obj` equal to `val`, and returns
%   a modified copy of `obj`.
%
%   See also GET_NESTED_FIELD

function obj = set_nested_field(obj, indx, val)
  if length(indx) == 1
    if isa(obj, 'containers.Map')
      if isKey(obj, indx{:})
        switch class(obj(indx{:}))
          case 'containers.Map'
            if ~isa(val, 'containers.Map')
              error('toml:RedefinedTable', ...
                    'Tables cannot be redefined.')
            elseif val.Count == 0
              return
            end
          case 'cell'
            if iscell(val) && ...
              ( ...
                isempty(val) || ...
                ( ...
                  isempty(val{1}) || ( ...
                    isa(val{1}, 'containers.Map') && isempty(keys(val{1})) ...
                  ) || ( ...
                    iscell(val{1}) && (isempty(val{1}{1}) || ( ...
                      isa(val{1}{1}, 'containers.Map') && isempty(keys(val{1}{1})) ...
                    )) ...
                  ) ...
                ) ...
              )
              error('toml:RedefinedArray', ...
                    'Arrays cannot be redefined.')
            elseif isa(val, 'containers.Map')
              error('toml:NameCollision', ...
                    'Table definitions cannot override existing arrays.')
            end
          otherwise
            if isa(val, 'containers.Map')
              error('toml:RedefinedTable', ...
                    'Tables cannot be redefined.')
            end
            error('toml:RedefinedKey', ...
                  'Keys cannot be redefined.')
        end
      end

      % annoying bug in octave requires assigning empty key twice
      if isempty(indx{1}) && is_octave()
        try
          obj(indx{1}) = val;
        catch
        end
      end

      obj(indx{1}) = val;
    elseif iscell(obj)
      if ischar(indx{1})
        obj{end}(indx{1}) = val;
      else
        obj{indx{1}} = val;
      end
    end
  else
    try
      orig = get_nested_field(obj, indx(1));
    catch
      if ischar(indx{2})
        orig = containers.Map();
      else
        orig = {};
      end
    end
    new = set_nested_field(orig, indx(2:end), val);
    obj = set_nested_field(obj, indx(1), new);
  end
end