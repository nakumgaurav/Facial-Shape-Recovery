function plotFit(f,x,y)
figure;
plot(x,y,'-'); 
hold on;
plot(f,x,y);
xlabel('Pixel Intensities');
ylabel('Normalised Frequency');
