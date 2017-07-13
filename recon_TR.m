function [depth, flag] = recon_TR(im, coord, model)
% function [depth, flag] = recon_TR(im, coord, model)
%
% Reconstruct depth map using TR algorithm
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
% "Fast Facial Shape Recovery From a Single Image With General, Unknown Lighting by Using Tensor Representation,"
% Pattern Recognition, vol. 44, no. 7, pp. 1487-1496, Jul. 2011.
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


th = 1e-4;  % th (threshold) denotes epsilon 

G = get_affine_tr(model.rpts, coord); % rpts are the coordiantes of the eyes and mouth (in the training data) which when affine transformed give coord
z = warp_img(im, G, [model.n_y model.n_x]); % crops the image so that only the front facial part remains - eyes and mouth
z = model.Ui1' * z * model.Ui2 / sqrt(mse(z(:)));  % Ui1 = Ux     Ui2 = Uy   The LHS z = L of paper  
z = model.Ui' * z(:); % Ui = Uc (In 2014 paper, see page 63, the Q'I eqn just before section 4) LHS z = I' in paper

p = zeros(model.nI(4), 1);    % phi (personal identity vector)
l = zeros(model.nI(3), 1);    % s (light condition vector)
pl = ones(size(l));           % s_p (temp value of s used in iteration)
while mse(l,pl) > th          % repeat until ||s - s_p|| > th
    pl = l;                   % set s_p as s 

    temp = Nproduct(model.Pt, p', 3) + model.Mt;           % temp = V / T      model.Mt = R / T_bar      model.Pt = S / T_tilda
    l = (temp' * temp)\(temp' * z);                        % leftDivision: A \ B = X is equivalent to solving A*X = B or inv(A)*B (See Wolfram Pseudo-Inverse) 
    
    temp = squeeze(Nproduct(model.Pt, l', 2));             % temp = W  / F     squeeze removes singleton dimensions
    p = (temp'*temp + model.Rv)\(temp'*(z - model.Mt*l));  % model.Rv = inverse of Cphi      
end             

Gv = inv([G; 0 0 1]);                                      % Gv denotes the inverse affine transformation                
depth = warp_img(model.Ud1 * reshape(model.Ud * model.Pc * p, model.nD(1:2)) * model.Ud2' + model.DM, ...  % image  
                 Gv(1:2, :), ...                                                                           % Transformation Matrix (Inverse Affine)
                 size(im)) ...                                                                             % (new) cropping coordinates
                 * norm(diff(coord(:, 1:2), 1, 2) );                                                       % distance between left eye center and right eye center                  
flag = ~isnan(depth);
flag = imerode(flag, strel('diamond', 2)); % https://www.cs.auckland.ac.nz/courses/compsci773s1c/lectures/ImageProcessing-html/topic4.htm 
depth(~flag) = 0;                          % https://www.mathworks.com/help/images/ref/strel-class.html?searchHighlight=strel&s_tid=doc_srchtitle
                                           % http://www.mathworks.com/help/images/ref/imerode.html
end