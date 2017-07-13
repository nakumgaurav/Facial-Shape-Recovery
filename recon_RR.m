function [depth flag] = recon_RR(im, coord, model)
% function [depth flag] = recon_RR(im, coord, model)
%
% Reconstruct depth map using RR algorithm
%
% Inputs:
%     im: Input image         (n_y x n_x)
%     coord: left eye, right eye, and mouth coordinates (2 x 3)
%     model: Model data
%
% Outputs:
%     depth: Output depth map (n_y x n_x)
%     flag: Logical flag map  (n_y x n_x)
%
% Ref: [1] Minsik Lee and Chong-Ho Choi,
% "Real-time Facial Shape Recovery From a Single Image With General, Unknown Lighting by Rank Relaxation,"
% Computer Vision and Image Understanding, vol. 120, pp. 59-69, Mar. 2014.
% [2] Minsik Lee,
% "Facial Shape Recovery from a Single Image with General, Unknown Lighting,"
% Ph.D. dissertation, Seoul National University, 2012.
%
% Author: Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19
% License: GPLv3

%
% Copyright (C) 2014 Minsik Lee
% This file is part of SIFR.
%
% SIFR is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% SIFR is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SIFR.  If not, see <http://www.gnu.org/licenses/>.


th = 1e-6;

G = get_affine_tr(model.rpts, coord);
z = warp_img(im, G, [model.n_y model.n_x]);
z = model.Ui1'*z*model.Ui2;
z = model.Ui'*z(:);

H = reshape(model.Pv*z, model.nI(3:4));

p = model.Mi;
pp = zeros(size(p));
while mse(p-pp) > th
    pp = p;

    l = H*p;
    p = H'*l;
    p = p/norm(p);
end

Gv = inv([G; 0 0 1]);
depth = warp_img(model.Ud1*reshape(model.Ud*(model.Pc*(p*(model.nMi/(p'*model.Mi)))), model.nD(1:2))*model.Ud2' + model.Db, Gv(1:2, :), size(im))*norm(diff(coord(:, 1:2), 1, 2));
flag = ~isnan(depth);
flag = imerode(flag, strel('diamond', 2));
depth(~flag) = 0;

end


