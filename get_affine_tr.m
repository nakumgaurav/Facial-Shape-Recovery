function H = get_affine_tr(X, Y)
% Calculate affine transform
%
% Inputs:
%     X: 2D Input coordinates
%     Y: 2D Output coordinates
%
% Outputs:
%     H: Affine transform
%
% Implemented by Minsik Lee (mlee.paper@gmail.com)
% Last update: 2014-03-19


H = Y*pinv([X; ones(1, size(X, 2))]);

end
