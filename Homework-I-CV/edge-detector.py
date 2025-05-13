import cv2
import numpy as np
import matplotlib.pyplot as plt
from skimage.feature import peak_local_max

# 1️⃣ Load and resize image
img = cv2.imread('buildings.jpg')
scale = 0.5  # Resize to 50% for speed
img_resized = cv2.resize(img, None, fx=scale, fy=scale, interpolation=cv2.INTER_AREA)
gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)

# 2️⃣ Show grayscale image
plt.figure()
plt.imshow(gray, cmap='gray')
plt.title('Grayscale Image')
plt.axis('off')

# 3️⃣ Canny edge detection
edges = cv2.Canny(gray, 100, 200)
plt.figure()
plt.imshow(edges, cmap='gray')
plt.title('Canny Edges')
plt.axis('off')

# 4️⃣ Hough Transform parameters
rows, cols = edges.shape
max_rho = int(np.ceil(np.sqrt(rows**2 + cols**2)))
min_alpha = -90
max_alpha = 180
thetas = np.deg2rad(np.arange(min_alpha, max_alpha + 1))
cos_t = np.cos(thetas)
sin_t = np.sin(thetas)
num_thetas = len(thetas)

# 5️⃣ Vectorized Hough Transform
A = np.zeros((max_rho, num_thetas), dtype=np.uint64)
y_idxs, x_idxs = np.nonzero(edges)

for i in range(len(x_idxs)):
    x = x_idxs[i]
    y = y_idxs[i]
    rhos = np.round(x * cos_t + y * sin_t).astype(int)
    valid = (rhos >= 0) & (rhos < max_rho)
    A[rhos[valid], np.where(valid)[0]] += 1

# 6️⃣ Show Hough Accumulator (2D)
plt.figure()
plt.imshow(A, cmap='hot', extent=[min_alpha, max_alpha, 0, max_rho])
plt.title('Hough Accumulator')
plt.xlabel('Theta (degrees)')
plt.ylabel('Rho (pixels)')
plt.colorbar()
plt.axis('on')

# 7️⃣ Detect peaks in accumulator
coordinates = peak_local_max(A, min_distance=10, threshold_abs=0.4 * np.max(A), num_peaks=10)

# 8️⃣ Draw detected lines
plt.figure()
plt.imshow(cv2.cvtColor(img_resized, cv2.COLOR_BGR2RGB))
plt.title('Detected Lines on Buildings')

length = max(rows, cols)  # Adjusted line length based on resized image

for peak in coordinates:
    rho = peak[0]
    theta = thetas[peak[1]]
    a = np.cos(theta)
    b = np.sin(theta)
    x0 = a * rho
    y0 = b * rho
    x1 = int(x0 + length * (-b))
    y1 = int(y0 + length * (a))
    x2 = int(x0 - length * (-b))
    y2 = int(y0 - length * (a))
    plt.plot([x1, x2], [y1, y2], 'r', linewidth=2)

plt.axis('off')
plt.tight_layout()
plt.show()
