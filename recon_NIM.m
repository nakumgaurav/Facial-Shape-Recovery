function [depth flag] = recon_NIM(im, coord, model)
% function [depth flag] = recon_NIM(im, coord, model)
%
% Reconstruct depth map using NIM algorithm
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
% Ref: Minsik Lee and Chong-Ho Choi,
% "A Robust Real-Time Algorithm for Facial Shape Recovery From a Single Image Containing Cast Shadow Under General, Unknown Lighting,"
% Pattern Recognition, vol. 46, no. 1, pp. 38-44, Jan. 2013.
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


G = get_affine_tr(model.rpts, coord);
z = warp_img(im, G, [model.n_y model.n_x]);
z = model.Ui1'*z*model.Ui2;
z = model.Ui'*z(:);

z = hyperspherical(z);

Gv = inv([G; 0 0 1]);
depth = warp_img(model.Ud1*reshape(model.Ud*(model.Pc*z), model.nD(1:2))*model.Ud2' + model.Db, Gv(1:2, :), size(im))*norm(diff(coord(:, 1:2), 1, 2));
flag = ~isnan(depth);
flag = imerode(flag, strel('diamond', 2));
depth(~flag) = 0;

end


