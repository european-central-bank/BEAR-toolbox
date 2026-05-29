%{
%
% bear6.runExcelUX  Run BEAR6 from an Excel UX file
%
%     bear6.runExcelUX(uxFilePath)
%
%
% Input arguments
% -----------------
%
% * `uxFilePath` [ string ] - Path to the Excel UX file.
%
% Output arguments
% -----------------
%
% * `modelR` [ model.ReducedForm ] - Reduced-form model.
%
% * `modelS` [ model.Structural ] - Structural model.
%
%
% Description
% ------------
%
% This function reads an Excel UX file, creates a reduced-form model, and
% then a structural model. The reduced-form model is estimated and
% presampled. The structural model is initialized and presampled.
%
%}


function info = runFromExcelUX(uxFilePath)

    arguments
        uxFilePath (1, 1) string = "BEAR6_UX.xlsx"
    end

    thisDir = fileparts(mfilename("fullpath"));
    origBearDir = fullfile(thisDir, "..", "bear");
    addpath(origBearDir);

    logger = bear6.Logger.INFO;

    logger.info("Reading ExcelUX" + uxFilePath)
    excelUX = bear6.ExcelUX(filePath=uxFilePath);
    logger.info("√ Done")

    logger.info("Reading input data")
    excelUX.readInputData();
    logger.info("√ Done")

    config = excelUX.Config;
    inputTbx = excelUX.InputDataTable;

    info = bear6.runFromConfig(config, inputTbx);

    info.config = config;
    info.inputTbx = inputTbx;

    if config.Tasks_SaveConfig{1}
        json.write(config, config.Tasks_SaveConfig{2});
    end

end%


% U = E * D
% cov U = E[ U' * U ] = E[ D' * E' * E * D ] = E[ D' * D ]


% % modelR.initialize(hist, estimSpan);
% s.initialize(hist, estimSpan);
% s.presample(100);
% 
% shockSpan = datex.span(datex.q(1,1), datex.q(10,4));
% 
% fevd = s.fevd(shockSpan);
% 
% shockTbx = s.simulateShocks(shockSpan);
% shockPctileTbx = tablex.apply(shockTbx, pctileFunc);
% tiledlayout(3, 3);
% time = 0 : numel(shockPctileTbx.Time)-1;
% for n = ["DOM_GDP", "DOM_CPI", "STN"]
%     for i = 1 : 3
%         shockName = s.Meta.ShockNames(i);
%         nexttile();
%         hold on
%         data = shockPctileTbx.(n)(:, :, i);
%         h = plot(time, data);
%         set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.3, 0.6, 0.6]);
%         title(n + " <-- " + shockName, interpreter="none");
%     end
% end
% 
% return
% 
% N = 10000;
% 
% disp("Presampling...")
% modelR.presample(N);
% modelR.Estimator.SampleCounter
% 
% amean = s.asymptoticMean();
% 
% endHist = estimSpan(end);
% % startForecast = datex.shift(endHist, -11);
% % endForecast = datex.shift(endHist, 0);
% startForecast = datex.shift(endHist, 1);
% endForecast = datex.shift(endHist, 100);
% forecastSpan = datex.span(startForecast, endForecast);
% 
% rng(0);
% disp("Forecasting...")
% fcast = s.forecast(hist, forecastSpan);
% clippedHist = tablex.clip(hist, endHist, endHist);
% 
% 
% fcastPctiles = tablex.apply(fcast, pctileFunc);
% fcastPctiles = tablex.merge(clippedHist, fcastPctiles);
% 
% fcastMean = tablex.apply(fcast, @(x) mean(x, 2));
% fcastMean = tablex.merge(clippedHist, fcastMean);
% 
% tiledlayout(2, 2);
% for n = ["DOM_GDP", "DOM_CPI", "STN"]
%     nexttile();
%     hold on
%     h = tablex.plot(fcastPctiles, n);
%     set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.5, 0.8, 0.8]);
%     h = tablex.plot(hist, n);
%     set(h, color="black", lineWidth=2);
% end
% 


