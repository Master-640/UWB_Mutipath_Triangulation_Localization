% 定义方程组
fun = @(z) [
    sin(3*pi/8 - atan2(z(1), 2.2 + z(2))) - sin(pi/8 - atan2(2.2 + z(2), z(1))) - 0.81;
    sqrt(z(1)^2 + (z(2) + 2.2)^2) - sqrt(z(1)^2 + (z(2) - 2.2)^2) - 1.8
];

% 设置初始猜测值 (x0, y0)
z0 = [1; 0.5]; % 初始猜测 [x; y]

% 求解方程组
options = optimoptions('fsolve', 'Display', 'off'); % 关闭迭代显示
z = fsolve(fun, z0, options);

% 提取解
x_sol = z(1);
y_sol = z(2);

% 显示结果
fprintf('解为:\n');
fprintf('x = %.6f m\n', x_sol);
fprintf('y = %.6f m\n', y_sol);