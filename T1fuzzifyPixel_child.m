function [fPixel, status] = T1fuzzifyPixel_child(x,z,f_initial)
%%T1fuzzifyPixel_child is a replica of the T1fuzzifyPixel script. It is 
% used to repeat the process of pixel fuzzification process for the upper and 
% lower data points of the best fitted Gaussian to the original data
% x is the set of abscissae of the lower/upper data points
% z is the set of ordinates of the lower/upper data points

status = 1;
if(numel(x) < 3)
    fPixel = 0;
    status = 0;
    return;
end
z = smooth(z);
%% Step-1: Histogram Smoothing and Polynomial Fitting 

F = fit(x,z,'smoothingspline');
figure;
title('Polynomial Fit for Lower/Upper Data points');
h = plot(F,x,z);
hold on;
X = h(2).XData;
Y = h(2).YData;

%h  = hist_smoothen_ori(y);

% Remove duplicates
x_coord = X;  y_coord = Y;
[~, ind] = unique(x_coord);
x_coord = x_coord(ind);  y_coord = y_coord(ind);


%% Step-2: Find Prominent Peaks
% Find the location (& other parameters) of prominent peaks (lcs) and valleys
% using polyFit constraining the min peak prominence and min peak width
% parameters MP: Change the distance and width parameters if required

% Find peaks
[pks_max, lcs_max, w_max, p_max] = findpeaks(y_coord,x_coord,...
                              'MinPeakProminence',0.15, 'MinPeakWidth', 20);
peaks_max = cell(1,4);
signal = 1;
%FOR UNIMODAL:
[~, ind] = max(pks_max);
pks_max = pks_max(ind); lcs_max = lcs_max(ind);

% If no peaks and/or valleys have been found, it means the max/min of the
% polynomial occurs at the end points
if(~numel(pks_max))
    signal = 0;
    if(y_coord(1) > y_coord(end))
        pks_max = y_coord(1);
        lcs_max = x_coord(1);
    else
        pks_max = y_coord(end);
        lcs_max = x_coord(end);
    end
end


peaks_max{1} = pks_max; peaks_max{2} = lcs_max; 
peaks_max{3} = w_max; peaks_max{4} = p_max;
                                          
% Find valleys                                            
[pks_min, lcs_min, w_min, p_min] = findpeaks(-y_coord,x_coord,...
                              'MinPeakProminence',0.15, 'MinPeakWidth', 20);

if(~numel(pks_min))
    signal = 0;
    if(-y_coord(1) > -y_coord(end))
        pks_min = -y_coord(1);
        lcs_min = x_coord(1);
    else
        pks_min = -y_coord(end);
        lcs_min = x_coord(end);
    end
end
                       
peaks_min = cell(1,4);
peaks_min{1} = pks_min; peaks_min{2} = lcs_min; 
peaks_min{3} = w_min; peaks_min{4} = p_min;



% Plot the peaks & valleys
plot(lcs_max,pks_max,'ro',lcs_min,-pks_min,'bx');
legend('Data Points','Polynomial Fit', 'Maxima','Minima');
hold off;
%lim = max(abs(min(x_coord)), abs(max(x_coord)));
%xlim([-lim-1 lim+1]); ylim([min(y_coord)-10 max(y_coord)+10]);



%% Step-3: Initialize Gaussians
% Initialize the height, width and mean of the asymmetric Gaussians
%f = fitData_improved(x_coord', y_coord', peaks_max, peaks_min);
if(signal)
    try
        f = fitData_improved(x,z,peaks_max,peaks_min);
    catch
        load('default.mat');
        f = f1071;
    end
else
    try
        f = fit(x,z,'gauss1');
    catch
        try
            [~, mini] = min(x_coord); [~, maxi] = max(x_coord); 
            avg = mean([mini, maxi]);
            first = uint8(mean([mini,avg])) ;
            last = uint8(mean(avg,maxi)); 
            f = fit(x_coord(first:last)', y_coord(first:last)','gauss1');
        catch
            f = f_initial; 
        end
    end
end    
[a, b, c] = assignValues(f,numel(lcs_max));
initial_params = [a; b; c];
%fprintf('Initial Cost = %d',computeCost(initial_params, x_coord, y_coord));
fprintf('Initial Cost = %d',computeCost(initial_params, x, z));

% plot the initial Gaussian fit curve f on the data
%plotFit(f,x_coord',y_coord'); 
plotFit(f,x,z);
title('Initial Gaussian Fit');

% define legend
legend('Original Curve', 'Data Points', 'Initial Gaussian Fit');
hold off;

%% Step-4: Find Best Fit
% Use an optimisation algorithm to find the best Gaussian fit to the data.

options = optimset('LargeScale', 'on', 'GradObj', 'on', 'MaxFunEvals', ...
                    10000,'TolFun',1e-30, 'TolX',1e-30, 'MaxIter', 10000);
%[opt_params, cost, exitflag, output] = fminsearch(@(params)(computeCost(params, x_coord, y_coord)), ...
%                                               initial_params, options);
[opt_params, cost, exitflag, output] = fminsearch(@(params)(computeCost(params, x, z)), ...
                                               initial_params, options);

f = assignParams(f,opt_params);

%plotFit(f,x_coord',y_coord'); 
plotFit(f,x,z); 
hold off;
%title(sprintf('Best Gaussian Fit for Pixel (%d,%d)',i,j));
legend('Original Curve','Data Points', 'Best Gaussian Fit');
xlabel('Pixel Intensities'); ylabel('Normalised Frequency (No. of Images)');
ylim([min(y_coord)-0.2 max(y_coord) + 0.2]);
fprintf('Min Cost = %d\nExit Status:%d\n\n', cost, exitflag);

fprintf('Program paused. Press enter to continue\n\n');
%pause;
close all;

fPixel = f;
