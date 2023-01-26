function[endo_artificial]=gen_fake_data(endo_artificial,data_endo,B,EPSrotate,const,p,n,T)
Temp=[];
    for kk = 1:p
        endo_artificial(kk,:) = data_endo(kk,:);
        Temp = [endo_artificial(kk,:) Temp]; %Temp captures all the current and past realizations of the artificial series                                         %that are necesarry to produce the artificially generated data 
    end
    % Initialize the artificial series and take care of exogenous variables
    if const==0
        Temp2 = Temp;
    elseif const==1
        Temp2 = [Temp 1];
    end
    
    %% STEP 2.2: generate artificial series
    % From observation p+1 to T(number of observations), compute the artificial data
    for kk = p+1:T+p
        for mm = 1:n
            % Compute the value for time=jj
            endo_artificial(kk,mm) = Temp2 * B(1:end,mm) + EPSrotate(kk-p,mm);
        end
        % now update the Temp matrix
        if kk<T+p
            Temp = [endo_artificial(kk,:) Temp(1,1:(p-1)*n)];
            if const==0
                Temp2 = Temp;
            elseif const==1
                Temp2 = [Temp 1];
            end
        end
    end