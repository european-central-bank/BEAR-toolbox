function s = unvech(v, inclDiag, byRows)

arguments
  v
  inclDiag  (1, 1) logical = true
  byRows    (1, 1) logical = false
end

l = length(v);
n = (sqrt(1 + 8*l) - 1) / 2;

if ~inclDiag
  n = n + 1;
end

ind = 1:n;

s = zeros(n);

if byRows
  if inclDiag
    matInd = ind' <= ind;
  else
    matInd = ind' < ind;
    s = eye(n);
  end
else
  if inclDiag
    matInd = ind' >= ind;
  else
    matInd = ind' > ind;
    s = eye(n);
  end
end

s(matInd) = v;

if byRows
  s = s';
end

end