function O = randmixu1(p, lb, ub)

if1 = rand() < 1 - p;
u   = lb + rand()*(ub - lb);
O   = if1 + (1 - if1)*u;

end