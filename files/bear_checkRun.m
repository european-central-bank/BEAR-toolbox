% peform some routines to check wheter we started BEAR via bear_Run
load('checkRun.mat')
checkRun.checkRun2=datetime;

% check wheter we just started the run file (in the last five seconds)
if milliseconds(checkRun.checkRun2-checkRun.checkRun1) < 5000 
    checkRun.bear_Run_dummy=1;
% % %     % turn off the the GUI in this case
% % %     GUI=0;
else % perform the normal routines
    checkRun.bear_Run_dummy=0;
end