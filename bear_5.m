%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX           %
%                                                                          %
%    Authors:                                                              %
%    Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                       %
%    Björn van Roye  (bvanroye@bloomberg.net)                              %
%                                                                          %
%    Version 5.0                                                           %
%                                                                          %
%    The updated version 5 of BEAR has benefitted from contributions from  %
%    Boris Blagov, Marius Schulte and Ben Schumann.                        %
%                                                                          %
%    This version builds-upon previous versions where Romain Legrand was   %
%    instrumental in developing BEAR.                                      %
%                                                                          %
%    The authors are grateful to the following people for valuable input   %
%    and advice which contributed to improve the quality of the toolbox:   %
%    Paolo Bonomolo, Mirco Balatti, Marta Banbura, Niccolo Battistini,     %
%	 Gabriel Bobeica, Martin Bruns, Fabio Canova, Matteo Ciccarelli,       %
%    Marek Jarocinski, Michele Lenza, Francesca Loria, Mirela Miescu,      %
%    Gary Koop, Chiara Osbat, Giorgio Primiceri, Martino Ricci,            %
%    Michal Rubaszek, Barbara Rossi, Fabian Schupp, Peter Welz and         % 
%    Hugo Vega de la Cruz.                                                 %
%                                                                          %
%    These programmes are the responsibilities of the authors and not of   %
%    the ECB and all errors and ommissions remain those of the authors.    %
%                                                                          %
%    Using the BEAR toolbox implies acceptance of the End User Licence     %
%    Agreement and appropriate acknowledgement should be made.             %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
warning off;
clc

%keep
runapp=1;

% Start BEAR with Graphical User Interface
cd files

waitfor(interface);

cd ../

% % now load the settings that we specified in the interface, set other
% % default options and translate them to the BEAR conventions
if runapp==1 
    run(fullfile('files','bear_appsettings'));

else
    run(fullfile('files','bear_settings'));
end

% run main code
run(fullfile('files','bear_toolbox_main_code.m'));
