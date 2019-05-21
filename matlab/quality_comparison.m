clear all;
clc;

image = 'lionking';
scaling_method = 'nearest';

orig_file = strcat('..\img\pre_scaled\',image,'\',image,'_rgb_1080.png');

matlab_file_360 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_360_to_1080.png');
matlab_file_540 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_540_to_1080.png');
matlab_file_720 = strcat('..\img\matlab_out\',image,'\',image,'_',scaling_method,'_720_to_1080.png');

vhdl_file_360 = strcat('..\img\vhdl_out\',image,'\',image,'_',scaling_method,'_360_to_1080.png');
vhdl_file_540 = strcat('..\img\vhdl_out\',image,'\',image,'_',scaling_method,'_540_to_1080.png');
vhdl_file_720 = strcat('..\img\vhdl_out\',image,'\',image,'_',scaling_method,'_720_to_1080.png');

% Read image files
orig_img = imread(orig_file);
if isa(orig_img,'uint16') && (bit == 8)
    fprintf('Converting uint16 to uint8\n');
    orig_img = uint8(orig_img/256);
end

matlab_img_360 = imread(matlab_file_360);
matlab_img_540 = imread(matlab_file_540);
matlab_img_720 = imread(matlab_file_720);

vhdl_img_360 = imread(vhdl_file_360);
vhdl_img_540 = imread(vhdl_file_540);
vhdl_img_720 = imread(vhdl_file_720);

% Calculate PSN and SNR
[PSNR_matlab_360, SNR_matlab_360] = psnr(matlab_img_360, orig_img);
[PSNR_matlab_540, SNR_matlab_540] = psnr(matlab_img_540, orig_img);
[PSNR_matlab_720, SNR_matlab_720] = psnr(matlab_img_720, orig_img);

[PSNR_vhdl_360, SNR_vhdl_360] = psnr(vhdl_img_360, orig_img);
[PSNR_vhdl_540, SNR_vhdl_540] = psnr(vhdl_img_540, orig_img);
[PSNR_vhdl_720, SNR_vhdl_720] = psnr(vhdl_img_720, orig_img);

% Calculate MSE
MSE_matlab_360 = immse(matlab_img_360, orig_img);
MSE_matlab_540 = immse(matlab_img_540, orig_img);
MSE_matlab_720 = immse(matlab_img_720, orig_img);

MSE_vhdl_360 = immse(vhdl_img_360, orig_img);
MSE_vhdl_540 = immse(vhdl_img_540, orig_img);
MSE_vhdl_720 = immse(vhdl_img_720, orig_img);

% Calulate SSIM
[mssim_matlab_360, ssim_matlab_360] = ssim(matlab_img_360, orig_img);
[mssim_matlab_540, ssim_matlab_540] = ssim(matlab_img_540, orig_img);
[mssim_matlab_720, ssim_matlab_720] = ssim(matlab_img_720, orig_img);

[mssim_vhdl_360, ssim_vhdl_360] = ssim(vhdl_img_360, orig_img);
[mssim_vhdl_540, ssim_vhdl_540] = ssim(vhdl_img_540, orig_img);
[mssim_vhdl_720, ssim_vhdl_720] = ssim(vhdl_img_720, orig_img);