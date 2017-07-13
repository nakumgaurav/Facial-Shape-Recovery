%% Compute the T values for each cluster found in preComputeT_1 

% Entire training set
files = dir('data/*.mat');
files = {files.name}';
m = numel(files);           % number of training samples

A = cell(m,1);
for i = 1:m
    A{i} = load(['data/' files{i}]);
end

load('clusters.mat');
% T(:,1) contains T_bar while T(:,2) contains T_tilda
T5 = cell(1,2);

%{
for i = 1:k
    temp = A(idx==i); 
    data = fun_preprocess(temp);
    [T{i,1}, T{i,2}] = fun_train_TR(data,numel(temp));
end

save('T.mat','T','idx','C');
%}
    temp = A(idx==5); 
    data = fun_preprocess(temp);
    [T5{1,1}, T5{1,2}] = fun_train_TR(data,numel(temp));
    
    save('T5.mat','T5');