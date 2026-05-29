function Q = randorth(n, P, R)

Q = nan(n);

if nargin == 1

	X = randn(n);
	[Q, R] = qr(X);
	Q = Q * diag(diag(sign(R)));

else

	for i = 1:n

		zind = R(:, i) == 0;
		B = null([P(zind, :); Q(:, 1:i-1)']);
		v = randn(size(B, 2), 1);
		Q(:, i) = B * v / norm(v);

  end

end