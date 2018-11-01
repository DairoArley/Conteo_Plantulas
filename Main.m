close all; clear all; clc;
%% %%%%%%%%%%%%%%%%%%%%%%%% Cargar Video  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileNameVideo = "DJI_0058.MP4";
pathRoot = "Sources/Video/";
fullName = pathRoot + fileNameVideo;
movie = VideoReader(fullName);
n = movie;
%%
%%%%%%%%%%%%%%%%%%%%%%%% Guardar Imágenes %%%%%%%%%%%%%%%%%%%%%%%%%%%
% i = 1;
% while hasFrame(movie)
%     imagen = readFrame(movie);     
%     imwrite(imagen , sprintf('Sources/Photos/Imagen%d.png', i), 'png');
%     i = i+1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stitching %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reading all three images
F = imread('Sources/Photos/Imagen130.png');
S = imread('Sources/Photos/Imagen120.png');
V = imread('Sources/Photos/Imagen110.png');
% Girar Imagenes
F = imrotate(F, 90);
figure,
imshow(F);
S = imrotate(S, 90);
figure,
imshow(S);
V = imrotate(V, 90);
figure,
imshow(V);
%Converting color images to Grayscale
F = im2double(rgb2gray(F));
S = im2double(rgb2gray(S));
V = im2double(rgb2gray(V));
[rows, cols] = size(F);
Tmp = [];
Tmp1 = [];
temp = 0;
% Saving the patch(rows x 5 columns) of second(S) & third(V) images in    
% S1 & V1 resp for future use.
for i = 1:rows
    for j = 1:5
        S1(i,j) = S(i,j);
        V1(i,j) = V(i,j);
    end
end
% Performing Correlation i.e. Comparing the (rows x 5 column) patch of 
% first image with patch of second image i.e. S1 saved earlier.
for k = 0:cols-5 % (cols - 5) prevents j from going beyond boundary of image.
    for j = 1:5
        F1(:,j) = F(:,k+j);% Forming patch of rows x 5 each time till cols-5.
    end
    temp = corr2(F1,S1);% comparing the patches using correlation.
    Tmp = [Tmp temp]; % Tmp keeps growing, forming a matrix of 1*cols
    temp = 0;
end
[Min_value, Index] = max(Tmp);% Gets the Index with maximum value from Tmp.
% Determining the number of columns of new image. Rows remain the same.
n_cols = Index + cols - 1;
Opimg = [];
for i = 1:rows
    for j = 1:Index-1
        Opimg(i,j) = F(i,j);% First image is pasted till Index.
    end
    for k = Index:n_cols
        Opimg(i,k) = S(i,k-Index+1);%Second image is pasted after Index.
    end    
end
[r_Opimg c_Opimg] = size(Opimg);
% Performing Correlation i.e. Comparing the (rows x 5 column) patch of 
% second image with patch of third image i.e. V1 saved earlier.
for k = 0:c_Opimg-5% to prevent j to go beyond boundaries.
    for j = 1:5
        Opimg1(:,j) = Opimg(:,k+j);% Forming patch of rows x 5 each time till cols-5.
    end
    temp = corr2(Opimg1,V1);% comparing the patches using correlation.
    Tmp1 = [Tmp1 temp]; % Tmp keeps growing, forming a matrix of 1*cols
    temp = 0;
end
% Determining the size of third image for future use.
[r_V, c_V] = size(V);
[Min_value, Index] = max(Tmp1);
% Determining new column for final stitched image.
% Rows remain the same.
n_cols = Index + c_V - 1;
Opimg1 = [];
for i = 1:rows
    for j = 1:Index-1
        Opimg1(i,j) = Opimg(i,j);% Previous stitched image is pasted till new Index.
    end
    for k = Index:n_cols
        Opimg1(i,k) = V(i,k-Index+1);%Third image is pasted after new Index.
    end    
end
% Determining the size of Final Stitched image.
[r_Opimg c_Opimg] = size(Opimg1);

figure,
imshow(Opimg1);
% imwrite(Opimg1, sprintf('Sources/Stitching%d.png', i), 'png');
% imwrite(F, sprintf('Sources/Third%d.png', i), 'png');
% imwrite(S, sprintf('Sources/Second%d.png', i), 'png');
% imwrite(V, sprintf('Sources/First%d.png', i), 'png');