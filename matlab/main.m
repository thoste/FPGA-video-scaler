clear all;
clc;
addpath('functions');

% Create new low res version
rgb = imread('..\img\orig\lionking_rgb_720.png');
scale = imresize(rgb, 1.5, 'nearest');
imwrite(scale, '..\img\matlab\lionking_matlab_720_to_1080.png');

% % Create YCbCr 4:4:4 image
% rgb = imread('..\img\rgb_1080.png');
% ycbcr444 = rgb2ycbcr(rgb);
% imwrite(ycbcr444, '..\img\ycbcr444_1080.png');


