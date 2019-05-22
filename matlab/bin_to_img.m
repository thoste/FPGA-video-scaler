clear all;
clc;
addpath('functions');

image = 'planetearth2c';
in_height = 720;
out_width = 1920;
out_height = 1080;
scaling_method = 'bilinear';
bit = 8;

input_file_name = strcat('..\data\vhdl_out\',image,'\',image,'_',scaling_method,'_',string(in_height),'_to_',string(out_height),'.bin');
output_file_name = strcat('..\img\vhdl_out\',image,'\',image,'_',scaling_method,'_',string(in_height),'_to_',string(out_height),'.png');

% Read data from binary file
read_bin = bin2img(input_file_name, out_width, out_height, true, bit);

% Create image from binary file
imwrite(ycbcr2rgb(read_bin), output_file_name);

imshow(ycbcr2rgb(read_bin));

% fileID = fopen(input_file_name);
% num = (out_width*out_height*(bit*3+2) - 2);
% data_serial = fread(fileID,[1 num], '*char');
% 
% % Convert data to characters
% data_lines = splitlines(data_serial);