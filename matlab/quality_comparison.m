clear all;
clc;

% Read image files
orig_img = imread('..\img\rgb_720.png');
matlab_img = imread('..\img\rgb_720.png');
vhdl_img = imread('..\img\rgb_720.png');


% Calculate PSN and SNR
[PSNR_matlab, SNR_matlab] = psnr(matlab_img, orig_img);
[PSNR_vhdl, SNR_vhdl] = psnr(vhdl_img, orig_img);

% Calculate MSE
MSE_matlab = immse(matlab_img, orig_img);
MSE_vhdl = immse(vhdl_img, orig_img);

% Calulate SSIM
[mssim_matlab, ssim_matlab] = ssim(matlab_img, orig_img);
[mssim_vhdl, ssim_vhdl] = ssim(vhdl_img, orig_img);