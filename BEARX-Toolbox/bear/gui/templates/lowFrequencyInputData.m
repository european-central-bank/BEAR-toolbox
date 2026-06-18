
%% Add low-frequency data

% Find out the base frequency of the model
baseFrequency = tablex.frequency(inputTbl);

% Load the input table with low-frequency data
lowFrequencyInputTbl = tablex.fromFile(?INPUT_DATA_PATH?);
?PRINT_TABLE?display(lowFrequencyInputTbl);

% Convert the low-frequency data to base-frequency data
lowFrequencyInputTbl = tablex.upsample( ...
    lowFrequencyInputTbl, ...
    baseFrequency, ...
    method="last" ...
);
?PRINT_TABLE?display(lowFrequencyInputTbl);

% Add the low-frequency data to the main input table. Use stratege="error" to
% throw an error if there are any duplicate names.
inputTbl = tablex.merge( ...
    inputTbl, ...
    lowFrequencyInputTbl, ...
    strategy="error" ...
);
?PRINT_TABLE?display(inputTbl);

