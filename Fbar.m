load('pre_Fbar/basic');
% Determine the fixed number of data points (images) to delete each time
% Change this fraction if required
num_iter = 10;
num_images = size(Img,3);                           % number of images
pts_del = num_images/num_iter;                      % number of images to be deleted per iteration
num_pixels = size(Img,1)*size(Img,2);


% Fits{i,j,1} stores the lower membership function of the (i,j)th pixel,
% while Fits{i,j,2} stores its upper membership function
Fits = cell(size(Img,1), size(Img,2), 2);

%for i = 1:size(Img,1)
 for i = 51:89
%    for j = 1:size(Img,2)
     for j = 14:size(Img,2)
        fprintf('\nPixel (%d,%d)\n',i,j);
        [Fl, Fm, Fu, f_L, f_U] = generateFits(Img(i,j,:), num_iter, pts_del, num_images);
        
        %{
        for k = 1:num_iter
            [f_l, f_u] = normalizeFits(Fl{k}, Fu{k});
            plot(f_l,'r');
            if(k==1)
                hold on; 
            end
            plot(f_u,'g'); 
        end
        %}
   
        plotT1funcs(f_L, f_U, i, j);
        Fits{i,j,1} = f_L; Fits{i,j,2} = f_U;
    end
end

save('MFs.mat', 'Fits');

 