% Load the building image
img = imread('buildings.jpg');  % Replace with your image file
grayImg = rgb2gray(img);       % Convert to grayscale

% 1️⃣ Display the grayscale image
figure;
imshow(grayImg);
title('Grayscale Image');

% Apply edge detection (Canny works well for buildings)
buildingEdges = edge(grayImg, 'Canny');  % Renamed variable

% 2️⃣ Display the edge-detected image
figure;
imshow(buildingEdges);
title('Edge Detection (Canny)');

% Get image dimensions
[rows, cols] = size(buildingEdges);
max_rho = ceil(sqrt(rows^2 + cols^2));
min_alpha = -90;
max_alpha = 180;

% Initialize accumulator
A = zeros(max_rho, max_alpha - min_alpha + 1);

% 3️⃣ Compute Hough Transform
for x = 1:cols
    for y = 1:rows
        if buildingEdges(rows - y + 1, x)  % Canny edge returns logical (true/false)
            for alpha = min_alpha:max_alpha
                a = pi * alpha / 180;
                rho = round(x * cos(a) + y * sin(a));
                if rho > 0 && rho <= max_rho
                    A(max_rho - rho + 1, alpha - min_alpha + 1) = ...
                        A(max_rho - rho + 1, alpha - min_alpha + 1) + 1;
                end
            end
        end
    end
end

% 4️⃣ Display the Hough accumulator (2D)
figure;
imshow(A, [], 'XData', min_alpha:max_alpha, 'YData', 0:max_rho);
title('Custom Hough Transform Accumulator (2D)');
xlabel('Theta (degrees)');
ylabel('Rho (pixels)');
colorbar;

% 5️⃣ Display the Hough accumulator in 3D
[ThetaGrid, RhoGrid] = meshgrid(min_alpha:max_alpha, 0:max_rho-1); % Fix dimensions
figure;
surf(ThetaGrid, RhoGrid, A);
title('Custom Hough Transform Accumulator (3D)');
xlabel('Theta');
ylabel('Rho');
zlabel('Votes');
shading interp;
colorbar;

% Detect peaks (increase number for more lines)
peaks = houghpeaks(A, 10, 'Threshold', ceil(0.4 * max(A(:))));

% 6️⃣ Draw lines on original image
figure;
imshow(img);
title('Detected Edges on Building');
hold on;
for i = 1:size(peaks,1)
    rhoVal = max_rho - peaks(i,1) + 1;
    thetaVal = (peaks(i,2) + min_alpha) * pi / 180;

    x = 1:cols;
    
    % Fix for flipped Y-axis
    y = (rhoVal - x * cos(thetaVal)) / sin(thetaVal);

    % Flip the y coordinates to match MATLAB's image coordinate system
    y = rows - y; % Flip the Y-axis for correct orientation

    % Ensure lines fall within the image boundaries
    validIdx = y >= 1 & y <= rows;
    
    % Draw the detected lines
    plot(x(validIdx), y(validIdx), 'r', 'LineWidth', 2);
end
hold off;
