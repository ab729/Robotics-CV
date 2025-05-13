% Load the image
img = imread('lines2.bmp');
grayImg = rgb2gray(img); % Convert to grayscale
binaryImg = imbinarize(grayImg); % Convert to binary

% Image dimensions
[rows, cols] = size(binaryImg);
max_rho = ceil(sqrt(rows^2 + cols^2)); % Maximum possible rho

% Define theta (alpha) range in degrees
min_alpha = -90;
max_alpha = 180;

% Initialize accumulator array
A = zeros(max_rho + 1, max_alpha - min_alpha + 1); % +1 because rho can be 0

% Manual Hough Transform
for x = 1:cols
    for y = 1:rows
        if binaryImg(y, x) == 0 % Detect dark (black) pixels
            for alpha = min_alpha:max_alpha
                a = pi * alpha / 180.0; % Convert angle to radians
                rho = round(x * cos(a) + y * sin(a));
                if (rho >= 0 && rho <= max_rho)
                    A(rho + 1, alpha - min_alpha + 1) = A(rho + 1, alpha - min_alpha + 1) + 1;
                end
            end
        end
    end
end

% Find peaks in the accumulator array
peaks = houghpeaks(A, 5, 'Threshold', ceil(0.5 * max(A(:))));

% 1️⃣ Plot the original image
figure;
imshow(img);
title('Original Image');

% 2️⃣ Plot the Hough accumulator array in 2D
figure;
imshow(A, [], 'XData', min_alpha:max_alpha, 'YData', 0:max_rho);
set(gca, 'YDir', 'normal'); % ✅ Flip Y-axis to correct orientation
title('Custom Hough Transform Accumulator (2D)');
xlabel('Theta (degrees)');
ylabel('Rho (pixels)');
axis on;
colorbar;

% 3️⃣ Properly formatted Hough accumulator in 3D
[ThetaGrid, RhoGrid] = meshgrid(min_alpha:max_alpha, 0:max_rho);
figure;
surf(ThetaGrid, RhoGrid, A);
title('Custom Hough Transform Accumulator (3D)');
xlabel('Theta');
ylabel('Rho');
zlabel('Votes');
shading interp;
colorbar;

% 4️⃣ Draw detected lines on original image
figure;
imshow(img);
title('Detected Lines');
hold on;
for i = 1:size(peaks,1)
    rhoVal = peaks(i,1) - 1; % Convert index back to rho
    thetaVal = (peaks(i,2) + min_alpha) * pi / 180; % Convert index to angle in radians

    % Generate X values across the image
    x = 1:cols;
    % Calculate corresponding Y values
    y = (rhoVal - x * cos(thetaVal)) / sin(thetaVal);

    % Keep only points within image boundaries
    validIdx = y >= 1 & y <= rows;

    % Plot the line
    plot(x(validIdx), y(validIdx), 'r', 'LineWidth', 2);
end
hold off;
