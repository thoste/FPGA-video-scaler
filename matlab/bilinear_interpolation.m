clear all;
clc;

addpath('functions');

rgb = imread('..\img\rgb_1080.png');
scale = bilinear(rgb, 2);

imshow(scale);