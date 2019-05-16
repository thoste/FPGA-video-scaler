clear all;
clc;

image = 'lionking';
in_height = 720;
out_height = 1080;
scaling_method = 'nearest';
bit = 8;

orig_file = strcat('..\img\source\',image,'_source.png');
%matlab_file = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_',string(in_height),'_to_',string(out_height),'.png');
vhdl_file = strcat('..\img\vhdl_out\',image,'\',image,'_',scaling_method,'_',string(in_height),'_to_',string(out_height),'.png');

% Read image files
orig_img = imread(orig_file);
if isa(orig_img,'uint16') && (bit == 8)
    fprintf('Converting uint16 to uint8\n');
    orig_img = uint8(orig_img/256);
end

%matlab_img = imread(matlab_file);
vhdl_img = imread(vhdl_file);


% Calculate PSN and SNR
%[PSNR_matlab, SNR_matlab] = psnr(matlab_img, orig_img);
[PSNR_vhdl, SNR_vhdl] = psnr(vhdl_img, orig_img);

% Calculate MSE
%MSE_matlab = immse(matlab_img, orig_img);
MSE_vhdl = immse(vhdl_img, orig_img);

% Calulate SSIM
%[mssim_matlab, ssim_matlab] = ssim(matlab_img, orig_img);
[mssim_vhdl, ssim_vhdl] = ssim(vhdl_img, orig_img);