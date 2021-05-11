function result=RS_DF_Test(rdata1,rtrue1,grid1,hstep,el,bootMC)

% Construct PITs
pit = [];
T = size(rdata1,1);

for i = 1:T

    ygrid = grid1;
    rdata = rdata1(i,1:length(ygrid))';

    fitdens1 = fitdist(ygrid, 'normal', 'frequency',round(rdata));

    z1 = normcdf(rtrue1(i,:),fitdens1.mu, fitdens1.sigma);

    pit = [pit; z1];
end
    

% Construct Histogram of PITS
bin  = 10;
m    = length(pit);
rvec = (0:0.001:1);
hs   = histc(pit,0:1/bin:1);

result.rvec      = rvec;
result.m         = m;
result.bin       = bin;
result.histogram = hs;


% Test Statistic
for r = 1:size(rvec,2)
    ecdf(:,r) = mean(pit < rvec(:,r));
end
result.ecdf=ecdf;


% Critical Values
if hstep == 1
    results1CS = RS_DF_rstest(pit);
    table1 = results1CS(:,1:2);
elseif hstep >= 1
%     table1 = RS_DF_CVfinalbootstrap(el,bootMC,pit,rvec); % 20.9.2018
    table1 = RS_DF_CVfinalbootstrapInoue(el,bootMC,pit,rvec);
end

result.output=round(table1.*1000)./1000;
