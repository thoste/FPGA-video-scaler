clear all;

rgb = imread('img\rgb_2160.png');

scale = imresize(rgb, 1/8, 'bicubic');

%imwrite(scale, 'scale.png');