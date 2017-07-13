function [Fl, Fm, Fu, f_L, f_U] = generateFits(y, num_iter, pts_del, num_images)

Fl = cell(1,num_iter); Fm = cell(1,num_iter); Fu = cell(1,num_iter);
Al = zeros(num_iter,1); Au = zeros(num_iter,1);
close all;
for k = 1:num_iter
    fprintf('\nITERATION NUMBER %d\n',k);
    del_this = randi(num_images,[pts_del, 1]);  % indices of the elements to be deleted in this iteration 
    tempI = squeeze(y);                         % tempI is the truncated image data
    tempI(del_this) = [];                   
    tempF = findFreq(tempI);                    % tempF is the truncated frequency data
    [Fl{k}, Fm{k}, Fu{k}] = T1fuzzifyPixel_ori(tempI,tempF);
    [Fl{k}, Fu{k}] = normalizeFits(Fl{k}, Fu{k});
    Al(k) = Fl{k}.a1; Au(k) = Fu{k}.a1;
end
hold off;
[~, l_ind] = min(Al); [~, u_ind] = max(Au);
f_L = Fl{l_ind}; f_U = Fu{u_ind};
%f_L = improveFits(Al,Fl,f_L,f_U,num_iter);