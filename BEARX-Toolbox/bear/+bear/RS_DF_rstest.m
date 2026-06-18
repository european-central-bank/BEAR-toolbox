function results  = RS_DF_rstest(z);

rvec = (0:0.001:1);
P = size(z,1);

cumcumz = [];    
for r = rvec
    cumcumz = [cumcumz (z<r)-r];
end

v = sum(cumcumz,1)/sqrt(P);

Qv = []; Qvabs = [];
for rs = 1:size(rvec,2);
    Qv = [Qv; v(1,rs)'*v(1,rs)]; 
    Qvabs = [Qvabs; abs(v(1,rs)')];
end 

Kv = max(Qvabs);
CVMv = mean(Qv);

results(1,1) = Kv;
results(1,2) = CVMv;