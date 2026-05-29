function [Xdraw, shockDraw,  X0draw, Xhat, X0hat, P] = rwnoisePrecisionBasedSampler(Y, Ny, T, volSTATE, volNOISE, X0, sqrtV0, Ndraws)
% precisionBasedSampler for RW + noise vector
% computes smoothed kalman states using the stacked approach of Chan and Jeliazkov
%  
%   ... 

% assumes volSTATE is Nx x 1 vector (or Nx x T matrix), and volNOISE is (Ny x T) x 1 vectors (i.e. no correlation within X and Y)

% Stacks X0 onto X

if nargin < 8
    Ndraws = 1;
end

%% read parameters
Y        = Y(:);
NyT      = Ny * T;
Nx       = Ny;
NxT      = Nx * T; 
NxTp1    = Nx * (T + 1); 

%% construct stacked system
XX0 = sparse(1:Nx, 1, X0, NxTp1, 1);

rowndx = [1 : NxTp1, Nx + (1 : NxT)];
colndx = [1 : NxTp1, 1 : NxT];
values = [ones(1,NxTp1), -ones(1, NxT)];
AA     = sparse(rowndx, colndx, values);

CC     = cat(2, sparse(NyT, Nx), speye(NyT, NxT));

if size(volSTATE, 3) == 1
    IT          = speye(T);
    sqrtSIGMA   = blkdiag(sqrtV0,  kron(IT, volSTATE));
else
    rowndx      = repmat((1:Nx)', 1, Nx) + permute(Nx * (0:T), [1 3 2]);
    colndx      = repmat((1:NxTp1), Nx, 1);
    volSTATE    = cat(1,sqrtV0(:),volSTATE(:));
    sqrtSIGMA   = sparse(rowndx(:), colndx(:), volSTATE(:));
end


sqrtOMEGA   = sparse(1:NyT, 1:NyT, volNOISE(:)');

%% set up  stacked system


AAtilde            = sqrtSIGMA \ AA;
XX0tilde           = sqrtSIGMA \ XX0;

CCtilde            = sqrtOMEGA \ CC;
Ytilde             = sqrtOMEGA \ Y;

P                   = AAtilde' * AAtilde + (CCtilde' * CCtilde);
[sqrtP, flag]       = chol(P, 'lower');

if flag > 0
    error('P not posdf, using QR instead')
    % via qr -- much slower
    M = [AAtilde; CCtilde]; %#ok<UNRCH>
    m = size(M,2);
    [~, R] = qr(M);
    sqrtP = R(1:m,1:m)';
    % checkdiff(sqrtP * sqrtP', sqrtP2 * sqrtP2');
end

sqrtPXhat   = sqrtP \ (AAtilde' * XX0tilde + CCtilde' * Ytilde); 

Zdraw        = randn( NxTp1, Ndraws);
Xdraw        = (sqrtP') \ (sqrtPXhat + Zdraw);

if nargout > 1
    shockDraw = AA * Xdraw - XX0;
    shockDraw = reshape(shockDraw(Nx+1:end), Nx, T, Ndraws);
end

X0draw       = Xdraw(1:Nx); % nargout > 2
Xdraw        = reshape(Xdraw(Nx+1:end), Nx, T, Ndraws);

if nargout > 3
    Xhat        = (sqrtP') \ sqrtPXhat;
    X0hat       = Xhat(1:Nx);
    Xhat        = reshape(Xhat(Nx+1:end), Nx, T, Ndraws);
end

