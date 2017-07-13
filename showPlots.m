function showPlots

load('partials.mat');

for i = 2:19
    j = 14;
    while(j<120)
        f_L = Fits_partial_4{i,j,1};
        f_U = Fits_partial_4{i,j,2};
        plotT1funcs(f_L,f_U,i,j);
        pause;
        j = j+10;
    end
end