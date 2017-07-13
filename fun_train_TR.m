function [T_bar, T_tilda] = fun_train_TR(data,m_phi)

% parameters
source = 9; 
if strcmp(source, 'cast')
    nI = [40 30 10 min(m_phi,150)]; % [n_y',  n_x',  n_l',  n_phi'] [ny, nx, ns, nphi]     
    nQ = 400;                       % number of column vectors of Q = np
else
   nI = [40 30 source min(m_phi,80)];   % [n_y',  n_x',  n_l',  n_phi'] [ny, nx, ns, nphi]         
   nQ = 200;                       % np = 200
end

nQ = min(nQ, prod(nI(1:2)));

% illumination model
switch source
    case 4
        M = data{7}{1}; C = data{7}{2}; U = data{7}{3};
    case 9
        M = data{6}{1}; C = data{6}{2}; U = data{6}{3};
    case 'cast'
        M = data{9}{1}; C = data{9}{2}; U = data{9}{3};
end

[C, U] = TensorTrim(C, U, nI);      % C - Core Tensor of Eq . 2 (2011 paper) and U is a cell array containing 
                                    % the 4 mode matrices Uy, Ux, Ul, Up (Ux, Uy, Us, Uphi)
                                    % U:120x40, 100x30, 9x9, 500x80
C = reshape(C, [], prod(nI(3:4)));  % C is now a 1200 x 1500(720) matrix = Uc * Lambdac * Vc'
[Ui, S] = eig(C*C');                % Ui has the singular vectors of C, while S stores (the squares of) C's 
                                    % singular values
[~, ind] = sort(diag(S), 'descend');    %(Ui:1200x1200  S:1200x1200)
Ui = Ui(:, ind(1:nQ));              % Ui contains the singular vectors of C such that their corresponding e.values are in decreasing order
                                    % Ui = Uc;  Ui = 1200x200 
Pt = reshape(Ui'*C, [nQ nI(3:4)]);  % T_tilda: 200x10x150 (200x9x80)4 
temp = M;                           % M is F_bar (calculated in preprocess.m): 120x100x9        
for i=1:3
    temp = Nproduct(temp, U{i}', i); % U{3} = Us (2014)
end                                  % temp = F_bar x1 Uy x2 Ux x3 Us:40x30x9
Mt = Ui' * reshape(temp, [], nI(3)); % Mt is T_bar: 200x9

T_bar = Mt;
T_tilda = Pt;
