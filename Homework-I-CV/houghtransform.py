import cv2
import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage import maximum_filter

# Load the image in grayscale
imgName = 'lines2.bmp'
img = cv2.imread(imgName, cv2.IMREAD_GRAYSCALE)


# Ensure it's binary: lines are dark, background is white
_, binaryImg = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY_INV)

rows, cols = binaryImg.shape
max_rho = int(np.ceil(np.sqrt(rows**2 + cols**2)))
min_alpha = -90
max_alpha = 180

# Initialize accumulator
A = np.zeros((max_rho + 1, max_alpha - min_alpha + 1), dtype=np.uint64)

# Manual Hough Transform
for x in range(cols):
    for y in range(rows):
        if binaryImg[y, x] == 255:  # 255 after THRESH_BINARY_INV for black pixels
            for alpha in range(min_alpha, max_alpha + 1):
                a = np.pi * alpha / 180.0
                rho = int(round(x * np.cos(a) + y * np.sin(a)))
                if 0 <= rho <= max_rho:
                    A[rho, alpha - min_alpha] += 1

# Function to find peaks manually
def find_hough_peaks(accumulator, num_peaks=5, threshold=0):
    peaks = []
    A_max = maximum_filter(accumulator, size=5)
    for r in range(accumulator.shape[0]):
        for t in range(accumulator.shape[1]):
            if accumulator[r, t] == A_max[r, t] and accumulator[r, t] > threshold:
                peaks.append((r, t))
    peaks = sorted(peaks, key=lambda x: accumulator[x[0], x[1]], reverse=True)
    return peaks[:num_peaks]

# Detect peaks
threshold = int(0.5 * np.max(A))
peaks = find_hough_peaks(A, num_peaks=5, threshold=threshold)


# Plot original image
plt.figure()
plt.imshow(cv2.cvtColor(cv2.imread(imgName), cv2.COLOR_BGR2RGB))
plt.title('Original Image')
plt.axis('off')

# Plot Hough accumulator 2D
plt.figure()
plt.imshow(A, extent=[min_alpha, max_alpha, 0, max_rho], aspect='auto', cmap='hot')
plt.gca().invert_yaxis()
plt.colorbar(label='Votes')
plt.title('Custom Hough Transform Accumulator (2D)')
plt.xlabel('Theta (degrees)')
plt.ylabel('Rho (pixels)')

# Plot Hough accumulator 3D
from mpl_toolkits.mplot3d import Axes3D

theta_range = np.arange(min_alpha, max_alpha + 1)
rho_range = np.arange(0, max_rho + 1)
ThetaGrid, RhoGrid = np.meshgrid(theta_range, rho_range)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.plot_surface(ThetaGrid, RhoGrid, A, cmap='hot', edgecolor='none')
ax.set_title('Custom Hough Transform Accumulator (3D)')
ax.set_xlabel('Theta')
ax.set_ylabel('Rho')
ax.set_zlabel('Votes')
plt.colorbar(ax.plot_surface(ThetaGrid, RhoGrid, A, cmap='hot', edgecolor='none'))

# Draw detected lines on original image
plt.figure()
plt.imshow(cv2.cvtColor(cv2.imread(imgName), cv2.COLOR_BGR2RGB))
plt.imshow(img, cmap='gray', extent=[0, cols, rows, 0])
plt.title('Detected Lines')
plt.axis('off')

for rhoIdx, thetaIdx in peaks:
    rhoVal = rhoIdx
    thetaVal = (thetaIdx + min_alpha) * np.pi / 180

    if np.sin(thetaVal) != 0:
        x = np.arange(cols)
        y = (rhoVal - x * np.cos(thetaVal)) / np.sin(thetaVal)
        valid = (y >= 0) & (y < rows)
        plt.plot(x[valid], y[valid], 'r', linewidth=2)
    else:
        y = np.arange(rows)
        x = (rhoVal - y * np.sin(thetaVal)) / np.cos(thetaVal)
        valid = (x >= 0) & (x < cols)
        plt.plot(x[valid], y[valid], 'r', linewidth=2)

plt.show()
