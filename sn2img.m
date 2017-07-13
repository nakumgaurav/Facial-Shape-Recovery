function image = sn2img(snormal, s, albedo)
% function image = sn2img(snormal, s, albedo)
%
% Render image (without cast shadow)
%
% Inputs:
%     snormal: Surface normal map
%     s: Light vector
%     albedo: Albedo map
%
% Outputs:
%     image: Output image
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


[ysize, xsize, ~] = size(snormal);

if nargin < 2,
    s=[0 0 1]';
end

image = reshape(reshape(snormal, [], 3)*s, ysize, xsize);
image(image < 0) = 0;

if nargin == 3
    image = albedo.*image;
end

end