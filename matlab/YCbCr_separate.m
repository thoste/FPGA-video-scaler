clear variables;
addpath('functions');

RGB = imread('..\img\rgb_1080.png');
YCbCr = rgb2ycbcr(RGB);


%Create a matrix of 128s.
a =  128 + zeros(size(RGB,1),size(RGB,2));


%Isolate components. 
Y = YCbCr(:,:,1);
Cb = YCbCr(:,:,2);
Cr= YCbCr(:,:,3);

%Create a YCbCr image with only the component.  
just_Y = cat(3, Y, a, a);
just_Cb = cat(3, a, Cb, a);
just_Cr = cat(3, a, a, Cr);

%turn back to rgb
YY = ycbcr2rgb(just_Y);
CbCb = ycbcr2rgb(just_Cb);
CrCr = ycbcr2rgb(just_Cr);


figure()
subplot(2,2,1), imshow(RGB), title('Original Image');
subplot(2,2,2), imshow(YY), title('Y Component');
subplot(2,2,3), imshow(CbCb), title('Cb Component');
subplot(2,2,4), imshow(CrCr), title('Cr Component');  