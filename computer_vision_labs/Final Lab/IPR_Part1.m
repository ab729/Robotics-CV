% === 1. Read Images ===
I_rgb = imread('cancer.bmp');       % Main image
P_rgb = imread('cell.bmp');         % Pattern image

% === 2. Manual RGB to Grayscale Conversion ===
I = 0.2989 * double(I_rgb(:,:,1)) + 0.5870 * double(I_rgb(:,:,2)) + 0.1140 * double(I_rgb(:,:,3));
P = 0.2989 * double(P_rgb(:,:,1)) + 0.5870 * double(P_rgb(:,:,2)) + 0.1140 * double(P_rgb(:,:,3));

% === 3. Initialize SAD Accumulator Matrix ===
[rP, cP] = size(P);
[rI, cI] = size(I);
A = zeros(rI - rP + 1, cI - cP + 1);

% === 4. Compute SAD (Sum of Absolute Differences) ===
for r = 1:(rI - rP + 1)
    for c = 1:(cI - cP + 1)
        patch = I(r:r+rP-1, c:c+cP-1);
        A(r, c) = sum(abs(patch(:) - P(:)));
    end
end

% === 5. Normalize the accumulator matrix ===
A_norm = (A - min(A(:))) / (max(A(:)) - min(A(:)));

% === 6. Display the normalized accumulator matrix ===
figure;
imshow(A_norm, []);
colormap('jet');
colorbar;
title('Normalized Accumulator Matrix (SAD Values)');

% === 7. Threshold and find candidate matches ===
threshold = 0.1;  % Tune this threshold for matches
[rows, cols] = find(A_norm <= threshold);

scores = A_norm(sub2ind(size(A_norm), rows, cols));
matches = [rows, cols, scores];
matches = sortrows(matches, 3);

% === 8. Non-Maximum Suppression (NMS) ===
kept_matches = [];
min_dist = min(rP, cP) / 2;

for i = 1:size(matches,1)
    r = matches(i,1);
    c = matches(i,2);
    is_far = true;
    
    for j = 1:size(kept_matches,1)
        r2 = kept_matches(j,1);
        c2 = kept_matches(j,2);
        dist = sqrt((r - r2)^2 + (c - c2)^2);
        if dist < min_dist
            is_far = false;
            break;
        end
    end
    
    if is_far
        kept_matches = [kept_matches; r, c];
    end
end

fprintf('Found %d candidate matches, kept %d after NMS\n', size(matches,1), size(kept_matches,1));

% === 9. Show detected matches on main image ===
figure;
imshow(uint8(I)); hold on;
for k = 1:size(kept_matches,1)
    rectangle('Position', [kept_matches(k,2), kept_matches(k,1), cP, rP], 'EdgeColor', 'g', 'LineWidth', 2);
end
title('Detected Matches with NMS (Green Boxes)');
