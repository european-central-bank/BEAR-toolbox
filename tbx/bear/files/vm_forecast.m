%==========================================================================
%              BAYESIAN ESTIMATION: FORECASTING                  
%==========================================================================

YYpred              = zeros(H+1,nv);     % forecasts from VAR
YYpred(1,:)         = YYact;
XXpred              = zeros(H+1,(nv)*nlags+1);
XXpred(:,end)       = ones(H+1,1);
XXpred(1,:)         = XXact;

%==========================================================================   
%          given posterior draw, draw #{H+1} random sequence
%==========================================================================

error_pred = zeros(H+1,nv);     
    
for h=1:H+1
        
    error_pred(h,:) = mvnrnd(zeros(nv,1), post_sig);         
        
end

%==========================================================================   
%       given posterior draw, iterate forward to construct forecasts
%==========================================================================
    
for h=2:H+1
        
    XXpred(h,nv+1:end-1) = XXpred(h-1,1:end-nv-1);
    XXpred(h,1:nv)       = YYpred(h-1,:);
    YYpred(h,:)          = (1-exc(h-1,:)).*(XXpred(h,:)*post_phi+error_pred(h,:)) + ...
        exc(h-1,:).*YYcond(h-1,:);
    
end

YYpred1     = YYpred;
YYpred      = YYpred(2:end,:);

