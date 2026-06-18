function result = is_octave()
  persistent cache_val;

  if isempty (cache_val)
    cache_val = (exist ("OCTAVE_VERSION", "builtin") > 0);
  end

  result = cache_val;
end
