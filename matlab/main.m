clear all;
clc;
addpath('functions');

% % Create new low res version
% rgb = imread('img\rgb_68.png');
% scale = imresize(rgb, 1/8, 'bicubic');
% imwrite(scale, 'img\scale.png');

% Create YCbCr 4:4:4 image
rgb = imread('..\img\rgb_1080.png');
ycbcr444 = rgb2ycbcr(rgb);
imwrite(ycbcr444, '..\img\ycbcr444_1080.png');
