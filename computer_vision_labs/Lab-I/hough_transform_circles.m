% ---------------- Load and Preprocess Image ----------------
img = imread('circles1.bmp');
grayImg = rgb2gray(img);
binaryImg = imbinarize(grayImg);

[rows, cols] = size(binaryImg);

% ---------------- LINE HOUGH TRANSFORM ----------------
max_rho = ceil(sqrt(rows^2 + cols^2));
min_alpha = -90;
max_alpha = 180;
A_line = zeros(max_rho + 1, max_alpha - min_alpha + 1);

for x = 1:cols
    for y = 1:rows
        if binaryImg(y, x) == 0  % dark pixels
            for alpha = min_alpha:max_alpha
                a = pi * alpha / 180;
                rho = round(x * cos(a) + y * sin(a));
                if (rho >= 0 && rho <= max_rho)
                    A_line(rho + 1, alpha - min_alpha + 1) = A_line(rho + 1, alpha - min_alpha + 1) + 1;
                end
            end
        end
    end
end

peaks_line = houghpeaks(A_line, 5, 'Threshold', ceil(0.5 * max(A_line(:))));

% ---------------- CIRCLE HOUGH TRANSFORM ----------------
min_r = 10;
max_r = 50;
A_circle = zeros(rows, cols, max_r);  % rows = Y, cols = X

for x = 1:cols
    for y = 1:rows
        if binaryImg(y, x) == 0
            for r = min_r:max_r
                nop = round(2 * pi * r);  % number of perimeter points
                for a = 1:nop
                    theta = 2 * pi * (a / nop);
                    xc = round(x - r * cos(theta));
                    yc = round(y - r * sin(theta));
                    if xc >= 1 && xc <= cols && yc >= 1 && yc <= rows
                        A_circle(yc, xc, r) = A_circle(yc, xc, r) + 1;
                    end
                end
            end
        end
    end
end

% ---------------- Find Circle Peaks ----------------
circle_threshold = ceil(0.8 * max(A_circle(:)));
[yc_peak, xc_peak, rc_peak] = ind2sub(size(A_circle), find(A_circle >= circle_threshold));

% ---------------- Display Results ----------------
figure;
imshow(img);
title('Detected Lines and Circles');
hold on;

% Plot lines
for i = 1:size(peaks_line, 1)
    rhoVal = peaks_line(i,1) - 1;
    thetaVal = (peaks_line(i,2) + min_alpha) * pi / 180;
    x_vals = 1:cols;
    y_vals = (rhoVal - x_vals * cos(thetaVal)) / sin(thetaVal);
    valid = y_vals >= 1 & y_vals <= rows;
    plot(x_vals(valid), y_vals(valid), 'r', 'LineWidth', 2);
end

% Plot circles
for i = 1:length(xc_peak)
    xc = xc_peak(i);
    yc = yc_peak(i);
    rc = rc_peak(i);
    viscircles([xc, yc], rc, 'EdgeColor', 'g', 'LineWidth', 1);
end

hold off;

% ---------------- Optional: 3D Accumulator Visualization for Lines ----------------
[ThetaGrid, RhoGrid] = meshgrid(min_alpha:max_alpha, 0:max_rho);
figure;
surf(ThetaGrid, RhoGrid, A_line);
title('Hough Accumulator (Lines, 3D)');
xlabel('Theta');
ylabel('Rho');
zlabel('Votes');
shading interp;
colorbar;
