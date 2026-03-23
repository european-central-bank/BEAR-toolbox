function Phi = companion(B)

n = size(B, 2);
p = size(B, 1) / n;

I = eye(n*(p-1));
O = zeros(n*(p-1), n);

Phi = [B'; [I, O]];

end