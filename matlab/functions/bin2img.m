%% Converts binary image to image

function output = bin2img(filename, width, height, colours, bits)
    % Read data from file
    fileID = fopen(filename);
    num = (width*height*(bits*3+2) - 2);
    data_serial = fread(fileID,[1 num], '*char');
    
    % Convert data to characters
    data_lines = splitlines(data_serial);
    
    if colours
        for i = 1:size(data_lines)
            colour_a(i,1) = extractBetween(data_lines(i), bits*2 + 1, bits*3);
            colour_b(i,1) = extractBetween(data_lines(i), bits + 1, bits*2);
            colour_c(i,1) = extractBetween(data_lines(i), 1, bits);
        end
        
        data_a = bin2dec(colour_a);
        data_b = bin2dec(colour_b);
        data_c = bin2dec(colour_c);
    else
        data = bin2dec(data_lines);
    end 
    
    for y = 1:height
        for x = 1:width
            if colours
                img(y,x,1) = data_a(((y-1)*width)+x);
                img(y,x,2) = data_b(((y-1)*width)+x);
                img(y,x,3) = data_c(((y-1)*width)+x);
            else
                img(y,x) = data(((y-1)*width)+x);
            end
        end
    end
    fclose(fileID);
    output = uint8(img);
end