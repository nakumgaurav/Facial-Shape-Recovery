function [c_L, c_R] = MCF(i,j)
%%Monotone Centroid Flow algorithm implemented on pixel (i,j)

k = 8;          % The number of alpha-planes 
x = (0:1:255)';
n = numel(x);   % The number of discretization levels of the primary variable
%% Step-1: Compute the principal memberhsip function A*(x)
[~,Astar,~] = alphaPlane(i,j,1);

%% Step-2: Calculate the centroid C_A*(x) of the principal membership and the global switch points L^ and R^
CAstar = x'*Astar/sum(Astar);
Lhat = ceil(CAstar);            % 104
Rhat = floor(CAstar);           % 103

%% Step-3: Centroid Flow Elementary Operation
alpha = 0:(1/k):1;

% Estimated centroid boundaries for alpha-planes A0 to Ak
c_hatL = zeros(k+1,1); 
c_hatR = zeros(k+1,1);
c_hatL(k+1) = CAstar;
c_hatR(k+1) = CAstar;

% True centroid boundaries for alpha-planes A0 to Ak
c_L = zeros(k+1,1);
c_R = zeros(k+1,1);
c_L(k+1) = CAstar;
c_R(k+1) = CAstar;


E1 = zeros(n,1);
E2 = zeros(n,1);
D1 = zeros(n,1);
D2 = zeros(n,1);


for t = k:-1:1
    % 3.1
    [~, lmf, umf] = alphaPlane(i,j,alpha(t));
    E1(Lhat) = x(1:Lhat)'*umf(1:Lhat) + x(Lhat+1:n)'*lmf(Lhat+1:n);
    E2(Lhat) = sum(umf(1:Lhat)) + sum(lmf(Lhat+1:n));
    D1(Rhat) = x(1:Rhat)'*lmf(1:Rhat) + x(Rhat+1:n)'*umf(Rhat+1:n);
    D2(Rhat) = sum(lmf(1:Rhat)) + sum(umf(Rhat+1:n));

    c_hatL(t) = E1(Lhat)/E2(Lhat);
    c_hatR(t) = D1(Rhat)/D2(Rhat);
   
    % 3.2
    E1(Lhat-1) = E1(Lhat) - x(Lhat)*umf(x(Lhat)) - lmf(x(Lhat));
    E2(Lhat-1) = E2(Lhat) - umf(x(Lhat)) + lmf(x(Lhat));
    
    cl_prime = E1(Lhat-1)/E2(Lhat-1);
    
    % 3.3
    while(cl_prime < c_hatL(t))
        c_hatL(t) = cl_prime;
        Lhat = Lhat - 1;
        E1(Lhat-1) = E1(Lhat) - x(Lhat)*umf(x(Lhat)) - lmf(x(Lhat));
        E2(Lhat-1) = E2(Lhat) - umf(x(Lhat)) + lmf(x(Lhat));
        cl_prime = E1(Lhat-1)/E2(Lhat-1);
    end
    c_L(t) = c_hatL(t);
    
    % 3.4
    D1(Rhat+1) = D1(Rhat) - x(Rhat)*lmf(x(Rhat)) - umf(x(Rhat));
    D2(Rhat+1) = D2(Rhat) - lmf(x(Rhat)) + umf(x(Rhat));
    
    cr_prime = D1(Rhat+1)/D2(Rhat+1);
    
    % 3.5
    while(cr_prime > c_hatR(t))
        c_hatR(t) = cr_prime;
        Rhat = Rhat + 1;
        D1(Rhat+1) = D1(Rhat) - x(Rhat)*lmf(x(Rhat)) - umf(x(Rhat));
        D2(Rhat+1) = D2(Rhat) - lmf(x(Rhat)) + umf(x(Rhat));
        cr_prime = D1(Rhat+1)/D2(Rhat+1);
    end
    c_R(t) = c_hatR(t);
end

%c_L(k) = mean([c_L(k-1) c_L(k+1)]);
end