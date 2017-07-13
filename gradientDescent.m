function [best_fit, J_history] = gradientDescent(x_coord, y_coord, f, n)
%%The gradient descent algorithm gives the optimal choice of the parameters
% cj (width of the asymmetric Gaussians) which minimizes the cost function

y_diff = f(x_coord) - y_coord';
m = numel(x_coord);


% Assign and initialize the fit parameters
[a, mu_new, sigma_new] = assignValues(f,n);

% termination tolerance
tol = 1e-6;
% maximum number of allowed iterations
maxiter = 100;
% step size ( 0.33 causes instability, 0.2 quite accurate)
alpha = 0.1;
% minimum allowed perturbation
dxmin = 1e-6;

J_history = zeros(maxiter,1);

% initialize gradient norm, optimization vector, iteration counter, perturbation
gnorm_mu = inf; dx_mu = inf;
gnorm_sigma = inf; dx_sigma = inf;

% gradient descent algorithm:
for iter = 1:maxiter
    if(gnorm_mu < tol || gnorm_sigma < tol || dx_mu < dxmin || dx_sigma < tol)
        break;
    end
    
    mu_old = mu_new;
    sigma_old = sigma_new;
    delta_mu = sigma_new;
    delta_sigma = zeros(n,1);
    
    % Calculate gradient
    for j = 1:n
        for i = 1:m
            comm_term = y_diff(i) * gaussianTerm(x_coord(i),a(j), ...
                                               mu_old(j),sigma_old(j)) * 2;
            delta_mu(j)    = delta_mu(j)    + comm_term * ...
                              2*(x_coord(i) - mu_old(j))/((sigma_old(j))^2);
            delta_sigma(j) = delta_sigma(j) + comm_term * ...
                         2*((x_coord(i) - mu_old(j))^2)/((sigma_old(j)^3));
        end
        delta_mu(j)    = delta_mu(j)/m;
        delta_sigma(j) = delta_sigma(j)/m;
    end
    % Take a step
    mu_new    = mu_old    - alpha*delta_mu;
    sigma_new = sigma_old - alpha*delta_sigma;
    
    % Update termination metrics
    gnorm_mu = norm(delta_mu);     gnorm_sigma = norm(delta_sigma);
    dx_mu = norm(mu_new - mu_old); dx_sigma = norm(sigma_new - sigma_old);
    
    for j = 1:n
        eval(sprintf('f.b%d = mu_new(%d)',j,j));
    end
    for j = 1:n
        eval(sprintf('f.c%d = sigma_new(%d)',j,j));
    end
    % Save the cost of J in every iteration
    J_history = computeCost(f(x_coord),y_coord',m);
end
% Why not adjust heights as well?  


best_fit = f;
end

function expo = gaussianTerm(x,a,b,c)
expo = a*exp(-(((x-b)/c)^2));
end

