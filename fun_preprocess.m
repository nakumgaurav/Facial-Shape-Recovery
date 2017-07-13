function data = fun_preprocess(files)

m_phi = numel(files);

% parameters
n_y = 120;      % y-size of training samples
n_x = 100;      % x-size of training samples
rpts = [22.7222 78.2778 50.5; 30.5 30.5 99.5];  % target coordinates for left eye, right eye, and mouth
penum = 2;      % penumbra parameter for soft cast shadow


load lightdir;
n_i = size(s, 2);    % value of 2*m_s
sind = s(3, :) > 0;  % all points on the upper half of the hemisphere

n_p = m_phi;

lp_option = optimset('Display', 'off');


disp('Calculating illumination samples and warping...');

F = false(n_y, n_x, n_p);
D = zeros(n_y, n_x, n_p);
S = zeros(n_y, n_x, 3, n_p);
H = zeros(n_y, n_x, 9, n_p);
I = zeros(n_y, n_x, sum(sind), n_p);
AH = zeros(n_y, n_x, n_p);
AI = zeros(n_y, n_x, n_p);
for i=1:numel(files)
    a = files{i};
    depth = a.depth; flag = a.flag; img = a.img; pts = a.pts;
    
    [ty, tx] = size(img);
    
    
    % synthesizing illumination samples
    [snormal, flag] = depth2sn(depth, flag);
    
    harm = zeros(ty, tx, 9);
    sx = snormal(:, :, 1);
    sy = snormal(:, :, 2);
    sz = snormal(:, :, 3);

    harm(:, :, 1) = flag;
    harm(:, :, 2:4) = snormal;
    harm(:, :, 5) = 3*sz.^2-1;
    harm(:, :, 6) = sx.*sy;
    harm(:, :, 7) = sx.*sz;
    harm(:, :, 8) = sy.*sz;
    harm(:, :, 9) = sx.^2-sy.^2;

    tI = reshape(harm, [], 9);
    L = pinv(tI(flag(:), :))*img(flag);
    albh = img./reshape(reshape(harm, [], 9)*L, ty, tx)/2;
    albh(isnan(albh)) = 0;
    albh(albh > 1) = 1;
    albh(albh < 0) = 0;
    albh(~flag) = 0;
    
    
    illum = zeros(ty, tx, n_i);
    for j=1:n_i
        illum(:, :, j) = plamb(depth, snormal, s(:, j), penum);
    end

    nsamp = 2e3;
    tF = find(flag(:));
    tF = tF(randperm(numel(tF)));
    tF = tF(1:nsamp);
    tI = reshape(illum, [], n_i);

    % Albedo calculation
    % Ref: Sungho Suh, Minsik Lee, and Chong-Ho Choi,
    % "Robust Albedo Estimation from a Facial Image with Cast Shadow under General, Unknown Lighting,"
    % IEEE Trans. Image Processing, vol. 22, no. 1, pp. 391-401, Jan. 2013.
    tY = img(tF);
    tI = tI(tF(:), :);
    E = eye(nsamp);
    L = linprog([zeros(n_i, 1); ones(nsamp, 1)]/nsamp, [-tI -E; tI -E; -eye(n_i) zeros(n_i, nsamp)], [-tY; tY; zeros(n_i, 1)], [], [], [], [], [], lp_option);
    albi = MMSE_alb(img, flag, reshape(illum, [], n_i), L(1:n_i), s);
    
    
    illum = illum(:, :, sind);
        
    
    % warping
    crop = [n_y n_x];
    G = get_affine_tr(rpts, pts);
    
    depth(~flag) = nan;
    temp = warp_img(depth, G, [n_y n_x]);
    FO = imerode(~isnan(temp), strel('diamond', 2));
    vFO = ~FO;    
    temp(vFO) = 0;
    tt = temp(FO);
    temp(FO) = tt - mean(tt);
    temp = temp/norm(diff(pts(:, 1:2), 1, 2));

    D(:, :, i) = temp;
    F(:, :, i) = FO;
    for j=1:3
        temp = warp_img(snormal(:, :, j), G, [n_y n_x]);
        temp(vFO) = 0;
        S(:, :, j, i) = temp;
    end
    for j=1:size(illum, 3)
        temp = warp_img(illum(:, :, j), G, [n_y n_x]);
        temp(vFO) = 0;
        I(:, :, j, i) = temp;
    end
    temp = warp_img(albh, G, crop);
    temp(vFO) = 0;
    AH(:, :, i) = temp;
    temp = warp_img(albi, G, crop);
    temp(vFO) = 0;
    AI(:, :, i) = temp;
    
    
    disp([num2str(i) ' / ' num2str(n_p) ' processed.']);
end


disp('Filling missing entries...');


F = reshape(F, [], n_p);
D = reshape(fill_nuclear(reshape(D, [], n_p), F, true), n_y, n_x, n_p);
disp('Depth done.');
AH = fill_nuclear(reshape(AH, [], n_p), F);
AH(AH < 0) = 0;
AH(AH > 1) = 1;
AH = AH./repmat(sqrt(mean(AH.^2)), size(AH, 1), 1);
disp('Albedo (spherical harmonics) done.');
AI = fill_nuclear(reshape(AI, [], n_p), F);
AI(AI < 0) = 0;
AI(AI > 1) = 1;
disp('Albedo (cast shadow) done.');

for i=1:3
    temp = fill_nuclear(reshape(S(:, :, i, :), [], n_p), F);
    if i == 3
        temp(temp < 0) = 0;
    else
        temp(temp < -1) = -1;
    end
    temp(temp > 1) = 1;
    S(:, :, i, :) = reshape(temp, n_y, n_x, 1, n_p);
    disp(['Snormal sample ' num2str(i) ' done.']);
end

Sx = S(:, :, 1, :);
Sy = S(:, :, 2, :);
Sz = S(:, :, 3, :);

H(:, :, 1, :) = 1;
H(:, :, 2:4, :) = S;
H(:, :, 5, :) = 3*Sz.^2-1;
H(:, :, 6, :) = Sx.*Sy;
H(:, :, 7, :) = Sx.*Sz;
H(:, :, 8, :) = Sy.*Sz;
H(:, :, 9, :) = Sx.^2-Sy.^2;
for i=1:9
    H(:, :, i, :) = reshape(reshape(H(:, :, i, :), size(AH)).*AH, n_y, n_x, 1, n_p);
end

n_i = size(I, 3);
for i=1:n_i
    temp = fill_nuclear(reshape(I(:, :, i, :), [], n_p), F);
    temp(temp < 0) = 0; temp(temp > 1) = 1;
    I(:, :, i, :) = reshape(temp.*AI, n_y, n_x, 1, n_p);
    disp(['Cast shadow sample ' num2str(i) ' done.']);
end




basic = {n_y, n_x, rpts};
pre = {D,H,I};


disp('Decomposing tensors...');


DM = mean(D, 3);
D = D - repmat(DM, [1 1 n_p]);
[DC, DU] = TensorDecomposition(D);
pre_DTD = {DM,DC,DU};
%clear DM DC DU;

[C, U] = TensorDecomposition(H); 
pre_H9TD = {C,U};
%clear C U;

[C, U] = TensorDecomposition(H(:, :, 1:4, :));
pre_H4TD = {C,U};
%clear C U;

M = mean(H, 4);
H = H - repmat(M, [1 1 1 n_p]);
[C, U] = TensorDecomposition(H); % C has same dimensions as H 
pre_H9TDM = {M,C,U};
%clear C U;

M = M(:, :, 1:4);
[C, U] = TensorDecomposition(H(:, :, 1:4, :));
pre_H4TDM = {M,C,U};
%clear C U;

[C, U] = TensorDecomposition(I);    
pre_ITD = {C,U};
%clear C U;

M = mean(I, 4);
I = I - repmat(M, [1 1 1 n_p]);
[C, U] = TensorDecomposition(I);
pre_ITDM = {M,C,U};
%clear C U;

data = {basic, pre, pre_DTD, pre_H9TD, pre_H4TD, pre_H9TDM, pre_H4TDM, pre_ITD, pre_ITDM};