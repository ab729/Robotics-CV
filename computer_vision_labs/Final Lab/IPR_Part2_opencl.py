import pyopencl as cl
import numpy as np
import cv2
import matplotlib.pyplot as plt
import scipy.ndimage

# === 1. Read images and convert to grayscale manually ===
I_rgb = cv2.imread('cancer.bmp')
P_rgb = cv2.imread('cell.bmp')
if I_rgb is None or P_rgb is None:
    raise ValueError("Images not found")

def rgb2gray_manual(img):
    B = img[:, :, 0].astype(np.float32)
    G = img[:, :, 1].astype(np.float32)
    R = img[:, :, 2].astype(np.float32)
    return 0.1140 * B + 0.5870 * G + 0.2989 * R

I = rgb2gray_manual(I_rgb).astype(np.uint8)
P = rgb2gray_manual(P_rgb).astype(np.uint8)

rI, cI = I.shape
rP, cP = P.shape

# === 2. Setup OpenCL context and queue ===
platforms = cl.get_platforms()
gpu_devices = platforms[0].get_devices(device_type=cl.device_type.GPU)
if len(gpu_devices) == 0:
    devices = platforms[0].get_devices(device_type=cl.device_type.CPU)
else:
    devices = gpu_devices

ctx = cl.Context(devices)
queue = cl.CommandQueue(ctx)

# === 3. OpenCL kernel: SAD computation ===
kernel_code = """
__kernel void sad_match(__global uchar* I, __global uchar* P, __global float* A,
                        int rI, int cI, int rP, int cP)
{
    int r = get_global_id(0);
    int c = get_global_id(1);

    if (r <= rI - rP && c <= cI - cP) {
        float sum = 0.0f;
        for (int i = 0; i < rP; i++) {
            for (int j = 0; j < cP; j++) {
                int idxI = (r + i) * cI + (c + j);
                int idxP = i * cP + j;
                sum += fabs((float)I[idxI] - (float)P[idxP]);
            }
        }
        A[r * (cI - cP + 1) + c] = sum;
    }
}
"""

# === 4. Build program and create buffers ===
prg = cl.Program(ctx, kernel_code).build()

mf = cl.mem_flags
I_buf = cl.Buffer(ctx, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=I)
P_buf = cl.Buffer(ctx, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=P)
A_shape = (rI - rP + 1, cI - cP + 1)
A_np = np.zeros(A_shape, dtype=np.float32)
A_buf = cl.Buffer(ctx, mf.WRITE_ONLY, A_np.nbytes)

# === 5. Execute kernel ===
global_size = (A_shape[0], A_shape[1])
prg.sad_match(queue, global_size, None, I_buf, P_buf, A_buf,
              np.int32(rI), np.int32(cI), np.int32(rP), np.int32(cP))

# === 6. Read back results ===
cl.enqueue_copy(queue, A_np, A_buf)
queue.finish()

# === 7. Normalize and display accumulator matrix ===
A_norm = (A_np - A_np.min()) / (A_np.max() - A_np.min())
plt.imshow(A_norm, cmap='jet')
plt.title('Normalized Accumulator Matrix (SAD)')
plt.colorbar()
plt.show()

# === 8. Non-Maximum Suppression (NMS) to remove duplicate detections ===
footprint = np.ones((rP, cP))  # neighborhood size = pattern size
local_min = (A_np == scipy.ndimage.minimum_filter(A_np, footprint=footprint))

# Threshold to filter good matches (tune as needed)
threshold = np.min(A_np) + 0.1 * (np.max(A_np) - np.min(A_np))

candidates = np.argwhere(local_min & (A_np <= threshold))

print(f'Number of unique matches after NMS: {len(candidates)}')

# === 9. Draw rectangles on original image for matches ===
I_display = I_rgb.copy()
for (r, c) in candidates:
    top_left = (c, r)
    bottom_right = (c + cP, r + rP)
    cv2.rectangle(I_display, top_left, bottom_right, (0, 255, 0), 2)

cv2.imshow('Unique Matches', I_display)
cv2.waitKey(0)
cv2.destroyAllWindows()
