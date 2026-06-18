function [Xdraws, disturbanceDraws, X0draws, noiseDraws] = ...
    vectorRWsmoothingsampler1draw(Ydata, sqrtVCVstate, sqrtVCVnoise, X00, cholSigma00)
% vectorRWsmoothingsampler1draw
% ....

% sqrtVCVstate is time invariant, sqrtVCVnoise is time-varying

%   Coded by  Elmar Mertens, em@elmarmertens.com


%% parse inputs
[Ny, T]           = size(Ydata);
Nw                = size(sqrtVCVnoise,2);
Nx                = size(sqrtVCVstate,2);


%% init Variables and allocate memory

I                 = eye(Nx);
Iy                = eye(Ny);

%% allocate memory
[Sigmattm1, ImKC]           = deal(zeros(Nx, Nx, T));
invSigmaYttm1               = zeros(Ny, Ny, T);
Ytilde                      = zeros(Ny, T);
[XtT, Xttm1, Xplus]         = deal(zeros(Nx, T));


%% generate plus data
wplus  = randn(Nw, T);
eplus  = randn(Ny, T);
X0plus = X00 + cholSigma00 * randn(Nx, 1); 

%% Forward Loop: Kalman Forecasts
[Sigma00, Sigmatt] = deal(cholSigma00 * cholSigma00');
Xtt     = zeros(Nx,1); % use zeros, since projection on difference between Y and Yplus

disturbanceplus  = zeros(Nx, T);
noiseplus        = zeros(Ny, T);

VCVstate   = sqrtVCVstate * sqrtVCVstate';

for t = 1 : T
    
    % "plus" States and priors
    disturbanceplus(:,t)  = sqrtVCVstate * wplus(:,t);
    
    if t == 1
        Xplus(:,t) = X0plus + disturbanceplus(:,t);
    else
        Xplus(:,t) = Xplus(:,t-1) + disturbanceplus(:,t);
    end
    
    % priors
    Sigmattm1(:,:,t)        = Sigmatt + VCVstate;
    Xttm1(:,t)              = Xtt;    
    
    % observed innovation
    noiseplus(:,t)    = sqrtVCVnoise(:,:,t) * eplus(:,t); 
    Yplus             = Xplus(:,t) + noiseplus(:,t);
    SigmaYttm1        = Sigmattm1(:,:,t) + sqrtVCVnoise(:,:,t) * sqrtVCVnoise(:,:,t)';
        
   
    Ytilde(:,t) = Ydata(:,t) - Yplus  - Xttm1(:,t);
    
    invSigmaYttm1(:,:,t) = Iy / SigmaYttm1;

    % Kalman Gain
    K                       = Sigmattm1(:,:,t) * invSigmaYttm1(:,:,t);
    ImKC(:,:,t)             = I - K;
    
    % posteriors
    Sigmatt                 = ImKC(:,:,t) * Sigmattm1(:,:,t);
    
    Xtt                     = Xttm1(:,t) + K * Ytilde(:,t);
   
end

%% Backward Loop: Disturbance Smoother
XtT(:,T)        = Xtt;

StT             = invSigmaYttm1(:,:,T) * Ytilde(:,T);

if nargout > 1
    disturbancetT               = zeros(Nx, T);
    disturbancetT(:,T)          = VCVstate * StT;
else
    disturbancetT        = [];
end

if nargout > 2 
    noisetT            = zeros(Ny, T);
    noisetT(:,T)       = Ytilde(:,T) - (XtT(:,T) - Xttm1(:,T));
else
    noisetT      = [];
end


for t = (T-1) : -1 : 1
    
    StT         = ImKC(:,:,t)' * StT + ...
        (invSigmaYttm1(:,:,t) * Ytilde(:,t));
    XtT(:,t)    = Xttm1(:,t) + Sigmattm1(:,:,t) * StT;
    
    if ~isempty(disturbancetT)
        disturbancetT(:,t)        = VCVstate * StT;
    end
    if ~isempty(noisetT)
        noisetT(:,t)       = Ytilde(:,t) - (XtT(:,t) - Xttm1(:,t));
    end
    
end

%% sample everything together (and reorder output dimensions)
Xdraws  = Xplus + XtT;

if nargout > 1
    
    disturbanceDraws  = disturbanceplus + disturbancetT;
    
    if nargout > 2
        
        X0T      = Sigma00 * StT; % note: no mean added to X0T since it is already included in X0plus
        X0draws  = X0plus + X0T;
        
        
        if nargout > 3
            noiseDraws  = noiseplus + noisetT;
        end
    end
end


       
