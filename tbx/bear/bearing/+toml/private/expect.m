function str = expect(str, token)
  if ~startsWith(str, token)
    error('toml:MissingToken', ...
      ['Expected token `', token, '` but did not find it.']);
  end
  str = str(numel(token)+1:end);
end
