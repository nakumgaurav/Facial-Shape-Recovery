load('pre_Fbar/basic');

%% Step-1: Polynomial Fitting 
% Remove redundant singleton dimensions
y = squeeze(Img(10,71,:))';
% Normalize y
y = zscore(y);
% Plot the histogram of the data
hist(y);
% polyFit is the polynomial fitted to the histogram of the data
polyFit = hist_smoothen(y);


%% Step-2: Find Prominent Peaks
% Find the location (& other parameters) of prominent peaks (lcs) using freqS 
% constraining the min peak height, min peak distance and min peak width 
% parameters MP: Change the distance and width parameters if required
[pks, lcs, w, p] = findpeaks(freqS, x,'MinPeakHeight',0.002, ...
                            'MinPeakDistance', 30, 'MinPeakWidth', 5);
peaks = cell(1,4);
peaks{1} = pks; peaks{2} = lcs; peaks{3} = w; peaks{4} = p;