clear all;
clc;
addpath('functions');

% Create new low res version
rgb = imread('..\img\source\PlanetEarth2c_source.png');
if isa(rgb,'uint16')
    fprintf('Converting uint16 to uint8\n');
    rgb = uint8(rgb/256);
end

scale = imresize(rgb, 1, 'bicubic');
imwrite(scale, '..\img\pre_scaled\planetearth2c\planetearth2c_rgb_2160.png');




% % Create YCbCr 4:4:4 image
% rgb = imread('..\img\rgb_1080.png');
% ycbcr444 = rgb2ycbcr(rgb);
% imwrite(ycbcr444, '..\img\ycbcr444_1080.png');


