% interinfo cells: required to save data when the back button is used with the interfaces
interinfo1={};
interinfo2={};
interinfo3={};
interinfo4={};
interinfo5={};
interinfo6={};
interinfo7={};
% panel scalar (non-model value): required to have the argument for interface 6, even if a non-panel model is selected 
if VARtype==4
else 
panel=10;
end
% signreslabels empty element: required to have the argument for IRF plots, even if sign restriction is not selected 
signreslabels=[];
% Units empty element: required to record estimation information on Excel even if the selected model is not a panel VAR
Units=[];
% blockexo empty element: required to have the code run properly for the BVAR model if block exogeneity is not selected
blockexo=[];
% forecast and IRFs empty elements: required for the display of panel results if forecast/IRFs are disactivated
forecast_record=[];
forecast_estimates=[];
gamma_estimates=[];
D_estimates=[];
% gamma empty elements: required for the display of stochastic volatility results if selected model is not random inertia
gamma_median=[];

