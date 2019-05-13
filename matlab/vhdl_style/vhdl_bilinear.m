% Bilinear interpolation VHDL style
clear all;
clc;

num_line_buffers = 4;

rx_video_width = 6;
rx_video_height = 6;

tx_video_width = 12;
tx_video_height = 12;

sr_y = 1/(tx_video_height/rx_video_height);
sr_x = 1/(tx_video_width/rx_video_width);

pixel_count = 0;

x_count = 0;
y_count = 0;

x1 = 0;
x2 = 0;
y1 = 0;
y2 = 0;

done_flag = false;

while pixel_count < (tx_video_width*tx_video_height)
    dx = (x_count*sr_x) + (0.5 * (1 - 1*sr_x));
    dy = (y_count*sr_y) + (0.5 * (1 - 1*sr_y));
    
    x_count = x_count + 1;
    
    if x_count == tx_video_width
       x_count = 0;
       y_count = y_count + 1 ;
    end
    
    if dy >= num_line_buffers
        y_count = 0;
        dy = 0;
    end
    
    x2 = floor(dx);
    if x2 == 0
        x1 = 0;
    else
        x1 = x2 - 1;
    end
    
    y2 = floor(dy);
    if y2 == 0
        y1 = 0;
    else
        y1 = y2 - 1;
    end
       
    fprintf('pixel: %i \n dx: %f | dy: %f \n', pixel_count, dx, dy);
    fprintf(' x1: %i | x2: %i\n y1: %i | y2: %i\n', x1, x2, y1, y2);
    pixel_count = pixel_count + 1;
    
    if done_flag == true
        fprintf('DONE\n');
    end
end
