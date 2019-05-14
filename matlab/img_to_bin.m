clear all;
clc;
addpath('functions');

% Read image and create YCbCr and greyscale components
rgb = imread('..\img\orig\lionking_rgb_540.png');
ycbcr444 = rgb2ycbcr(rgb);
% grayscale = rgb2gray(rgb);
Y = ycbcr444(:,:,1);
Cb = ycbcr444(:,:,2);
Cr = ycbcr444(:,:,3);

% Write data to binary file
%write_bin = img2bin(ycbcr444, '..\data\lionking_ycbcr444_8bit_34.bin', 8);

imshow(rgb)