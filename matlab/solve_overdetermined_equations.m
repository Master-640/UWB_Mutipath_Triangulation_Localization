function [x, y, beta] = solve_overdetermined_equations(x0, y0, alpha, phi1, phi2, D, K)
% SOLVE_EMITTER Solve for emitter position and orientation
%   Inputs:
%       x0, y0: receiver position (已知接收端坐标)
%       alpha: receiver orientation in radians (接收端朝向，弧度)
%       phi1, phi2: arrival angles at receiver in radians (到达角，弧度)
%       D: sin(theta1) - sin(theta2) (离开角正弦差)
%       K: path length difference b+c-a (路径长度差)
%
%   Outputs:
%       x, y: emitter position (发射端坐标)
%       beta: emitter orientation in radians (发射端朝向，弧度)

% Initial guess for x and y based on phi1 and phi2
m1 = tan(alpha + phi1);
m2 = tan(alpha + phi2);
if abs(m1 + m2) < 1e-10
    x_init = x0;
    y_init = y0;
else
    x_init = x0 - 2 * y0 / (m1 + m2);
    y_init = y0 * (m2 - m1) / (m1 + m2);
end
beta_init = 0; % initial guess for beta

% Combine initial guess
initial_guess = [x_init, y_init, beta_init];

% Define residual function
options = optimoptions('fsolve', 'Display', 'off', 'Algorithm', 'levenberg-marquardt');
solution = fsolve(@(X) residuals(X, x0, y0, alpha, phi1, phi2, D, K), initial_guess, options);

x = solution(1);
y = solution(2);
beta = solution(3);

end

function F = residuals(X, x0, y0, alpha, phi1, phi2, D, K)
x = X(1);
y = X(2);
beta = X(3);

% Equation 1: from phi1 (直接路径到达角)
F1 = (y - y0) - tan(alpha + phi1) * (x - x0);

% Equation 2: from phi2 (反射路径到达角)
F2 = -(y + y0) - tan(alpha + phi2) * (x - x0);

% Equation 3: path length difference (路径长度差)
d_direct = sqrt((x - x0)^2 + (y - y0)^2); % direct path length a
d_reflect = sqrt((x - x0)^2 + (y + y0)^2); % reflected path length b+c
F3 = d_reflect - d_direct - K;

% Equation 4: sin difference for departure angles (离开角正弦差)
% Compute reflection point x_s
if abs(y0 + y) < 1e-10
    x_s = x0;
else
    x_s = x0 + (y0 / (y0 + y)) * (x - x0);
end

% Compute global angles for departure
theta1_global = atan2(y0 - y, x0 - x); % direct path from emitter to receiver
theta2_global = atan2(-y, x_s - x); % reflected path from emitter to reflection point

% Relative departure angles
theta1_rel = theta1_global - beta;
theta2_rel = theta2_global - beta;

F4 = sin(theta1_rel) - sin(theta2_rel) - D;

% Combine residuals
F = [F1; F2; F3; F4];
end