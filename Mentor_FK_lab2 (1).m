
% Robot Mentor
% Lab I - Actuator space(Thetas) vs Joint Space (Regoisters)
% Lab II - Forward Kinematics
% Lab III - Reverse Kinematics
% Lab IV - Trajectory
 

t1 = 30 *pi/180
t2 = 60 *pi/180
t3 = -45 *pi/180
t4 = 20 *pi/180


H=37
l1 = 17
l2 = 15
l3 = 10.5



r1 = 125+ (110.0/90.0*(-t1) * 90/(pi/2))
r2 = 20+ (140.0/90.0*t2 * 90/(pi/2))
r3 = 130+ (90.0/90.0*t3 * 90/(pi/2))
r4 = 116+ (52.0/60.0*t4 * 90/(pi/2))


T01 = [cos(t1) -sin(t1) 0 0;
       sin(t1) cos(t1) 0 0;
           0      0    1 H;
           0      0    0  1;
]

T12 = [cos(t2) -sin(t2) 0 0;
          0         0  -1 0;
       sin(t2) cos(t2)    0 0;
           0      0    0  1;
]

T23 = [cos(t3) -sin(t3) 0 l1;
       sin(t3) cos(t3) 0 0;
           0      0    1 0;
           0      0    0  1;
]

T34 = [cos(t4) -sin(t4) 0 l2;
       sin(t4) cos(t4) 0 0;
           0      0    1 0;
           0      0    0  1;
]


T04 = T01 * T12 * T23 * T34
P = T04 * [l3; 0; 0; 1] 





% Extract positions of joints and end-effector
P0 = [0; 0; 0; 1]; % Base joint (frame 0)
P1 = T01 * [0; 0; 0; 1]; % Joint 1
P2 = T01 * T12 * [0; 0; 0; 1]; % Joint 2
P3 = T01 * T12 * T23 * [0; 0; 0; 1]; % Joint 3
P4 = T01 * T12 * T23 *T34 * [0; 0; 0; 1]; % Joint 4 (wrist)
P5 = T01 * T12 * T23 *T34 * [l3; 0; 0; 1]; % End-effector (final point)


% Plot the line connecting the points
x_coords = [P0(1), P1(1), P2(1), P3(1), P4(1), P5(1)];
y_coords = [P0(2), P1(2), P2(2), P3(2), P4(2), P5(2)];
z_coords = [P0(3), P1(3), P2(3), P3(3), P4(3), P5(3)];

plot3(x_coords, y_coords, z_coords, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b'); % Blue line
hold on;

% Highlight P5 with a distinct marker
plot3(P5(1), P5(2), P5(3), 'r*', 'MarkerSize', 12); % Red star for P4



% Enhance plot appearance
grid on;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Robot Structure Highlighting End-Effector (P4)');
legend('Robot Structure', 'End-Effector (P4)');
hold off;


title('Line to point');

% -------------------------- Reverse Kinematis part ------------------


% Compute kinematics using register values
[x_wrist, y_wrist, z_wrist, phi_wrist] = inverse_kinematics(r1, r2, r3, r4, l1, l2, H);

disp(['End-Effector Position: (', num2str(x0), ', ', num2str(y0), ', ', num2str(z0), ')']);
disp(['Orientation (phi): ', num2str(phi)]);

disp(['r1 = ', num2str(round(r1)) ]);
disp(['r2 = ', num2str(round(r2)) ]);
disp(['r3 = ', num2str(round(r3)) ]);
disp(['r4 = ', num2str(round(r4)) ]);


% Reverse kinematic part - Lab II
function [x_wrist, y_wrist, z_wrist, phi_wrist] = inverse_kinematics(r1, r2, r3, r4, l1, l2, H)
    % Convert register values back to joint angles
    t1 = -(r1 - 125) * (pi/2) / 90 / (110.0/90.0);
    t2 = (r2 - 20) * (pi/2) / 90 / (140.0/90.0);
    t3 = (r3 - 130) * (pi/2) / 90 / (90.0/90.0);
    t4 = (r4 - 116) * (pi/2) / 90 / (52.0/60.0);

    % Define transformation matrices
    T01 = [cos(t1) -sin(t1) 0 0;
           sin(t1) cos(t1) 0 0;
           0      0    1 H;
           0      0    0  1];

    T12 = [cos(t2) -sin(t2) 0 0;
           0         0  -1 0;
           sin(t2) cos(t2) 0 0;
           0      0    0  1];

    T23 = [cos(t3) -sin(t3) 0 l1;
           sin(t3) cos(t3) 0 0;
           0      0    1 0;
           0      0    0  1];

    T34 = [cos(t4) -sin(t4) 0 l2;
           sin(t4) cos(t4) 0 0;
           0      0    1 0;
           0      0    0  1];

    % Compute wrist joint position (P4)
    T04 = T01 * T12 * T23 * T34;
    P4 = T04 * [0; 0; 0; 1]; % Wrist position in homogeneous coordinates

    % Extract wrist joint coordinates
    x_wrist = P4(1);
    y_wrist = P4(2);
    z_wrist = P4(3);

    % Compute wrist orientation phi (rotation about the Z-axis)
    phi_wrist = atan2(T04(2,1), T04(1,1));

    % Display wrist position and orientation
    disp(['Wrist Position: (', num2str(x_wrist), ', ', num2str(y_wrist), ', ', num2str(z_wrist), ')']);
    disp(['Wrist Orientation (phi): ', num2str(phi_wrist)]);
end




