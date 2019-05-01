clear all;

% Create grayscale version
rgb = imread('img\rgb_68.png');
grayscale = rgb2gray(rgb);
write = img2bin(grayscale, '../scaler/data/grey_8b_120x68.txt', 8);

imshow(grayscale);

% Create new low res version
% rgb = imread('img\rgb_2160.png');
% scale = imresize(rgb, 1/32, 'bicubic');
% imwrite(scale, 'scale.png');