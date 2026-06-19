%% Setting up opt structure
fileName = "nw_favar_opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opts      = jsondecode(str);

data_endo_table = readtable("data_endo_favar.csv");
% data_exo = readmatrix("+nw_favar/data_exo.csv");
data_exo = [];

informationnames = readcell("informationnames.csv","FileType", "text");
informationdata = readmatrix("informationdata.csv","FileType", "text");


fileName = "favar.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
favar    = jsondecode(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[sample, favar] = nw_favar.get_draws_new(data_endo_table,data_exo,informationdata,informationnames,opts,favar);