function Xsim = simulate(Y,X,B,Fperiods,lags,N,n,m)

  p = lags;
  % fcast
  % Ysim = Y;
  % for i = 1:Fperiods
  %   temp=bear.lagx(Ysim,p-1);
  %   X=temp(end,:);
  %   yp = X*B;
  %   Ysim = [Ysim;yp];
  % end
     
  % sim IRF, just one shock
  Ysim = zeros(p,size(Y,2));
  Ysim(p,1) = 1;
  for i = 1:Fperiods
    X = [];
    % preparation of X matrices has to be run for each country separately and then merged
    for j = 1:N
      temp=bear.lagx(Ysim(:,(j-1)*N+1:j*N),p-1);
      X = [X [temp(end,:) zeros(1,m)]];
    end
    yp = X*B;
    Ysim = [Ysim;yp];
  end

  figure;
  for i = 1:N
    for j = 1:n
      ind = (i-1)*N+j;
      subplot(n,N,ind);
      plot(1:size(Ysim,1),Ysim(:,ind)');
      highlight(size(Ysim,1)-Fperiods:size(Ysim,1));
    end
  end
  
end