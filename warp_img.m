function result = warp_img(img, T, crop)
% function result = warp_img(img, T, crop)
%
% Perform image warping
%
% Inputs:
%     img: Input image
%     T: Transform matrix (2 x 3)
%     crop: Size of output image
%
% Outputs:
%     result: Output image
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


[XI, YI] = meshgrid(1:crop(2), 1:crop(1));
CI = [XI(:) YI(:) ones(numel(XI), 1)] * T';  
XI(:) = CI(:, 1);
YI(:) = CI(:, 2);
% The above 4 lines effectively apply affine transformation to every
% coordinate of the n_y x n_x to be cropped (not yet cropped though) image
% This  is done to map each part of the face in the cropped image to 
% its corresponding part in the original sized image.

n_c = size(img, 3);  % n_c = 1
result = zeros([crop n_c]);
for i=1:n_c
    result(:, :, i) = interp2(img(:, :, i), XI, YI);  % Vq = interp2(V,Xq,Yq) : interpolation
    % Given the values of pixel intensity at a set of locations in the orignal image,
    % interpolate them to get the pixel intensity values at some intermediate
    % coordinates.
end

end