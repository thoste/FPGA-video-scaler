clear all;
clc;

% Read image files
orig_img = imread('..\img\orig\lionking_rgb_1080.png');
matlab_img = imread('..\img\matlab\lionking_matlab_720_to_1080.png');
vhdl_img = imread('..\img\vhdl\lionking_vhdl_720_to_1080.png');


% Calculate PSN and SNR
[PSNR_matlab, SNR_matlab] = psnr(matlab_img, orig_img);
[PSNR_vhdl, SNR_vhdl] = psnr(vhdl_img, orig_img);

% Calculate MSE
MSE_matlab = immse(matlab_img, orig_img);
MSE_vhdl = immse(vhdl_img, orig_img);

% Calulate SSIM
[mssim_matlab, ssim_matlab] = ssim(matlab_img, orig_img);
[mssim_vhdl, ssim_vhdl] = ssim(vhdl_img, orig_img);