function [snormal flag] = depth2sn(depth, flag)
% function [snormal flag] = depth2sn(depth, flag)
%
% Calculate surface normal map from depth map
% (Forward, backward, or symmetric approximation is selected based on 'flag' for differentiation)
%
% Common:
%     flag: Logical flag map      (n_y x n_x)
%
% Inputs:
%     depth: Depth map            (n_y x n_x)
%
% Outputs:
%     snormal: Surface normal map (n_y x n_x x 3)
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


[ysize xsize] = size(depth);
p = zeros(ysize, xsize);
q = zeros(ysize, xsize);

if nargin < 2
    flag = true(size(depth));

    p(:, 2:xsize-1) = (depth(:, 3:xsize)-depth(:, 1:xsize-2))/2;
    p(:, 1) = depth(:, 2) - depth(:, 1);
    p(:, xsize) = depth(:, xsize) - depth(:, xsize-1);

    q(2:ysize-1, :) = (depth(3:ysize, :)-depth(1:ysize-2, :))/2;
    q(1, :) = depth(2, :) - depth(1, :);
    q(ysize, :) = depth(ysize, :) - depth(ysize-1, :);
else
    emp = false(ysize, 1);
    tf = flag(:, 1:end-1) & flag(:, 2:end);
    ind = tf & ~[emp flag(:, 1:end-2)];
    p([ind emp]) = depth([emp ind]) - depth([ind emp]);
    ind = tf & ~[flag(:, 3:end) emp];
    p([emp ind]) = depth([emp ind]) - depth([ind emp]);
    ind = flag(:, 1:end-2) & flag(:, 2:end-1) & flag(:, 3:end);
    p([emp ind emp]) = (depth([emp emp ind]) - depth([ind emp emp]))/2;

    emp = false(1, xsize);
    tf = flag(1:end-1, :) & flag(2:end, :);
    ind = tf & ~[emp; flag(1:end-2, :)];
    q([ind; emp]) = depth([emp; ind]) - depth([ind; emp]);
    ind = tf & ~[flag(3:end, :); emp];
    q([emp; ind]) = depth([emp; ind]) - depth([ind; emp]);
    ind = flag(1:end-2, :) & flag(2:end-1, :) & flag(3:end, :);
    q([emp; ind; emp]) = (depth([emp; emp; ind]) - depth([ind; emp; emp]))/2;

    tf1 = (flag(:, 1:end-2) | flag(:, 3:end));
    tf2 = (flag(1:end-2, :) | flag(3:end, :));
    flag(:, 2:end-1) = flag(:, 2:end-1) & tf1;
    flag(2:end-1, :) = flag(2:end-1, :) & tf2;
end

temp = sqrt(p.^2+q.^2+1);
snormal = zeros(ysize, xsize, 3);
snormal(:, :, 1) = -p./temp;
snormal(:, :, 2) = -q./temp;
snormal(:, :, 3) = 1./temp;

if nargin == 2
    snormal(repmat(~flag, [1 1 3])) = 0;
end
    
end
