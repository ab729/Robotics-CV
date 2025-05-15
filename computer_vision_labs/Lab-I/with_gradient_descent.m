% Generate synthetic data
rng(42);
m = 100;
X = 2 * rand(m, 1);
y = 3 * X + 7 + randn(m, 1);

% Add bias term
X_b = [ones(m, 1), X];

% Gradient Descent Settings
theta = randn(2,1);  % initial theta
alpha = 0.1;
n_iterations = 100;

% To store the path
theta_history = zeros(n_iterations, 2);
cost_history = zeros(n_iterations, 1);

% Gradient Descent Loop
for iter = 1:n_iterations
    gradients = (2/m) * X_b' * (X_b * theta - y);
    theta = theta - alpha * gradients;
    theta_history(iter, :) = theta';
    cost_history(iter) = (1/m) * sum((X_b * theta - y).^2);
end

% Generate Cost Surface
theta0_vals = linspace(5, 9, 100);
theta1_vals = linspace(2, 4, 100);
J_vals = zeros(length(theta0_vals), length(theta1_vals));

for i = 1:length(theta0_vals)
    for j = 1:length(theta1_vals)
        t = [theta0_vals(i); theta1_vals(j)];
        J_vals(j, i) = (1/m) * sum((X_b * t - y).^2);
    end
end

% 3D Surface Plot
figure;
surf(theta0_vals, theta1_vals, J_vals, 'EdgeColor', 'none')
xlabel('\theta_0')
ylabel('\theta_1')
zlabel('Cost J(\theta)')
title('Gradient Descent on Cost Function Surface')
colormap jet
hold on

% Plot the gradient descent path
plot3(theta_history(:,1), theta_history(:,2), cost_history, '-w', 'LineWidth', 2)

legend('Cost Surface', 'Gradient Descent Path')
view(45, 30)
grid on
