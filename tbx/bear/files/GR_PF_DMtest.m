function result = GR_PF_DMtest(y1,bench,qn);

% INPUT: squared forecast errors from model (y1) and benchmark (bench); qn is bandwidth in NW
% OUTPUT: pval, the p-value of the test
% This is valid with NaN values

a=isfinite(y1); c=isfinite(bench);
ac=a+c; ac=find(ac==2);
y1=y1(ac); bench=bench(ac); 
kk1=size(y1,2);
teststatv=[]; pval=[]; 
for i1=1:kk1;
        P = length(y1);
%         y=(y1(:,i1)-true).^2;
        y=y1(:,i1)-bench;       % 2018_06_18: loss difference
        variance = nw(y,qn)/P;
        teststat = mean(y)/sqrt(variance); 
        teststatv = [teststatv; teststat]; 
        pval = [pval; 1-cdf('chi2',teststat^2,1)]; 
end;
result.teststat=teststatv;
result.pval=pval;

function result = nw(y,qn);
%input: y is a T*k vector and qn is the truncation lag
%output: the newey west HAC covariance estimator 
%Formulas are from Hayashi
[T,k]=size(y); ybar=ones(T,1)*((sum(y))/T);
dy=y-ybar;
G0=dy'*dy/T;
for j=1:qn-1;
   gamma=(dy(j+1:T,:)'*dy(1:T-j,:))./(T-1);
   G0=G0+(gamma+gamma').*(1-abs(j/qn));
end;
result=G0;