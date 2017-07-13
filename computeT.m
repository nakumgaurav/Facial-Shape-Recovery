function [T_bar, T_tilda] = computeT(img)
%%Compute the T value of an image using the clustering approach

load('T.mat');
temp = img(:);
S = temp - C';

% Find the index of the cluster to which the test image belongs
[~, ind] = min(sqrt(sum(S.^2))); 

% Assign the T value of that cluster to the test image
T_bar = T{ind,1};
T_tilda = T{ind,2};