clear all;
clc;
addpath('functions');

% Read data from binary file
read_bin = bin2img('..\data\file.bin', 1280, 720, true, 8);

% Create image from binary file
imwrite(ycbcr2rgb(read_bin), '..\img\out.png');