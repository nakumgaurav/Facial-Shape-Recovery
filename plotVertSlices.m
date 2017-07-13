function plotVertSlices(f_L,z_M,f_U)
%%plotVertSlices plots the vertical slices of the fuzzy memb function
%%at a few values of 'x' for pixel (i,j)
X = [0, 25, 50, 75, 100];
x = (0:1:255)';
%{
load('MFs.mat');
f_L = Fits{i,j,1};
f_U = Fits{i,j,2};
%}
z_L = f_L(x); 
z_U = f_U(x);


for k = 1:numel(X)
    [u, secondary] = secondaryMemb(z_L(k),z_M(k),z_U(k));
    plot(u,secondary);
    if(k==1)
        hold on;
    end
end

legend('0', '25', '50', '75', '100');
xlim([0 1]);
ylim([0 1]);
xlabel('u');
ylabel('f(u)');
title('Secondary Membership Functions');