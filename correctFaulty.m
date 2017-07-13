function Fits2 = correctFaulty(faulty)
load('pre_Fbar/basic');
% Determine the fixed number of data points (images) to delete each time
% Change this fraction if required
num_iter = 10;
num_images = size(Img,3);                           % number of images
pts_del = num_images/num_iter;                      % number of images to be deleted per iteration
num_pixels = size(Img,1)*size(Img,2);

Fits2 = cell(size(Img,1), size(Img,2), 2);

for k = 1:numel(faulty)
    pix = faulty{k};
    i = pix(1);
    j = pix(2);
    fprintf('\nPixel (%d,%d)\n',i,j);
    [~, ~, ~, f_L, f_U] = generateFits(Img(i,j,:), num_iter, pts_del, num_images);
    plotT1funcs(f_L, f_U, i, j);
    Fits2{i,j,1} = f_L; Fits2{i,j,2} = f_U;
end

%save('MFs.mat', 'Fits');