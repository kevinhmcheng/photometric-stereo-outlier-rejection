% Perform Photometric Stereo Method on 'DiLiGent'
% based on the original code written by Boxin Shi and Neil Alldrin 

clc;
close all;
clear all;

%% Settings
testId = 1; %Object ID
option = 1; %Observations Selection Method 1: %IRF(RGB); 2: IRF(Gray) 3: Position T; 4:Darkest; 5:Brightest; 6:Nearest(RGB); 7:Nearest (Gray)
param = 20; %Number of Selected Observations p
iteration = 10; %Number of Iterations i
NumOfEqu = 1; %Number of Equations to be removed r
%iteration = min([param*(param-1)/2-3+1, 100]);
%%

%==========01=========%
dataNameStack{1} = 'ball';
%==========02=========%
dataNameStack{2} = 'cat';
%==========03=========%
dataNameStack{3} = 'pot1';
%==========04=========%
dataNameStack{4} = 'bear';
%==========05=========%
dataNameStack{5} = 'pot2';
%==========06=========%
dataNameStack{6} = 'buddha';
%==========07=========%
dataNameStack{7} = 'goblet';
%==========08=========%
dataNameStack{8} = 'reading';
%==========09=========%
dataNameStack{9} = 'cow';
%==========10=========%
dataNameStack{10} = 'harvest';

numData = numel(dataNameStack);
dataFormat = 'PNG';
dataDir = '..\..\pmsData';
resultDir = '..\..\estNormalNonLambert';
% Number of normals for each data
numPx = [15791,45200,57721,41512,35278,44864,26193,27654,26421,57342];
pMax = max(numPx);

dataName = [dataNameStack{testId}, dataFormat];
datadir = ['..\..\pmsData\', dataName];
bitdepth = 16;
gamma = 1;
resize = 1;  
data = load_datadir_re(datadir, bitdepth, resize, gamma); 

L = (data.s)';
f = size(L, 2);
[height, width, color] = size(data.mask);
if color == 1
    mask1 = double(data.mask./255);
else
    mask1 = double(rgb2gray(data.mask)./255);
end
mask3 = repmat(mask1, [1, 1, 3]);
m = find(mask1 == 1);
p = length(m);

%% Read I and Split RGB
I = zeros(p, f);
for i = 1 : f
    img = data.imgs{i};
    img = rgb2gray(img);    
    img = img(m);
    I(:, i) = img;
end

Irgb = zeros(p, f, 3);
for i = 1 : f
    img = data.imgs{i};
    for color = 1:3
        imgrgb = img(:,:,color);
        imgrgb = imgrgb(m);
        Irgb(:, i, color) = imgrgb;
    end
end

%% MAIN method
%I:NumOfPixel x NumOfImage
%I1: 1 x NumOfImage
%L: 3 x NumOfImage
S = zeros(size(I,1),3,iteration);
h1 = waitbar(0); 
for i = 1 : p
    tic
    S(i,:,:) = solve_n(I(i,:)',squeeze(Irgb(i,:,:)), L, param, option, NumOfEqu, iteration);
    waitbar(double(i/p), h1, ['Remaining time: ' num2str((p-i)*toc/60) 'min']);
end
close(h1);

%S: NumOfPixel x 3
%% END MAIN
%% Convert 1D mask normal to 2D normal
n_x = zeros(height*width, 1, iteration);
n_y = zeros(height*width, 1, iteration);
n_z = zeros(height*width, 1, iteration);
for i = 1 : p
    n_x(m(i),:, :) = S(i, 1, :);
    n_y(m(i),:, :) = S(i, 2, :);
    n_z(m(i),:, :) = S(i, 3, :);
end
n_x = reshape(n_x, height, width, iteration);
n_y = reshape(n_y, height, width, iteration);
n_z = reshape(n_z, height, width, iteration);
N = zeros(height, width, 3, iteration);
N(:, :, 1, :) = n_x;
N(:, :, 2, :) = n_y; 
N(:, :, 3, :) = n_z;
N(isnan(N)) = 0;

%% Comparison with ground truth
load([dataDir, '\', dataNameStack{testId}, dataFormat, '\', 'Normal_gt.mat']);
% Load masks
mask = im2bw(imread([dataDir, '\', dataNameStack{testId}, dataFormat, '\', 'mask.png']));
m = find(mask == 1);
N_gt = normal_img2vec(Normal_gt, m);

Err = zeros(1,iteration);
for param_i = 1:iteration
    Normal_est = N(:,:,:,param_i);
    N_est = normal_img2vec(Normal_est, m);
    angErr = real(acos(dot(N_gt, N_est, 2))) * 180 / pi;
    %Err(testId, param_i) = mean(angErr);
    Err(param_i) = mean(angErr);
end
[Err_final, Idx] = min(Err);

%% Save Mean Angular Error
save('Result.mat','Err_final')

%% Save "png"
imwrite(uint8((N(:,:,:,Idx)+1)*128).*uint8(mask3), strcat(dataName, '_Normal.png'));
