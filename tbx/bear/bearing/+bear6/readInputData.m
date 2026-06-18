
function dataTable = readInputData(dataConfig)

    INPUT_DATA_READER = struct( ...
        csv=@tablex.fromCsv ...
    );

    dataTable = [];

    reader = INPUT_DATA_READER.(lower(dataConfig.format));
    dataTable = reader(dataConfig.source);

end%

