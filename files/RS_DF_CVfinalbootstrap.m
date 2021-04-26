function result = RS_DF_CVfinalbootstrap(el, bootMC, pit, rvec)

Kv = zeros(bootMC,1); CVMv = zeros(bootMC,1);  

P = size(pit,1);
size_rvec = length(rvec);

for bootrep = 1:bootMC
    z = 1/sqrt(el)*randn(P-el+1,1);
    emp_cdf = (repmat(pit,1,size_rvec) <= repmat(rvec,P,1));
    
    K_star = zeros(1,size_rvec);
    for j = 1:P-el+1
        K_star = K_star + (P^(-1/2)*z(j,1)).*(sum(emp_cdf(j:j+el-1,:) - repmat(rvec,el,1),1));
    end
    
    KSv(bootrep,1) = max(abs(K_star'));
    CVMv(bootrep,1) = mean(K_star'.^2);
end

KSv = sort(KSv,'ascend');       cvKv = KSv(bootMC*0.95);
CVMv = sort(CVMv,'ascend');     cvMv = CVMv(bootMC*0.95); 

result = [cvKv cvMv];