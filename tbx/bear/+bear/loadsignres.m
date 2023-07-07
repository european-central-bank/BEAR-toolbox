function [signrestable,signresperiods,signreslabels,strctident,favar]=loadsignres(n,endo,pref,favar,IRFt,strctident)

% preliminary tasks

% initiate the cells signrestable, signresperiods and signreslabels
SignResValues = pref.data.SignResValues;
SignResValues = SignResValues(contains(endo,SignResValues.Properties.RowNames), contains(endo, SignResValues.Properties.RowNames));

signreslabels = SignResValues.Properties.VariableDescriptions';
signrestable = bear.utils.parseTableContent(SignResValues{:,:});
signresperiods = cell(n,n);


signreslabels_shocksindex=[];

%% check if sign, zero, magntiude restrictions are activated at all
% check for empty columns in signrestable
emptycells = cellfun(@isempty, signrestable);
count=sum( any( ~emptycells ) );

if count==0 && favar.FAVAR==0 % we found no signres res (this test is not applicable to the favar restrictions atm)
    strctident.signres=0;
    strctident.hbartext_signres='';
    strctident.zerores=0;
    strctident.hbartext_zerores='';
    strctident.magnres=0;
    strctident.hbartext_magnres='';
    strctident.favar_signres=0;
    strctident.hbartext_favar_signres='';
    strctident.favar_zerores=0;
    strctident.hbartext_favar_zerores='';
    strctident.favar_magnres=0;
    strctident.hbartext_favar_magnres='';
    strctident.signreslabels=signreslabels;
    strctident.signreslabels_shocksindex=signreslabels_shocksindex;
    strctident.signreslabels_shocks=cell(n,1);
    strctident.signrestableempty=ones(n,1);
    strctident.favar_signrestableempty=ones(n,1);

else % if we found something in the table then the sign res routine is activated
    %% sign restriction values
    % empty sign res table columns
    strctident.signrestableempty = all(emptycells)';                                        

    % erase first column in the restriction table for IV shock
    if IRFt==6
        % check for empty columns in sign res table
        %for ii=1:size(signrestable,2)
        if strctident.signrestableempty(1,1)==0
            for ll=1:size(signrestable,1)
                signrestable{ll,1}='';
            end
            signreslabels{1,1}=strcat('IV Shock (',strctident.Instrument,')');
            signreslabels_shocksindex(1,1)=1;
            message= "The restrictions in the first column of the ""sign res values"" table are ignored. This is the IV shock.";
            msgbox(message,'Sign restriction warning');
        end
        %end
    end

    %% zero res
    % loop over columns
    for ii=1:n
        % count the number of zero restrictions in this column
        numzerores=sum(strcmp(signrestable(:,ii),'0'));
        % if there are too many zero restrictions for the column, return an error
        if numzerores>n-ii
            temp=['You have requested ' num2str(numzerores) ' zero restrictions in column ' num2str(ii) ' of the restriction matrix, but at most ' num2str(n-ii) ' such restrictions can be implemented.'];
            msgbox(temp,'Zero restriction issue');
            error('Zero restriction error');
        end
    end

    %% sign restriction periods 
    signresperiods = pref.data.SignResPeriods;
    signresperiods = signresperiods(contains(endo,signresperiods.Properties.RowNames), contains(endo, signresperiods.Properties.RowNames));
    if height(signresperiods) ~= n || width(signresperiods) ~= n
        message = "Some endogenous variable cannot be found in both rows and columns of the table. Please verify that the ""sign res periods"" sheet of the Excel data file is properly filled.";
        error("bear:loadsignres:signrestrictionError", message)
    end

    signresperiods = bear.utils.parseTableContent(signresperiods{:,:});

    % now recover the values for the cell signresperiods
    % loop over endogenous (rows)
    for ii=1:n
        % loop over endogenous (columns)
        for jj=1:n
            % record the value
            signresperiods{ii,jj}=str2num(signresperiods{ii,jj}); %#ok<ST2NM>
        end
    end
    % erase first column in the restriction table for IV shock
    if IRFt==6
        % check for empty columns in sign res table
        for ii=1:size(signresperiods,2)
            signresperiodscat=cat(2,signresperiods{:,ii});
            if ii==1 && isempty(signresperiodscat)==0
                for ll=1:size(signresperiods,1)
                    signresperiods{ll,ii}='';
                end
                message= "The restrictions in the first column of the ""sign res periods"" table are ignored. This is the IV shock.";
                msgbox(message,'Sign restriction warning');
            end
        end
    end


    % recover the labels, if any
    % loop over endogenous (columns)
    for ii = 1 : n
        label = signreslabels{ii}';
        if IRFt == 6 && ii == 1
            signreslabels{ii,1}= "IV Shock (" + strctident.Instrument + ")";
            signreslabels_shocksindex=[signreslabels_shocksindex; ii];
        elseif isempty(label)
            signreslabels{ii,1} = "shock " + ii;
            if strctident.signrestableempty(ii)==0 % restrictions, however no label is found, count this column
                signreslabels_shocksindex=[signreslabels_shocksindex; ii];
            end
        else
            if strctident.signrestableempty(ii)==0 % label and restictions found
                signreslabels_shocksindex=[signreslabels_shocksindex; ii];
            elseif strctident.signrestableempty(ii)==1 % label, however no restriction is found, ignore this column
                signreslabels{ii,1}= "shock " + ii;
            end
        end
    end

    % save the shock index to later determine the number of identified shocks
    strctident.signreslabels_shocksindex=unique(signreslabels_shocksindex);
    strctident.signreslabels_shocks=signreslabels(strctident.signreslabels_shocksindex);
    strctident.signreslabels=signreslabels;


    %% Preliminiaries for irfres function
    % now identify all the periods concerned with restrictions
    % first expand the non-empty entries in signresperiods since they are only expressed in intervals: transform into list
    % for instance, translate [1 4] into [1 2 3 4]; I don't think this can done without a loop
    temp=cell2mat(signresperiods(~cellfun(@isempty,signresperiods)));
    periods=[];
    for ii=1:size(temp,1)
        periods=[periods temp(ii,1):temp(ii,2)];
    end
    % suppress duplicates and sort
    strctident.periods=sort(unique(periods))';
    % count the total number of restriction periods (required for IRF matrix)
    nperiods=size(strctident.periods,1);

    % Identify the restriction matrices
    % create five cells, corresponding to the three possible restrictions:
    % one cell for sign restrictions, three cells for magnitude restrictions, one cell for zero restrictions

    strctident.Scell=cell(1,n);
    strctident.Mcell=cell(1,n);
    strctident.Mlcell=cell(1,n);
    strctident.Mucell=cell(1,n);
    strctident.Zcell=cell(1,n);


    % Check if value and periods restrictions correspond to each other
    if sum(sum(~cellfun(@isempty,signresperiods) == ~cellfun(@isempty,signrestable))) == n^2
        % All cells with sign restrictions also specify the horizon over which
        % these are applied
    else
        disp('Warning: Value restrictions do not correspond to period restrictions one to one')
        pause(0.1)
    end

    % loop over rows and columns of the period matrix
    for ii=1:n
        for jj=1:n
            % if entry (ii,jj) of the period matrix and of the value matrix is not empty...
            if ~isempty(signresperiods{ii,jj}) && ~isempty(signrestable{ii,jj})
                % ... then there is a restriction over one (or several) periods
                % loop overt those periods
                for kk=signresperiods{ii,jj}(1,1):signresperiods{ii,jj}(1,2)
                    % identify the position of the considered period within the list of all periods (required to build the matrix)
                    position=find(strctident.periods==kk);
                    % now create the restriction matrix: this will depend on the type of restriction
                    % if it is a positive sign restriction...
                    if strcmp(signrestable{ii,jj},'+')
                        % ... then input a 1 entry in the corresponding S matrix
                        strctident.Scell{1,jj}=[strctident.Scell{1,jj};zeros(1,n*nperiods)];
                        strctident.Scell{1,jj}(end,(position-1)*n+ii)=1;
                        % if it is a negative sign restriction...
                    elseif strcmp(signrestable{ii,jj},'-')
                        % ... then input a -1 entry in the corresponding S matrix
                        strctident.Scell{1,jj}=[strctident.Scell{1,jj};zeros(1,n*nperiods)];
                        strctident.Scell{1,jj}(end,(position-1)*n+ii)=-1;
                        % if it is a zero restriction...
                    elseif strcmp(signrestable{ii,jj},'0')
                        % ... then input a 1 entry in the corresponding Z matrix
                        strctident.Zcell{1,jj}=[strctident.Zcell{1,jj};zeros(1,n*nperiods)];
                        strctident.Zcell{1,jj}(end,(position-1)*n+ii)=1;
                        % else, a non-empty entry being neither a sign nor a zero restriction has to be a magnitude restriction
                    else
                        % fill the corresponding M matrices:
                        % input a 1 in M
                        strctident.Mcell{1,jj}=[strctident.Mcell{1,jj};zeros(1,n*nperiods)];
                        strctident.Mcell{1,jj}(end,(position-1)*n+ii)=1;
                        % input the lower value of the interval in Ml
                        temp=str2num(signrestable{ii,jj});
                        strctident.Mlcell{1,jj}=[strctident.Mlcell{1,jj};temp(1,1)];
                        % input the upper value of the interval in Mu
                        strctident.Mucell{1,jj}=[strctident.Mucell{1,jj};temp(1,2)];
                    end
                end
            end
        end
    end

    %% Check kind of restrictions
    % now check what kind of restrictions apply among sign, zero and magnitude restrictions
    % check for sign restrictions: if there are any, at least one entry in the cell Scell is non-empty
    if sum(~cellfun(@isempty,strctident.Scell))~=0
        strctident.signres=1;
        strctident.hbartext_signres='sign, ';
    else
        strctident.signres=0;
        strctident.hbartext_signres='';
    end
    % similarly check for zero restrictions
    if sum(~cellfun(@isempty,strctident.Zcell))~=0
        strctident.zerores=1;
        strctident.hbartext_zerores='zero, ';
    else
        strctident.zerores=0;
        strctident.hbartext_zerores='';
    end
    % check for absolute magnitude restrictions
    if sum(~cellfun(@isempty,strctident.Mcell))~=0
        strctident.magnres=1;
        strctident.hbartext_magnres='magnitude, ';
    else
        strctident.magnres=0;
        strctident.hbartext_magnres='';
    end


    %% FAVAR restrictions
    if favar.FAVAR==1
        % strings of restricted information variables
        signresX_init=strngs1(max(rows)+1:end,min(clmns)-1); %strngs1 is already adjusted for empty rows and columns
        % which information variables are restricted?
        Xsignres=ismember(signresX_init,favar.informationvariablestrings);
        % number of restricted variables in X
        favar.nsignresX=sum(Xsignres);
        % keep only the ones that are actually in X
        favar.signresX=signresX_init(Xsignres==1,:);

        if favar.nsignresX~=0

            %create indices for restricted information variables (ordering in the sign res table is irrelevant)
            for jj=1:favar.nsignresX
                for ii=1:favar.nfactorvar
                    signresX_indexlogical{jj,1}(ii,1)=strcmp(favar.informationvariablestrings(1,ii),favar.signresX{jj,1}); % do we need this output in favar.?
                end
            end
            for jj=1:favar.nsignresX
                favar.signresX_index(jj,1)=find(signresX_indexlogical{jj,1}==1);
            end

            % now recover the values for the cell favar.signrestable
            for ii=1:favar.nsignresX % loop over restricted information variables
                for jj=1:n % loop over endogenous (columns)
                    favar.signrestable{ii,jj}=strngs1{max(rows)+ii,clmns(jj,1)};
                end
            end

            % empty favar sign res table columns
            for ii=1:size(favar.signrestable,2)
                strctident.favar_signrestableempty(ii,1)=isempty(cat(2,favar.signrestable{:,ii}))==1;
            end

            % erase first column in the restriction table for IV shock
            if IRFt==6
                % check for empty columns in sign res table
                for ii=1:size(favar.signrestable,2)
                    if ii==1 && sum(strctident.signrestableempty(ii,1))+sum(strctident.favar_signrestableempty(ii,1))==0
                        for ll=1:size(favar.signrestable,1)
                            favar.signrestable{ll,ii}='';
                        end
                        strctident.favar_signrestableempty(1,1)=1;
                        message=['The restrictions in the first column of the "sign res values" table are ignored. This is the IV shock.'];
                        msgbox(message,'Sign restriction warning');
                    end
                end
            end



            %% favar prelim for irfres function
            % check if we have restrictions to activate routines
            %if sum(any(~cellfun('isempty',favar.signrestable)))~=0
            %if sum(strctident.favar_signrestableempty==0)~=0

            % initiate cells
            strctident.favar_Scell=cell(1,n);
            strctident.favar_Mcell=cell(1,n);
            strctident.favar_Mlcell=cell(1,n);
            strctident.favar_Mucell=cell(1,n);
            strctident.favar_Zcell=cell(1,n);

            % assuming that the variables in the periods table here are identical to the variables in the value table
            % now recover the values for the cell favar.signrestable
            for ii=1:favar.nsignresX % loop over restricted information variables
                for jj=1:n % loop over endogenous (columns)
                    favar.signresperiods{ii,jj} = signresperiods{ii,jj};
                end
            end

            % now identify all the periods concerned with favar restrictions
            % first expand the non-empty entries in favar.signresperiods since they are only expressed in intervals: transform into list
            % for instance, translate [1 4] into [1 2 3 4]; I don't think this can done without a loop
            favar_temp=cell2mat(favar.signresperiods(~cellfun(@isempty,favar.signresperiods)));
            favar_periods=[];
            for ii=1:size(favar_temp,1)
                favar_periods=[favar_periods favar_temp(ii,1):favar_temp(ii,2)];
            end
            % suppress duplicates and sort
            strctident.favar_periods=sort(unique(favar_periods))';
            % count the total number of restriction periods (required for IRF matrix)
            favar_nperiods=size(strctident.favar_periods,1);

            % Check if value and periods restrictions correspond to each other
            if sum(sum(~cellfun(@isempty,favar.signresperiods) == ~cellfun(@isempty,favar.signrestable))) == n*favar.nsignresX
                % All cells with sign restrictions also specify the horizon over which
                % these are applied
            else
                disp('Warning: Value restrictions do not correspond to period restrictions one to one (FAVAR)')
                pause(0.1)
            end

            % loop over rows and columns of the period matrix
            for jj=1:n %shocks
                for ii=1:favar.nsignresX
                    % if entry (ii,jj) of the period matrix and of the value matrix is not empty...
                    if ~isempty(favar.signresperiods{ii,jj}) && ~isempty(favar.signrestable{ii,jj})
                        % ... then there is a restriction over one (or several) periods
                        % loop overt those periods
                        for kk=favar.signresperiods{ii,jj}(1,1):favar.signresperiods{ii,jj}(1,2)
                            % identify the position of the considered period within the list of all periods (required to build the matrix)
                            favar_position=find(strctident.favar_periods==kk);
                            % now create the restriction matrix: this will depend on the type of restriction
                            % if it is a positive sign restriction...
                            if strcmp(favar.signrestable{ii,jj},'+')
                                % ... then input a 1 entry in the corresponding S matrix
                                strctident.favar_Scell{1,jj}=[strctident.favar_Scell{1,jj};zeros(1,favar.nsignresX*favar_nperiods)];
                                strctident.favar_Scell{1,jj}(end,(favar_position-1)*favar.nsignresX+ii)=1;
                                % if it is a negative sign restriction...
                            elseif strcmp(favar.signrestable{ii,jj},'-')
                                % ... then input a -1 entry in the corresponding S matrix
                                strctident.favar_Scell{1,jj}=[strctident.favar_Scell{1,jj};zeros(1,favar.nsignresX*favar_nperiods)];
                                strctident.favar_Scell{1,jj}(end,(favar_position-1)*favar.nsignresX+ii)=-1;
                                % if it is a zero restriction...
                            elseif strcmp(favar.signrestable{ii,jj},'0')
                                % ... then input a 1 entry in the corresponding Z matrix
                                strctident.favar_Zcell{1,jj}=[strctident.favar_Zcell{1,jj};zeros(1,favar.nsignresX*favar_nperiods)];
                                strctident.favar_Zcell{1,jj}(end,(favar_position-1)*favar.nsignresX+ii)=1;
                                %else, a non-empty entry being neither a sign nor a zero restriction has to be a magnitude restriction
                            else
                                % fill the corresponding M matrices:
                                % input a 1 in M
                                strctident.favar_Mcell{1,jj}=[strctident.favar_Mcell{1,jj};zeros(1,favar.nsignresX*favar_nperiods)];
                                strctident.favar_Mcell{1,jj}(end,(favar_position-1)*favar.nsignresX+ii)=1;
                                % input the lower value of the interval in Ml
                                temp=str2num(favar.signrestable{ii,jj});
                                strctident.favar_Mlcell{1,jj}=[strctident.favar_Mlcell{1,jj};temp(1,1)];
                                % input the upper value of the interval in Mu
                                strctident.favar_Mucell{1,jj}=[strctident.favar_Mucell{1,jj};temp(1,2)]; %what kind of interval?
                            end
                        end
                    end
                end
            end

            % check for favar magnitude restrictions
            if sum(~cellfun('isempty',strctident.favar_Scell))~=0
                strctident.favar_signres=1;
                strctident.hbartext_favar_signres='favar-sign, ';
            else
                strctident.favar_signres=0;
                strctident.hbartext_favar_signres='';
            end

            % similarly check for favar zero restrictions
            if sum(~cellfun('isempty',strctident.favar_Zcell))~=0
                strctident.favar_zerores=1;
                strctident.hbartext_favar_zerores='favar-zero, ';
            else
                strctident.favar_zerores=0;
                strctident.hbartext_favar_zerores='';
            end

            % similarly check for favar magnitude restrictions
            if sum(~cellfun('isempty',strctident.favar_Mcell))~=0
                strctident.favar_magnres=1;
                strctident.hbartext_favar_magnres='favar-magnitude, ';
            else
                strctident.favar_magnres=0;
                strctident.hbartext_favar_magnres='';
            end


            % check if shocks are not identified via sign res, but via favar sign res
            if strctident.favar_signres==1 ||strctident.favar_zerores==1||strctident.favar_magnres==1
                % check for empty sign res and non-empty favar sign res shocks
                for ii=1:size(strctident.signreslabels,1)
                    if strctident.signrestableempty(ii,1)==1 && strctident.favar_signrestableempty(ii,1)==0
                        % add them to the list of identified shocks in this case
                        if isempty(strngs1{min(rows)-2,clmns(ii,1)})==0
                            strctident.signreslabels{ii,1}=strngs1{min(rows)-2,clmns(ii,1)}; % take the label provided in the table in this case
                        else
                            strctident.signreslabels{ii,1}=['shock ' num2str(ii)];    % or generate a label
                        end
                        strctident.signreslabels_shocksindex=[strctident.signreslabels_shocksindex; ii]; % add it in the shocksindex
                    end
                end
                % update the output in strctident
                strctident.signreslabels_shocksindex=unique(strctident.signreslabels_shocksindex);
                strctident.signreslabels_shocks=strctident.signreslabels(strctident.signreslabels_shocksindex);
                signreslabels=strctident.signreslabels;



                % % % if favar.FEVDplot==1
                % % %         FEVDplotXshock_indexlogical=ismember(signreslabels,favar.FEVD.pltXshck);
                % % %         favar.FEVD.plotXshock_index=find(FEVDplotXshock_indexlogical==1)';
                % % %         favar.FEVD.npltXshck=size(favar.FEVD.pltXshck,1);
                % % %         if favar.FEVD.npltXshck==0
                % % %         % error if no shock to plot is found, otherwise code crashes at a later stage
                % % %         message=['Error: Shock(' favar.FEVD.npltXshck ') cannot be found.'];
                % % %         msgbox(message,'favar.FEVD.npltXshck error');
                % % %         error('programme termination: favar.FEVD.npltXshck error');
                % % %         end
                % % % end

                % % % % adjust periods in case the maximum number of restricted periods is larger for favar restrictions only
                % % % if max(strctident.favar_periods)>max(strctident.periods)
                % % %     strctident.periods=strctident.favar_periods;
                % % % end
            end




        else % no favar restrictions found here
            strctident.favar_signres=0;
            strctident.hbartext_favar_signres='';
            strctident.favar_zerores=0;
            strctident.hbartext_favar_zerores='';
            strctident.favar_magnres=0;
            strctident.hbartext_favar_magnres='';
            strctident.favar_signrestableempty=ones(n,1);
            favar.signresX_index=[];
        end

        % create indices for plotXshock
        if favar.IRFplot==1 && favar.npltX>0
            IRFplotXshock_indexlogical=ismember(signreslabels,favar.IRF.pltXshck);
            favar.IRF.plotXshock_index=find(IRFplotXshock_indexlogical==1)';
            favar.IRF.npltXshck=size(favar.IRF.pltXshck,1);
            if favar.IRF.npltXshck==0
                % error if no shock to plot is found, otherwise code crashes at a later stage
                message=['Error: at least one Shock (' favar.IRFplotXshock ') cannot be found.'];
                error('bear:loadsignres:ShockNotFound',message)
            end
        end

    else %if favar.FAVAR is not =1, we do not have favar restrictions anyway
        strctident.favar_signres=0;
        strctident.hbartext_favar_signres='';
        strctident.favar_zerores=0;
        strctident.hbartext_favar_zerores='';
        strctident.favar_magnres=0;
        strctident.hbartext_favar_magnres='';
        strctident.favar_signrestableempty=ones(n,1);
    end

    % finally, record on Excel
    if pref.results==1
        pref.exporter.writeSignResValues(pref.data.SignResValues)
        pref.exporter.writeSignResPeriods(pref.data.SignResPeriods)
    end

end
