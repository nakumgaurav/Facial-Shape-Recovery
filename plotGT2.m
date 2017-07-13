function s = plotGT2(i,j) % x_pts
%x_pts = [0 25 50 75 100];
% load('something.mat');
load('pre_Fbar/basic.mat');
load('partials.mat');
x = (0:1:255)';
f_L = Fits_partial_4{i,j,1}; 
f_U = Fits_partial_4{i,j,2};

f_M = findBestFit(i,j);
z_M = f_M(x);
close all;
%{
% Plot the primary membership functions
plotT1funcs(f_L,f_U,i,j);


% Show the points through which vertical slices will be drawn in the next
% figure
hold on;
plot([x_pts(1) x_pts(1)], [f_L(x_pts(1)) f_U(x_pts(1))],':'); 
plot([x_pts(2) x_pts(2)], [f_L(x_pts(2)) f_U(x_pts(2))],':'); 
plot([x_pts(3) x_pts(3)], [f_L(x_pts(3)) f_U(x_pts(3))],':'); 
plot([x_pts(4) x_pts(4)], [f_L(x_pts(4)) f_U(x_pts(4))],':');
plot([x_pts(5) x_pts(5)], [f_L(x_pts(5)) f_U(x_pts(5))],':');
%legend(sprintf(' 'LMF',\'UMF\',\'x=0\',\'x=25\', \'x=50\', \'x=75\', \'x=100\' '));

% Plot the secondary membership functions of the 5 points shown in figure 1
hold off; 
plotVertSlices(f_L,z_M,f_U);

%}

% Plot the surface plot of the GT2 FS
pts = 100;
X = repmat(x,1,pts);
U = zeros(size(X)); 
Z = zeros(size(X));

z_L = f_L(x); 
z_U = f_U(x);


for k = 1:256
    [U(k,:), Z(k,:)] = secondaryMemb(z_L(k),z_M(k),z_U(k));
end
figure; 
s = surf(X,U,Z);

% Other graph features
colorbar;
xlim([0 255]); ylim([0 1]); zlim([0 1]);
xlabel('Feature (x)');
ylabel('Primary Membership (u)');
zlabel('Secondary Membership (mu(x,u))');
title(sprintf('GT2 Fuzzy Membership Function for pixel (%d,%d)',i,j));

