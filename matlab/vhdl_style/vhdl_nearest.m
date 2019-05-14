% Nearest neighbor VHDL style
clear all;
clc;

num_line_buffers = 4;

rx_video_width = 6;
rx_video_height = 6;

tx_video_width = 10;c
tx_video_height = 10;

sf_y = 1/(tx_video_height/rx_video_height);
sf_x = 1/(tx_video_width/rx_video_width);

fb_addr = 0;
pixel_count = 0;

x_count = 0;
y_count = 0;

done_flag = false;

while pixel_count < (tx_video_width*tx_video_height)
    dx = x_count*sf_x;
    dy = y_count*sf_y;
    
    x_count = x_count + 1;
    
    if x_count == tx_video_width
       x_count = 0;
       y_count = y_count + 1 ;
    end
    
    if dy >= num_line_buffers
        y_count = 0;
        dy = 0;
    end
    
    fb_addr = rx_video_width*floor(dy) + floor(dx);
       
    if fb_addr > (rx_video_width*rx_video_height)-1 
        fprintf('ERROR: fb_addr overflow => ');
    end
    fprintf('pixel: %i | dx: %f | dy: %f | fb_addr: %i\n', pixel_count, dx, dy, fb_addr);
    pixel_count = pixel_count + 1;
    
    if done_flag == true
        fprintf('DONE\n');
    end
end
