%% Converts image to binary image

function output = img2bin(img, filename, bits)
    fileID = fopen(filename,'w');
    [height,width,colors] = size(img);
    for y = 1:height
        for x = 1:width
            for z = colors:-1:1
                fprintf(fileID,dec2bin(img(y,x,z),bits));
            end
            if (y == height) && (x == width) && (z == 1)
                % No new line
            else
                fprintf(fileID,'\n');
            end
        end
    end
    fclose(fileID);
    output = img;
end