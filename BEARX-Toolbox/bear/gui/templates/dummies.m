
%% Create ?TYPE? prior dummy observations 

% Create ?TYPE? prior dummy observations object
?VARIABLE_NAME? = dummies.?TYPE?( ...
    ?SETTINGS?
);

% Include the dummies in the cell array for use in the reduced-form model
dummyObjects{end+1} = ?VARIABLE_NAME?;

