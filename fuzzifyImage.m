function I_memb = fuzzifyImage(img)
%%fuzzifyImage returns a fuzzy membership matrix for the image img

% prob(i) stores the probability of occurence of intensity i in image 
freq = zeros(1,256);
% range of grayscale pixel intensity
x = 0:1:255;
% total number of pixels in the image
N = numel(img);
 
% input image is in double precsion, convert it to range [0 255] 
img = uint8(img * 255);

% find the frequency (normalized) of each pixel intensity from 0 to 255
for i = 1:256
    freq(i) = numel(find(img == i-1))/N;
end

% Smoothen the plot of freq
freqS = smooth(freq)';

% Find the location (& other parameters) of prominent peaks (lcs) using freqS 
% constraining the min peak height, min peak distance and min peak width 
% parameters MP: Change the distance and width parameters if required
[pks, lcs, w, p] = findpeaks(freqS, x,'MinPeakHeight',0.002, ...
                            'MinPeakDistance', 30, 'MinPeakWidth', 5);
peaks = cell(1,4);
peaks{1} = pks; peaks{2} = lcs; peaks{3} = w; peaks{4} = p;

% Construction of the fitting curve (Gaussian) f
f = fitData(x', freqS', peaks);
clc;

y_original = freqS';
y_fitted = f(x);
data = [y_original y_fitted];

LMF = min(data,[],2);
UMF = max(data,[],2); 

I_memb = zeros([size(img),2]);

I_memb(:,:,1) = reshape(LMF(img(:)+1),size(img));
I_memb(:,:,2) = reshape(UMF(img(:)+1),size(img));

% figure; plot(y_original); figure; plot(y_fitted);
%{
for i = 1:size(img,1)
    for j = 1:size(img,2)
        k = img(i,j);
        I_memb(i,j,1) = LMF(k);
        I_memb(i,j,2) = UMF(k);
    end
end
%}

figure; plot(x,smooth(LMF)); hold on; plot(x,smooth(UMF)); legend('LMF', 'UMF');  



% MP in the code above suggests "modifications possible"