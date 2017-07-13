% Demo program for SIFR.
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



% **IMPORTANT: Model files have to be prepared in advance by running
% one of 'train_XX.m' scripts, after running 'preprocess.m' script.


clear; close all;


%im = rgb2gray(im2double(imread('lena.jpg')));
 
im = rgb2gray(im2double(imread('MinsikLee.jpg')));
coord = [69 127 103; 120 116 186]; 
% coord = [127 258 200; 256 247 372];  1754
%coord = [263 337 304; 271 272 364];

model_TR = load('model/TR');
% model_NIM = load('model/NIM');
% model_RR = load('model/RR');


tic;

% [depth flag] = recon_TR(im, coord, model_TR);
% [depth flag] = recon_NIM(im, coord, model_NIM);
[depth, flag] = recon_TR(im, coord, model_TR);


toc;

depth(~flag) = nan;
figure; surf(depth, im, 'LineStyle', 'none'); axis equal; axis off; colormap gray; view(-120, 60);

