files = dir('data/*.mat');
files = {files.name}';
m = numel(files);

A = load(['data/' files{1}]);
sz = size(A.img);
Img = zeros(sz(1), sz(2), m);
Img_double = zeros(sz(1), sz(2), m);

% Img(i,j,k) is the intensity of the (i,j)th pixel in the kth image
for i = 1:m
    temp = load(['data/' files{i}]);
    Img_double(:,:,i) = temp.img;
    Img(:,:,i) = uint8(temp.img * 255);
end

freq = zeros(sz(1),sz(2),256);

% freq(i,j,k) equals the number of images with intensity k-1 at the (i,j)th
% pixel
for pix_i = 1: sz(1)
    for pix_j = 1:sz(2)
        freq(pix_i,pix_j,:) = findFreq(Img(pix_i,pix_j,:));
    end
end

save pre_Fbar/basic freq Img Img_double