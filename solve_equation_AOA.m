% 定义方程组
fun = @(z) [
    % 角度方程: π/4 = arctan((x-4.4)/(y+2.2)) - arctan((x-4.4)/(y-2.2))
    % 使用恒等式转换为连续形式
    pi/4 - (atan2(z(1)-4.4, z(2)+2.2) - atan2(z(1)-4.4, z(2)-2.2));
    
    % 距离方程: d1-d2 = 1.8
    sqrt((4.4 - z(1))^2 + (z(2)+2.2)^2) - sqrt((4.4 - z(1))^2 + (z(2)-2.2)^2) - 2.1
];

% 设置初始猜测值 (初始值设置在(4.4, 0)附近)
z0 = [0; 2.2]; % [x; y]

% 求解方程 f ;组
options = optimoptions('fsolve', 'Display', 'off', 'TolFun', 1e-9, 'TolX', 1e-9);
z = fsolve(fun, z0, options);




% 提取解
x_sol = z(1);
y_sol = z(2);

% 显示结果
fprintf('解为:\n');
fprintf('x = %.6f m\n', x_sol);
fprintf('y = %.6f m\n', y_sol);