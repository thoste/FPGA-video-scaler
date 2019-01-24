%% Converts RGB image to grayscale binary image

function output = img2bin(img, filename, bits)
    fileID = fopen(filename,'w');
    [height,width,colors] = size(img);
    for y = 1:height
        for x = 1:width
            for z = 1:colors
                fprintf(fileID,dec2bin(img(y,x,z),bits));
                fprintf(fileID,'\n');
            end
        end
    end
    fclose(fileID);
    output = img;
end