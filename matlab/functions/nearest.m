%% Neares neighbor interpolation

function output_image = nearest(input_image, scale_factor)
    % Separate each colour value from input image
    A = input_image(:,:,1);
    B = input_image(:,:,2);
    C = input_image(:,:,3);

    % Calculate size of input image
    [orig_height,orig_width] = size(A);
    
    % Allocate output image with new size
    new_height = ceil(orig_height * scale_factor);
    new_width = ceil(orig_width * scale_factor);
    bit = class(input_image);
    A_new = zeros(new_height,new_width,bit);
    B_new = zeros(new_height,new_width,bit);
    C_new = zeros(new_height,new_width,bit);

    % Run thourch each pixel in output image
    if scale_factor > 1
        for y_out = 1:new_height
            for x_out = 1:new_width
                % Calculate corresponding position in input image  
                dx = ceil(y_out/scale_factor);
                dy = ceil(x_out/scale_factor);
                
                % Assign value to output image
                A_new(y_out,x_out) = A(dx,dy);
                B_new(y_out,x_out) = B(dx,dy);
                C_new(y_out,x_out) = C(dx,dy);
            end
        end
    else
        for y_out = 1:new_height
            for x_out = 1:new_width
                % Calculate corresponding position in input image
                dx = floor(y_out/scale_factor);
                dy = floor(x_out/scale_factor);

                % Assign value to output image
                A_new(y_out,x_out) = A(dx,dy);
                B_new(y_out,x_out) = B(dx,dy);
                C_new(y_out,x_out) = C(dx,dy);
            end
        end
    end

    % Combine colours into RGB image
    output_image = cat(3, A_new, B_new, C_new);
end