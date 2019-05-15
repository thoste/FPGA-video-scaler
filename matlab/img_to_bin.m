clear all;
clc;
addpath('functions');

image = 'lionking';
resolution = 360;
bit = 8;

input_file_name = strcat('..\img\pre_scaled\',image,'\',image,'_rgb_',string(resolution),'.png');
output_file_name = strcat('..\data\orig\',image,'\',image,'_ycbcr444_',string(bit),'bit_',string(resolution),'.bin');

% Read image and create YCbCr and greyscale components
rgb = imread(input_file_name);
if isa(rgb,'uint16') && (bit == 8)
    fprintf('Converting uint16 to uint8\n');
    rgb = uint8(rgb/256);
end
ycbcr444 = rgb2ycbcr(rgb);
% grayscale = rgb2gray(rgb);
% Y = ycbcr444(:,:,1);
% Cb = ycbcr444(:,:,2);
% Cr = ycbcr444(:,:,3);

% Write data to binary file
write_bin = img2bin(ycbcr444, output_file_name, bit);

%imshow(rgb);