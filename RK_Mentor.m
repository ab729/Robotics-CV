% Robot Mentor
% Introduction - Robot parameters, fk, rk
% Lab I - Actuator space(Thetas) vs Joint Space (Registers)
% Lab II - Forward Kinematics | Implemantation
% Lab III - Reverse Kinematics | Implemantation
% Lab IV - Trajectory generation



% ---------------------- Input Target Position ----------------------
target_x = -4;  % Desired x position
target_y = -15;  % Desired y position
target_z = 50;  % Desired z position
Fi=-20;

l1 = 17; 
l2 = 15; 
l3 = 10.5; 
H = 37; 

% ---------------------- Reverse Kinematics (Elbow-Up Only) ----------------------
%[t1, t2, t3, t4] = RK(target_x, target_y, target_z, l1, l2, H, Fi);
    x1 = sqrt(target_x^2+target_y^2);
    y1 = target_z - H;
    
    t1=atan2(target_y, target_x);
    disp(t1)
    %GEOMETRIC SOLUTION reduce to simple planar three-link manipulator
    if (l1+l2)>=sqrt(x1^2+y1^2)  %condition of solution existence
      %teta3
      c3=(x1^2+y1^2-l1^2-l2^2)/(2*l1*l2);
      t3=acos(c3);
      if t3>0  
          t3=-t3; 
      end;
      disp(t3)
      %teta2
      b=atan2(y1,x1);
      p=acos((x1^2+y1^2+l1^2-l2^2)/(2*l1*sqrt(x1^2+y1^2)));
      t2=(b+p);
      disp(t2)
      %teta4
      t4=deg2rad(Fi)-t3-t2;
      disp(t4)
    end;

% Convert joint angles to register values using your formula
r1 = 125 + (110.0 / 90.0 * (-t1) * 90 / (pi / 2));
r2 = 20 + (140.0 / 90.0 * t2 * 90 / (pi / 2));
r3 = 130 + (90.0 / 90.0 * t3 * 90 / (pi / 2));
r4 = 116 + (52.0 / 60.0 * t4 * 90 / (pi / 2));

% Ensure values remain within range [0, 255]
r1 = max(0, min(255, r1));
r2 = max(0, min(255, r2));
r3 = max(0, min(255, r3));
r4 = max(0, min(255, r4));

disp('Scaled Register Values (0 to 255):');
disp(['r1 = ', num2str(r1)]);
disp(['r2 = ', num2str(r2)]);
disp(['r3 = ', num2str(r3)]);
disp(['r4 = ', num2str(r4)]);

% ---------------------- Forward Kinematics ----------------------
T01 = [cos(t1) -sin(t1) 0 0;
       sin(t1) cos(t1) 0 0;
       0 0 1 H;
       0 0 0 1];

T12 = [cos(t2) -sin(t2) 0 0;
       0 0 -1 0;
       sin(t2) cos(t2) 0 0;
       0 0 0 1];

T23 = [cos(t3) -sin(t3) 0 l1;
       sin(t3) cos(t3) 0 0;
       0 0 1 0;
       0 0 0 1];

T34 = [cos(t4) -sin(t4) 0 l2;
       sin(t4) cos(t4) 0 0;
       0 0 1 0;
       0 0 0 1];

T04 = T01 * T12 * T23 * T34;
computed_pos = T04 * [0; 0; 0; 1];

disp('Forward Kinematics Position:');
disp(['X = ', num2str(computed_pos(1))]);
disp(['Y = ', num2str(computed_pos(2))]);
disp(['Z = ', num2str(computed_pos(3))]);

% ---------------------- 3D Graphing Function ----------------------
figure;
hold on;
grid on;
axis equal;
view(3);
rotate3d on;

P0 = [0; 0; 0; 1]; 
P1 = T01 * [0; 0; 0; 1]; 
P2 = T01 * T12 * [0; 0; 0; 1]; 
P3 = T01 * T12 * T23 * [0; 0; 0; 1]; 
P4 = T01 * T12 * T23 * T34 * [0; 0; 0; 1]; 
P5 = T01 * T12 * T23 * T34 * [l3; 0; 0; 1];

x_coords = [P0(1), P1(1), P2(1), P3(1), P4(1), P5(1)];
y_coords = [P0(2), P1(2), P2(2), P3(2), P4(2), P5(2)];
z_coords = [P0(3), P1(3), P2(3), P3(3), P4(3), P5(3)];

plot3(x_coords, y_coords, z_coords, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b'); 
plot3(P5(1), P5(2), P5(3), 'r*', 'MarkerSize', 12); 

xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('3D Robot Arm Structure (Elbow-Up)');
legend('Robot Structure', 'End-Effector');

hold off;