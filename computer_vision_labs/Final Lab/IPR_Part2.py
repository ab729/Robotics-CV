import cv2
import numpy as np
import matplotlib.pyplot as plt

# === 1. Read Images ===
I_rgb = cv2.imread('cancer.bmp')    # BGR format by default
P_rgb = cv2.imread('cell.bmp')

# Check if images loaded
if I_rgb is None or P_rgb is None:
    raise ValueError("One or both images not found or failed to load.")

# === 2. Manual RGB to Grayscale Conversion ===
# OpenCV loads images in BGR, so order is Blue, Green, Red
def rgb2gray_manual(img):
    B = img[:, :, 0].astype(np.float64)
    G = img[:, :, 1].astype(np.float64)
    R = img[:, :, 2].astype(np.float64)
    gray = 0.1140 * B + 0.5870 * G + 0.2989 * R
    return gray

I = rgb2gray_manual(I_rgb)
P = rgb2gray_manual(P_rgb)

# === 3. Initialize SAD accumulator matrix ===
rP, cP = P.shape
rI, cI = I.shape
A = np.zeros((rI - rP + 1, cI - cP + 1), dtype=np.float64)

# === 4. Compute SAD for each valid position ===
for r in range(rI - rP + 1):
    for c in range(cI - cP + 1):
        patch = I[r:r + rP, c:c + cP]
        A[r, c] = np.sum(np.abs(patch - P))

# === 5. Normalize accumulator matrix ===
A_norm = (A - np.min(A)) / (np.max(A) - np.min(A))

# === 6. Display accumulator matrix ===
plt.figure(figsize=(8, 6))
plt.title('Normalized Accumulator Matrix (SAD Values)')
plt.imshow(A_norm, cmap='jet')
plt.colorbar()
plt.show()

# === 7. Find candidate matches below threshold ===
threshold = 0.1
candidate_indices = np.argwhere(A_norm <= threshold)

# Extract scores
scores = A_norm[A_norm <= threshold]
# Combine rows, cols and scores
matches = np.hstack((candidate_indices, scores.reshape(-1, 1)))
# Sort matches by score ascending
matches = matches[matches[:, 2].argsort()]

# === 8. Non-Maximum Suppression (NMS) ===
kept_matches = []
min_dist = min(rP, cP) / 2

for match in matches:
    r, c, score = match
    r = int(r)
    c = int(c)
    too_close = False
    for km in kept_matches:
        dist = np.sqrt((r - km[0])**2 + (c - km[1])**2)
        if dist < min_dist:
            too_close = True
            break
    if not too_close:
        kept_matches.append((r, c))

print(f'Found {len(matches)} candidate matches, kept {len(kept_matches)} after NMS')

# === 9. Visualize matches on the image ===
# Convert image back to uint8 for display
I_display = I.astype(np.uint8)
I_display_color = cv2.cvtColor(I_display, cv2.COLOR_GRAY2BGR)

for (r, c) in kept_matches:
    top_left = (c, r)
    bottom_right = (c + cP, r + rP)
    cv2.rectangle(I_display_color, top_left, bottom_right, (0, 255, 0), 2)  # green box

cv2.imshow('Detected Matches with NMS (Green Boxes)', I_display_color)
cv2.waitKey(0)
cv2.destroyAllWindows()
