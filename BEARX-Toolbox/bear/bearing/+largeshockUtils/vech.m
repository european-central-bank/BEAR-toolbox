function v = vech(s, inclDiag, byRows)

arguments
  s
  inclDiag  (1, 1) logical = true
  byRows    (1, 1) logical = false
end

n     = size(s, 1);
ind   = 1:n;

if byRows

  s = s';

  if inclDiag
    matInd = ind' <= ind;
  else
    matInd = ind' < ind;
  end

else

  if inclDiag
    matInd = ind' >= ind;
  else
    matInd = ind' > ind;
  end

end

v = s(matInd);

end