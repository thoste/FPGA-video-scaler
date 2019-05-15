clear all;
clc;

% Read image files
orig_img = imread('..\img\source\PlanetEarth2c_source.png');
if isa(orig_img,'uint16')
    fprintf('Converting uint16 to uint8\n');
    orig_img = uint8(orig_img/256);
end

matlab_img = imread('..\img\pre_scaled\planetearth2c\planetearth2c_rgb_2160.png');
vhdl_img = imread('..\img\pre_scaled\planetearth2c\planetearth2c_rgb_2160.png');


% Calculate PSN and SNR
[PSNR_matlab, SNR_matlab] = psnr(matlab_img, orig_img);
[PSNR_vhdl, SNR_vhdl] = psnr(vhdl_img, orig_img);

% Calculate MSE
MSE_matlab = immse(matlab_img, orig_img);
MSE_vhdl = immse(vhdl_img, orig_img);

% Calulate SSIM
[mssim_matlab, ssim_matlab] = ssim(matlab_img, orig_img);
[mssim_vhdl, ssim_vhdl] = ssim(vhdl_img, orig_img);