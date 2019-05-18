clear all;
clc;
addpath('functions');

image = 'planetearth2c';
scaling_method = 'nearest';

% Read file
in_file_1 = strcat('..\img\pre_scaled\',image,'\',image,'_rgb_360.png');
in_file_2 = strcat('..\img\pre_scaled\',image,'\',image,'_rgb_540.png');
in_file_3 = strcat('..\img\pre_scaled\',image,'\',image,'_rgb_720.png');

rgb_1 = imread(in_file_1);
rgb_2 = imread(in_file_2);
rgb_3 = imread(in_file_3);

% Matlab scaling
scaled_1 = imresize(rgb_1, 1080/360, scaling_method, 'Antialiasing', false);
scaled_2 = imresize(rgb_2, 1080/540, scaling_method, 'Antialiasing', false);
scaled_3 = imresize(rgb_3, 1080/720, scaling_method, 'Antialiasing', false);

% Store file
out_file_1 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_360_to_1080.png');
out_file_2 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_540_to_1080.png');
out_file_3 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_720_to_1080.png');

imwrite(scaled_1, out_file_1);
imwrite(scaled_2, out_file_2);
imwrite(scaled_3, out_file_3);