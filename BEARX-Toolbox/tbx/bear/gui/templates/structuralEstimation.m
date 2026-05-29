
%% Create a structural model 

structModel = Structural( ...
    reducedForm=redModel ...
    , identifier=ident ...
);
?PRINT_OBJECT?display(structModel);


%% Initialize and presample the structural model 

structModel.initialize();
info = structModel.presample(?NUM_SAMPLES?);
?PRINT_INFO?display(info);

?SAVE_MAT?save(fullfile(outputFolder, "structuralModel.mat"), "structModel");

