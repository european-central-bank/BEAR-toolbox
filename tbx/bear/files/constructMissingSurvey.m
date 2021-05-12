function zData = constructMissingSurvey(zDataTrue, Gdraw, PsiAll, dataValues)

%PsiAll=PsiDraw_prop;
% Initialize
Ppsi = dataValues.Ppsi; %load selection matrix for the states (local mean), where survey data is available
PsiZ = PsiAll * Ppsi'; %only use those variables
[T, Mz] = size(zDataTrue);
zData = zDataTrue;

% for each survey variable
for iM = 1:Mz
    
    % determine time of incoming survey data
    Tz              = find(isfinite(zData(:,iM)),1,'first');
    iNaNs           = find(isnan(zData(:,iM)));
    iNaNs(iNaNs<Tz) = [];
    
    zDataDraw_i     = PsiZ(:, iM) + sqrt(Gdraw(:,iM)).*randn(T,1);
    % fill missing values (to previous values)
    zData(iNaNs,iM) = zDataDraw_i(iNaNs);
end

end
