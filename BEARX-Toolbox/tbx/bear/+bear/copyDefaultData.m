function copyDefaultData(name)

arguments
    name (1,1) string = "data.xlsx"
end

copyfile(fullfile(bearroot, 'default_bear_data.xlsx'), name)