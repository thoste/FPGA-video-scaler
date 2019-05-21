clear all;
clc;

addpath('functions');

pixels = uint8([
    11, 12, 13, 14, 15, 16;
    21, 22, 23, 24, 25, 26;
    31, 32, 33, 34, 35, 36;
    41, 42, 43, 44, 45, 46;
    51, 52, 53, 54, 55, 56;
    61, 62, 63, 64, 65, 66;
    ]);

rgb(:,:,1) = pixels;
rgb(:,:,2) = pixels;
rgb(:,:,3) = pixels;

scale = bilinear(rgb, 2);

imshow(scale);