function [f_lower, f_middle, f_upper] = T1fuzzifyPixel_poly(y_us,z)
%%T1fuzzifyPixel generates the FOU for a single pixel of all images

x = (0:1:255)';
freq_normal = z/max(z);
freq_normal = smooth(freq_normal);
cla reset;

%% Step-1: Histogram Smoothing and Polynomial Fitting 
% Smoothen y
y = smooth(y_us);

% polyFit is the polynomial fitted to the histogram of the data
polyFit  = hist_smoothen_poly(y);

% Remove duplicates
x_coord = polyFit(1,:);
y_coord = polyFit(2,:);
[~, ind] = unique(x_coord);
clear polyFit;
polyFit(1,:) = x_coord(ind);  
polyFit(2,:) = y_coord(ind);
x_coord = polyFit(1,:);
y_coord = polyFit(2,:);


%% Step-2: Find Prominent Peaks
% Find the location (& other parameters) of prominent peaks (lcs) and valleys
% using polyFit constraining the min peak prominence and min peak width
% parameters MP: Change the distance and width parameters if required

% Find peaks
[pks_max, lcs_max, w_max, p_max] = findpeaks(y_coord,x_coord,...
                              'MinPeakProminence',0.2, 'MinPeakWidth', 10);
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
                              'MinPeakProminence',0.2, 'MinPeakWidth', 10);
                          
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
legend('Histogram','Polynomial Fit', 'Maxima','Minima');
hold off;
%lim = max(abs(min(x_coord)), abs(max(x_coord)));
%xlim([-lim-1 lim+1]); ylim([min(y_coord)-10 max(y_coord)+10]);


%% Step-3: Initialize Gaussians
% Initialize the height, width and mean of the symmetric Gaussians

try
    if(signal)
        f = fitData_improved(x_coord', y_coord', peaks_max, peaks_min); 
    else
        f = fit(x_coord', y_coord','gauss1');
    end
catch
    [~, mini] = min(x_coord); [~, maxi] = max(x_coord);
    avg = mean([mini, maxi]);
    first = uint8(mean([mini,avg])) ;
    last = uint8(mean(avg,maxi)); 
    f = fit(x_coord(first:last)', y_coord(first:last)','gauss1');
end
[a, b, c] = assignValues(f,numel(lcs_max));
initial_params = [a; b; c];
fprintf('Initial Cost = %d',computeCost(initial_params, x_coord, y_coord));


% plot the initial fitting curve f on the data
 plotFit(f,x_coord',y_coord');                   % Polynomial and its Gaussian Fit
 plot(x,freq_normal); plot(f,x,freq_normal);     % Original Curve and its Gaussian Fit
 
 title('Initial Gaussian Fit');

% define legend
legend('Polynomial Curve', 'GF to Polynomial', 'Original Curve','Gaussian Fit to Ori', 'Data Points');
hold off;

%% Step-4: Find Best Fit
% Use an optimisation algorithm to find the best Gaussian fit to the data.

% Try Gradient Descent
%{
[f, J_history] = gradientDescent(x_coord,y_coord, f, numel(lcs_max));
plotFit(f,x_coord',y_coord');
J_history;
plot(J_history);
%}

% Try fminsearch
options = optimset('LargeScale', 'on', 'GradObj', 'on', 'MaxFunEvals', ...
                    10000,'TolFun',1e-30, 'TolX',1e-30, 'MaxIter', 10000);
[opt_params, cost, exitflag, output] = fminsearch(@(params)(computeCost(params, x_coord, y_coord)), ...
                                              initial_params, options);

f = assignParams(f,opt_params);

plotFit(f,x_coord',y_coord'); 
plot(x,freq_normal); plot(f,x,freq_normal);
hold off;
title('Best Gaussian Fit');
legend('Polynomial Curve', 'GF to Polynomial', 'Original Curve','Gaussian Fit to Ori', 'Data Points');
%ylim([min(y_coord)-0.2 max(y_coord) + 0.2]);

fprintf('Min Cost = %d\nExit Status:%d\n\n', cost, exitflag);

fprintf('Program paused. Press enter to continue\n\n');
pause;
close all;



%% Step-5: Extract upper and lower data and construct their Gaussians

% UPPER AND LOWER GAUSSIANS USING POLYNOMIAL DATA

% Indices where raw data </> predicted value (from the Gaussian fit)
lower_ind = find(y_coord'<f(x_coord));
upper_ind = find(y_coord'>f(x_coord));

% Define upper and lower data using these indices
x_lower = x_coord(lower_ind); y_lower = y_coord(lower_ind);
x_upper = x_coord(upper_ind); y_upper = y_coord(upper_ind);

% Find best fit to the lower data
[f_lower, status_lower] = T1fuzzifyPixel_child(x_lower', y_lower');

% if no lower data
if(~status_lower)
    f_lower = f;
end

% Find best fit to the upper data
[f_upper, status_upper] = T1fuzzifyPixel_child(x_upper', y_upper');

% if no upper data
if(~status_upper)
    f_upper = f;
end
f_middle = f;

% Plot the results
figure;

plot(x,freq_normal,'r');          
hold on;
%plot(f_middle,'m');
plot(f_lower,'g');
plot(f_upper,'b');

xlabel('Pixel Intensities');
ylabel('Normalised Frequency');
legend('Complete Original Curve', 'Lower Gaussian','Upper Gaussian');
% 'Middle Gaussian',
hold off;

pause;
close all;
