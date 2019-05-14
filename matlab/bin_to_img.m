clear all;
clc;
addpath('functions');

% Read data from binary file
read_bin = bin2img('..\data\vhdl\lionking_vhdl_540_to_1080.bin', 1920, 1080, true, 8);

% Create image from binary file
imwrite(ycbcr2rgb(read_bin), '..\img\vhdl\lionking_vhdl_540_to_1080_new.png');

imshow(ycbcr2rgb(read_bin));