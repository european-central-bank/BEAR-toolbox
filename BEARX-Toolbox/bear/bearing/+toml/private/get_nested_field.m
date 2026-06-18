% GET_NESTED_FIELD get a value from inside a Map
%
%   GET_NESTED_FIELD(obj, indx) follows the pointer `indx` into the
%   map or cell `obj`, and retrieves the value at the pointed
%   location, if it exists. If any member of the pointer chain does not
%   exist, it raises the error 'toml:NoSuchIndex'.
%
%   See also SET_NESTED_FIELD

function value = get_nested_field(obj, indx)
  % check for existence
  switch class(obj)
    case 'cell'
      if numel(obj) < indx{1}
        error('toml:NoSuchIndex', 'This index does not exist.')
      end
    case 'containers.Map'
      if ~isKey(obj, indx{1})
        error('toml:NoSuchIndex', 'This index does not exist.')
      end
  end

  % retrieve it
  value = get_item(obj, indx{1});
  % recurse if necessary
  if numel(indx) > 1
    value = get_nested_field(value, indx(2:end));
  end
end

function val = get_item(obj, indx2)
  switch class(obj)
    case 'cell'
      val = obj{indx2};
    case 'containers.Map'
      val = obj(indx2);
  end
end