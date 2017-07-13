function alb = MMSE_alb(img, flag, W, L, s)
% function alb = MMSE_alb(img, flag, W, L, s)
%
% MMSE filtering for albedo calculation
%
% Inputs:
%     img: Image             (n_y x n_x)
%     flag: Logical flag map (n_y x n_x)
%     W: Illumination basis  ((n_y n_x) x n_i)
%     L: Light intensities   (n_i x 1)
%     s: Light directions    (3 x n_i)
%
% Outputs:
%     alb: Albedo map        (n_y x n_x)
%
% Ref: Sungho Suh, Minsik Lee, and Chong-Ho Choi,
% "Robust Albedo Estimation from a Facial Image with Cast Shadow under General, Unknown Lighting,"
% IEEE Trans. Image Processing, vol. 22, no. 1, pp. 391-401, Jan. 2013.
%
% Author: Sungho Suh (sh86.suh@samsung.com), Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19
% License: GPLv3


e1 = 0.01;
e2 = 0.03;


rho = zeros(numel(img), 1);
illum = W*L;

if nargin == 5
    T = s.*(ones(3, 1)*L');
    Eill = sum(((W > 0)*T').^2, 2) - illum.^2;
else
    Eill = 2/3*max(illum)^2;
end
illum = illum + div_elem(e1 + e2*Eill, illum);

rho(flag(:)) = div_elem(img(flag(:)), illum(flag(:)));

alb = reshape(rho, size(img))/2;
alb(alb > 1) = 1;
alb(alb < 0) = 0;
alb(~flag) = 0;

end

function M = div_elem(N, D)

M = N./D;
M(isnan(M)) = 0;

end
