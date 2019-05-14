%% Converts image to binary image

function output = img2bin(img, filename, bits)
    fileID = fopen(filename,'w');
    [height,width,colors] = size(img);
    for y = 1:height
        for x = 1:width
            for z = colors:-1:1
                fprintf(fileID,dec2bin(img(y,x,z),bits));
            end
            fprintf(fileID,'\n');
        end
    end
    fclose(fileID);
    output = img;
end