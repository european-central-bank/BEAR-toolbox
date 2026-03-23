%{
%
% Run model tasks from a configuration struct.
%
%}

function info = runFromConfig(config, inputTbx)

    startTime = datetime();

    rng(0);
    logger = bear6.Logger.INFO;



    logger.info("Creating reduced-form model...")

    metaR = config.createReducedFormMetaObject();

    dataH = model.DataHolder(metaR, inputTbx);

    estimatorR = estimator.(config.Estimator_Name)( ...
        metaR, ...
        config.Estimator_Settings{:} ...
    );

    dummy = dummies.Minnesota(exogenousLambda=30);

    modelR = model.ReducedForm( ...
        meta=metaR ...
        , dataHolder=dataH ...
        , estimator=estimatorR ...
        , dummies={dummy} ...
        , stabilityThreshold=Inf ...
    )

    logger.info("√ Done")



    metaS = config.createStructuralMetaObject(metaR);

    id = identifier.Cholesky();

    % 
    % id = identifier.Custom( ...
    %     exact=config.identifier.settings.exact, ...
    %     verifiable=config.identifier.settings.verifiable ...
    % );
    % 

    logger.info("Creating structural model...")

    modelS = model.Structural( ...
        meta=metaS ...
        , reducedForm=modelR ...
        , identifier=id ...
    );

    logger.info("√ Done")



    logger.info("Initializing structural model...")

    modelS.initialize();

    logger.info("√ Done")



    logger.info("Presampling structural model...")

    modelS.presample(config.ReducedFormMeta_NumDraws);

    logger.info("√ Done")



    logger.info("Starting task manager...")

    results = bear6.runTasks(config, modelS, logger);

    logger.info("√ Done")



    info = struct( ...
        startTime=startTime ...
        , endTime=datetime() ...
        , modelR=modelR ...
        , modelS=modelS ...
        , results=results ...
    );

end%

