function [U, Z] = secondaryFuncs(i,j)
%%secondary(i,j) returns the secondary membership functions for each pixel
% intensity (0 to 255) of pixel (i,j)

% Construct the secondary membership functions
x = (0:1:255)';

load('partials.mat');
f_L = Fits_partial_4{i,j,1}; 
f_U = Fits_partial_4{i,j,2};

%{
x = linspace(0,10,100);
f_L = @(x)(max(exp(-(x-3)^2/8), 0.8*exp(-(x-6)^2/8)));
f_U = @(x)(max(0.5*exp(-(x-3)^2/2), 0.4*exp(-(x-6)^2/2)));
%}

pts = 100;
X = repmat(x,1,pts);
U = zeros(size(X)); 
Z = zeros(size(X));

z_L = f_L(x); 
z_U = f_U(x);

for k = 1:numel(x)
    [U(k,:), Z(k,:)] = secondaryMemb(z_L(k),x,z_U(k));
end