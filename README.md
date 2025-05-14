# 🤖 Robot Mentor – Labs Documentation

Welcome! This document covers the core labs we explored in the Robot Mentor system, going from basic joint control to full trajectory generation. I wrote this as a way to document what I’ve learned and make sure I understand everything properly. Let’s break it down lab by lab.

---

## 🧭 Introduction: Position and Orientation

In robotics, any object’s **pose** in 3D space is made up of:

- **Position**: Where it is (x, y, z)
- **Orientation**: How it’s rotated (usually given as angles, a rotation matrix, or a quaternion)

These are often combined into a **transformation matrix** (a 4×4 matrix), which is used a lot in forward and inverse kinematics.

---

## ⚙️ Lab I – Actuator Space vs Joint Space

In this lab, we learned how to convert between:

- **Joint space** – mathematical joint angles (θ₁, θ₂, etc.)
- **Actuator space** – actual register values sent to the motors

We used equations like:

```
r = offset + scale * θ
```

And the reverse:

```
θ = (r - offset) / scale
```

This conversion is important because our robot only understands register values, but we think in angles when solving FK or IK.

---

## 🔧 Lab II – Forward Kinematics (FK) using D-H Parameters

**Forward Kinematics** is about computing the position of the end-effector given a set of joint angles.

### D-H Parameters

We use the Denavit–Hartenberg convention to simplify the math. For each joint we define:

- `a`: link length
- `α`: link twist
- `d`: offset along z
- `θ`: rotation around z

We build one transformation matrix for each link, then chain them together.

### Example (2-link planar arm):

```
x = L₁ * cos(θ₁) + L₂ * cos(θ₁ + θ₂)
y = L₁ * sin(θ₁) + L₂ * sin(θ₁ + θ₂)
```

Given:
- L₁ = 10 cm
- L₂ = 7 cm
- θ₁ = 30°, θ₂ = 45°

Result:
- x ≈ 10.47 cm
- y ≈ 11.76 cm

---

## 🔁 Lab III – Reverse Kinematics (Geometric Method)

Now we’re going the other way: given (x, y, z, φ), figure out the joint angles θ₁, θ₂, θ₃, θ₄.

### Geometry Steps:

1. Compute radial and vertical distance:
   ```
   r = sqrt(x² + y²)
   z' = z - H
   ```
2. Base rotation:
   ```
   θ₁ = atan2(y, x)
   ```
3. Elbow angle (using cosine rule):
   ```
   c₃ = (r² + z'² - L₁² - L₂²) / (2 * L₁ * L₂)
   θ₃ = atan2(-sqrt(1 - c₃²), c₃)  # elbow-up
   ```
4. Shoulder angle:
   ```
   β = atan2(z', r)
   ψ = atan2(L₂ * sin(θ₃), L₁ + L₂ * cos(θ₃))
   θ₂ = β + ψ
   ```
5. Wrist angle:
   ```
   θ₄ = φ - θ₂ - θ₃
   ```

### Result:
- θ₁ ≈ -105°
- θ₂ ≈ -6.4°
- θ₃ ≈ -101.8°
- θ₄ ≈ 88.2°

These values are then converted to register values like we did in Lab I.

---

## 📈 Lab IV – Trajectory Generation (Line + Circle)

This lab was all about moving the robot **smoothly** between points.

### 1. Linear Trajectory

Moves in a straight line from A to B.

Given:
- Start: (x₀, y₀, z₀)
- End: (x_f, y_f, z_f)
- Time: T

Interpolation:
```
x(t) = x₀ + (t / T) * (x_f - x₀)
y(t) = y₀ + (t / T) * (y_f - y₀)
z(t) = z₀ + (t / T) * (z_f - z₀)
```

### 2. Circular Trajectory (XY plane)

Given:
- Radius R
- Center: (x_c, y_c)
- Start and end angles: θ₀ → θ_f

Position:
```
θ(t) = θ₀ + (t / T) * (θ_f - θ₀)
x(t) = x_c + R * cos(θ(t))
y(t) = y_c + R * sin(θ(t))
z(t) = z₀
```

We compute (x, y, z) at each t, then apply inverse kinematics to find the joint angles to make the move.

---

That’s it! These are the core robotics labs I’ve worked through using Robot Mentor. If you’ve made it this far, thanks for reading :)
