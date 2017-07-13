function I_memb = FHE(img)
%%FHE (Fuzzy Histogram Equalization) creates the histogram plot
%%corresponding to the input image img

% prob(i) stores the probability of occurence of intensity i in image 
prob = zeros(256,1);
% total number of pixels in the image
N = numel(img);
 
for i = 1:256
    % See if you need to divide this expression by N 
    prob(i) = numel(find(img == i-1));
end

