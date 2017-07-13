function f_M = findBestFit(i,j)
%%Find best fit for pixel (i,j)
load('pre_Fbar/basic.mat');
[~, f_m, f_u] = T1fuzzifyPixel_ori(squeeze(Img(i,j,:)), squeeze(freq(i,j,:)));
%close all;
x = (0:1:255)';
scale = 1/max(f_u(x));
z_M = f_m(x) * scale;
f_M = fit(x,z_M,'gauss1');