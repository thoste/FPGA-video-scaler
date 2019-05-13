clear all;
clc;

addpath('functions');

rgb = imread('img\scale.png');
scale = bilinear(rgb, 2);

%imshow(scale);