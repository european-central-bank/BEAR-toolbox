function []=irfdisp2(n,T,decimaldates1,endo,IRFperiods,IRFt,irf_estimates_allt,pref,signreslabels)



% function []=irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,datapath)
% plots the results for the impulse response functions
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs 
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none


% convert results into interpretable format
plot_estimates=cell(n,n);
for ii=1:n
    for jj=1:n
      for kk=1:IRFperiods
         for tt=1:T
         plot_estimates{ii,jj}(tt,kk)=irf_estimates_allt{ii,jj}(2,kk,tt);
         end
      end
    end
end
plotX = repmat(decimaldates1,1,IRFperiods);
plotY = repmat(1:IRFperiods,T,1);
plot_estimates=plot_estimates';

if pref.plot
% create figure for IRFs
irf=figure;
set(irf,'Color',[0.9 0.9 0.9]);
   if IRFt==1
   set(irf,'name','impulse response functions (all sample periods, no structural identifcation)');
   elseif IRFt==2
   set(irf,'name','impulse response functions (all sample periods, structural identification by Cholesky ordering)');
   elseif IRFt==3
   set(irf,'name','impulse response functions (all sample periods, structural identification by triangular factorisation)');
   elseif IRFt==4
   set(irf,'name','impulse response functions (all sample periods, structural identification by sign restrictions)');
   end
for ii=1:n^2
subplot(n,n,ii);
temp=surf(plotX,plotY,plot_estimates{ii});
set(gca,'Ydir','reverse');
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(T,1)],'YLim',[1 IRFperiods],'FontName','Times New Roman');
set(temp,'edgecolor',[0.15 0.15 0.15],'EdgeAlpha',0.5);
% top labels
   if ii<=n
      % if a sign restriction identification scheme has been used, use the structural shock labels
      if IRFt==4
      title(signreslabels{ii,1},'FontWeight','normal','interpreter','latex');
      % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
      else
      title(endo{ii,1},'FontWeight','normal','interpreter','latex');
      end
   end
% side labels
   if rem((ii-1)/n,1)==0
   ylabel(endo{(ii-1)/n+1,1},'FontWeight','normal','interpreter','latex');
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
% side supertitle
ylabel('Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal','interpreter','latex');
set(get(ax,'Ylabel'),'Visible','on')

end % pref.plot
