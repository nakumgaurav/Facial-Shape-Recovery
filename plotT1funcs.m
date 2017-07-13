function plotT1funcs(f_L,f_U,i, j)
figure; 
%load('MFs.mat');
%f_L = Fits{i,j,1};
%f_U = Fits{i,j,2};
plot(f_L, 'r'); 
hold on; 
plot(f_U, 'g'); 
xlim([0 255]);
ylim([0 1]);
hold off; 
%close 1;
        
title(sprintf('Primary Membership Functions for pixel (%d,%d)',i,j));
xlabel('Pixel Intensities (x)'); 
ylabel('Frequency (u)');
legend('LMF','UMF');