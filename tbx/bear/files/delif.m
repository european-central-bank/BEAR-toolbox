function xs=delif(x,t)
% DELIF(x,t) deletes the rows of x for which t=1
% x: NxK matrix, t: Nx1 matrix of 0's and 1's
xs=[];
nx=rows(x);
for i=1:nx
    if t(i)==0;
        xs=[xs;x(i,:)];
    end
end

