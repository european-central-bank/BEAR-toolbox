function [equilibrium,chvar,regimeperiods,Fpconfint,Fpconfint2,regime1,regime2,Dmatrix]=loadmaprior(endo,exo,startdate,pref,data_endo)

%This function reads the prior information for the Time Varying Equilibrium VAR mean-adjusted steady-state from the EXCEL spreadsheet 'mean adj prior'
%inputs:  - cell 'endo': list of endogenous variables of the model
%         - cell 'exo': list of exogenous variables of the model
%         - string 'datapath': user-supplied path to excel data spreadsheet
%outputs: - double 'equilibrium': Type of trend the user has specified: '1' for constant trend, '2' for linear trend and '3' for quadratic trend
%         - double 'chvar'
%         - cell 'regimeperiods'
%         - cell 'Fpconfint': prior mean confidence interval
%         - cell 'Fpconfint2': prior mean confidence interval
%         - cell 'regime 1': credibility interval for the steady state in regime 1
%         - cell 'regime 2': credibility interval for the steady state in regime 2
%         - double 'Dmatrix':

% identify the number of endogenous variables
numendo=size(endo,1);
% identify the number of exogenous variables (other than the constant)
numexo=size(exo,1);

MeanAdjPrior = pref.data.MeanAdjPrior;

% generate double array equilibrium
equilibrium = double(MeanAdjPrior.trend)';

% generate the cell Fpconfint for the first steady-state regime
Fpconfint = arrayfun(@str2num, MeanAdjPrior.("trend prior"), 'UniformOutput', false);

% generate the cell Fpconfint for the second steady-state regime
Fpconfint2 = arrayfun(@str2num, MeanAdjPrior.("trend prior 2"), 'UniformOutput', false);

% generate the cell regime 1 for the steady-state regime (if different from constant)
regime1 = cellfun(@strsplit, cellstr(MeanAdjPrior.("regime 1")), 'UniformOutput', false);

% generate the cell regime 2 for the second steady-state regime (if different from constant)
regime2=cell(numendo,numexo+1);

% generate array of regime changes
chvar = zeros(1, numendo);
% needs to be generalized (for now only first regime and first variable)
for ii=1:numendo
    if ~isempty(regime1{ii})
        chvar(ii)=1;
    end
end

% regime periods
indchvar=find(chvar==1);
if ~isempty(indchvar)
    regimeperiods=regime1{indchvar(1)};
else
    regimeperiods=[];
end

% Creation of the D matrix
T=length(data_endo(:,1));
Dmatrix = bear.TVEregimesDummy(startdate,regimeperiods,T);

% finally, record on Excel
pref.exporter.writeMeanAdjPrior(pref.data.MeanAdjPrior)