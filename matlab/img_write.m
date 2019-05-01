clear all;
clc;
addpath('functions');

% RGB image array
R = uint8([255 255 255 255; 0 128 128 255; 51 0 0 0; 255 0 255 255; 255 0 255 255]);
G = uint8([0 128 255 0; 0 255 128 128; 255 204 128 0; 255 0 255 128; 255 0 255 255]);
B = uint8([0 0 0 255; 0 0 128 0; 255 0 255 0; 0 255 255 0; 255 0 255 255]);
RGB = cat(3, R, G, B);


% Convert to bin
img = img2bin(RGB, 'img_bin.txt', 80);
imshow(img);
