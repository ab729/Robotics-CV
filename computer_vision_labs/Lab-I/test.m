clc;
clear;

% === 1. Read and preprocess ===
I_rgb = imread('euro.bmp');
P_rgb = imread('triangle_pattern.bmp');

I_gray = rgb2gray(I_rgb);
P_gray = rgb2gray(P_rgb);

I_edges = edge(I_gray, 'Canny');
P_edges = edge(P_gray, 'Canny');

[pr, pc] = size(P_edges);
[ir, ic] = size(I_edges);

angles = 0:15:345;
match_threshold = 0.3;  % Adjusted to allow slightly weaker matches for better detection

% Initialize accumulator
accumulator = zeros(ir - pr + 1, ic - pc + 1);
matches = [];

% === 2. Rotation-aware matching ===
for a = angles
    angle_rad = deg2rad(a);
    R = [cos(-angle_rad), -sin(-angle_rad); sin(-angle_rad), cos(-angle_rad)];
    
    P_rot = false(pr, pc);
    center = floor([pr, pc] / 2) + 1;
    
    % Rotate pattern pixels using interpolation for better accuracy
    for r = 1:pr
        for c = 1:pc
            vec = [r; c] - center(:);
            rotated = R * vec;
            r2 = round(rotated(1) + center(1));
            c2 = round(rotated(2) + center(2));
            if r2 >= 1 && r2 <= pr && c2 >= 1 && c2 <= pc
                P_rot(r, c) = P_edges(r2, c2);
            end
        end
    end

    % NCC-based matching
    ncc = normxcorr2(double(P_rot), double(I_edges));
    ncc_valid = ncc(pr:end-pr+1, pc:end-pc+1);
    accumulator = max(accumulator, ncc_valid);

    % Collect matches exceeding threshold
    [rows, cols] = find(ncc_valid > match_threshold);
    for k = 1:length(rows)
        matches = [matches; rows(k), cols(k), a, ncc_valid(rows(k), cols(k))];
    end
end

% === 3. Non-maximum suppression ===
min_dist = 50;  % Increased suppression distance to ensure cleaner selections
final_matches = [];

for i = 1:size(matches,1)
    r = matches(i,1);
    c = matches(i,2);
    angle = matches(i,3);
    
    if isempty(final_matches)
        final_matches = [r, c, angle];
    else
        distances = vecnorm(final_matches(:,1:2) - [r c], 2, 2);
        if all(distances > min_dist)
            final_matches = [final_matches; r, c, angle];
        end
    end
end

% === 4. Display results ===
figure;
imshow(I_rgb);
hold on;
title('Filtered Matches');

for i = 1:size(final_matches,1)
    r = final_matches(i,1);
    c = final_matches(i,2);
    x = c;
    y = r;
    w = pc;
    h = pr;
    rectangle('Position', [x, y, w, h], 'EdgeColor', 'r', 'LineWidth', 2);
    angle = final_matches(i,3);
    text(x + w/2, y - 10, sprintf('%d°', angle), 'Color', 'yellow', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

figure;
imagesc(accumulator);
colormap('hot');
colorbar;
title('Accumulator - Max NCC Scores');

figure;
surf(accumulator, 'EdgeColor', 'none');
colormap('jet');
colorbar;
title('3D Surface Plot of Accumulator');
view(45, 60);