%% Cluster the images in the training set using k-means

% Entire training set
files = dir('data/*.mat');
files = {files.name}';
m = numel(files);           % number of training samples

A = cell(m,1);
for i = 1:m
    A{i} = load(['data/' files{i}]);
end

width = size(A{1}.img,1);    % image width
height = size(A{1}.img,2);   % image height
num_pixels = width*height;

% X is the data matrix for kmeans
X = zeros(m,num_pixels);
for i = 1:m
    temp = A{i}.img;
    X(i,:) = (temp(:))';
end

% show only the final output
opts = statset('Display','iter');
% number of clusters
k = 5;

% first try euclidean distance (use 3 initializations)
%[idx, C] = kmeans(X,k,'Replicates',3,'Options',opts);

% then try Manhattan distance (use 3 initializations)
 [idx, C] = kmeans(X,k,'Distance','cityblock','Replicates',3,'Options',opts);

% idx will be a m x 1 vector of cluster indices assigned to each image while C will be a m x num_pixels matrix of
% cluster centroids

% For euclidean distance
%save('clusters.mat','idx','C');

% For Manhattan distance
save('clustersM.mat','idx','C');