% Preprocessing script for SIFR.
%
% Authors: Minsik Lee (mlee.paper@gmail.com)
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



% **IMPORTANT: Store Data files (in matlab data format) in 'data' directory.
% Each data file should contain;
%     img: Image             (n_y x n_x)
%     depth: Depth map       (n_y x n_x)
%     flag: Logical flag map (n_y x n_x)
%     pts: Coordinates of left eye, right eye, and mouth (2 x 3),
% of each person.
% If the depth map is very noisy/has some holes, it is better to perform
% smoothing/fill the holes before running this script.


clear; close all;


% parameters
n_y = 120;      % y-size of training samples
n_x = 100;      % x-size of training samples
rpts = [22.7222 78.2778 50.5; 30.5 30.5 99.5];  % target coordinates for left eye, right eye, and mouth


load lightdir;
n_i = size(s, 2);    % value of 2*m_s
sind = s(3, :) > 0;  % all points on the upper half of the hemisphere

files = dir('data/*.mat');
files = {files.name}';
n_p = numel(files);

lp_option = optimset('Display', 'off');


disp('Calculating illumination samples and warping...');

F = false(n_y, n_x, n_p);
D = zeros(n_y, n_x, n_p);
S = zeros(n_y, n_x, 3, n_p);    
H = zeros(n_y, n_x, 9, n_p);    % = Q 
I = zeros(n_y, n_x, sum(sind), n_p);
AH = zeros(n_y, n_x, n_p);
AI = zeros(n_y, n_x, n_p);

save pre/basic n_y n_x rpts;
save pre/D D;
save pre/H H;
save pre/I I -v7.3;


disp('Decomposing tensors...');


DM = mean(D, 3);
D = D - repmat(DM, [1 1 n_p]);
[DC, DU] = TensorDecomposition(D);
save pre/DTD DM DC DU;
clear DM DC DU;

[C, U] = TensorDecomposition(H);
save pre/H9TD C U;
clear C U;

[C, U] = TensorDecomposition(H(:, :, 1:4, :));
save pre/H4TD C U;
clear C U;

M = mean(H, 4);                 % Surely M is F_bar
H = H - repmat(M, [1 1 1 n_p]); 
[C, U] = TensorDecomposition(H);
save pre/H9TDM M C U;
clear C U;

M = M(:, :, 1:4);
[C, U] = TensorDecomposition(H(:, :, 1:4, :));
save pre/H4TDM M C U;
clear M C U;

[C, U] = TensorDecomposition(I);
save pre/ITD C U -v7.3;
clear C U;

M = mean(I, 4);
I = I - repmat(M, [1 1 1 n_p]);
[C, U] = TensorDecomposition(I);
save pre/ITDM M C U -v7.3;
clear M C U;

disp('done.');

