% turn off incompatible combinations of options and other preliminaries
% these steps have to be done before convertsrings
% first check for favar, turn off routines if favar doesn't exist (for VARtypes other than =1)
if exist('favar','var')~=1 | favar.FAVAR==0
    favar.FAVAR=0;
    favar.HD.plot=0;
    favar.IRF.plot=0;
    favar.FEVD.plot=0;
end

if favar.FAVAR==1
    if VARtype~=2
        favar.onestep=0; % always two-step (factors are static, principal components)
    end
	
	if favar.onestep==1 && favar.blocks==1
	    message='Please select two-step estimation (favar.onestep==0) to use Blocks.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
	end
    if favar.onestep==1 || IRFt>3 || favar.blocks==1
        favar.slowfast=0;
    end
    
    if favar.slowfast==1
        favar.blocknames='slow fast'; % specify in excel sheet 'factor data'
    end
    
    % changed the variable name in the settings for clarity to favar.plotXshock
    favar.IRF.plotXshock=favar.plotXshock;
    
    if favar.FEVD.plot==1
        % choose shock(s) to plot
        favar.FEVD.plotXshock=favar.IRF.plotXshock; % this option should be removed
    end
    if IRFt>4
        message='It is currently not recommended to use IRFt 5 and IRFt 6 in a FAVAR.';
        msgbox(message,'FAVAR warning','warn','warning');
    end
    
    if favar.blocks==0
        favar.HD.plotXblocks=0;
        favar.HD.HDallsumblock=0;
    end
    
    if VARtype==2 && (prior==51 || prior==61)
        message='Please choose other prior (51, 61 are currently not supported in FAVARs.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
    end
    
    if VARtype==5 && stvol==4
        message='stvol4 is currently not supported in FAVARs.';
        msgbox(message,'FAVAR error','Error','error');
        error('programme termination');
    end
end

if VARtype==2 && (IRFt==5 || IRFt==6)
    if  prior==21 || prior==22
    else
        message='Please choose Normal-Wishart prior (21, 22) for IRFt 5 and 6.';
        msgbox(message,'IRFt warning','Error','error');
        error('programme termination');
    end
end

if exist('strctident','var')~=1
    strctident.strctident=0;
end

if VARtype==4 || VARtype==6 % turn off the correl res routines
    strctident.CorrelInstrument="";
    strctident.CorrelShock="";
end

if IRFt==5
    strctident.MM=0; %no medianmodel in this case
end
