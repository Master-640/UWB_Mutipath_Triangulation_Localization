function solveEquations()
    % 定义方程组
    function F = equations(z)
        x = z(1);
        y = z(2);
        
        % 方程1：三角函数方程
        term1 = sin(3*pi/8 - atan2(x, 2.2 + y)); % 使用atan2避免奇点
        term2 = sin(pi/8 - atan2(2.2 - y, x));   % 使用atan2避免奇点
        eq1 = term1 - term2 - 0.76;
        
        % 方程2：双曲线距离方程
        sqrt1 = sqrt(x^2 + (y + 2.2)^2);
        sqrt2 = sqrt(x^2 + (y - 2.2)^2);
        eq2 = sqrt1 - sqrt2 - 1.82;
        
        F = [eq1; eq2];
    end

    % 初始猜测值（基于物理意义的合理估计）
    % 方程2描述双曲线，其顶点距离中心约0.9m
    % 方程1涉及角度计算，初始点在x轴附近
    initialGuesses = [0.1, 0.9;   % 第一猜测：右侧分支
                     -0.1, 0.9;  % 第二猜测：左侧分支
                      1.0, 1.5;  % 第三猜测：扩大范围
                     -1.0, 1.5]; % 第四猜测：扩大范围
    
    % 解的质量检查参数
    tolerance = 1e-6;
    maxIterations = 1000;
    options = optimoptions('fsolve', 'Display', 'off', 'MaxIterations', maxIterations, 'FunctionTolerance', tolerance);
    
    solutions = [];
    solutionCount = 0;
    
    % 使用不同初始点求解
    for i = 1:size(initialGuesses, 1)
        [z, fval, exitflag] = fsolve(@equations, initialGuesses(i,:), options);
        
        % 检查是否有效解
        if exitflag > 0 && all(abs(fval) < tolerance)
            % 检查解的物理合理性
            if abs(z(1)) < 100 && abs(z(2)) < 100 && imag(z(1)) == 0 && imag(z(2)) == 0
                solutionCount = solutionCount + 1;
                solutions(solutionCount, :) = real(z);
                
                % 显示数值解
                fprintf('解 %d: x = %.6f, y = %.6f\n', solutionCount, z(1), z(2));
                fprintf('残差: 方程1 = %.2e, 方程2 = %.2e\n\n', fval(1), fval(2));
            end
        end
    end
    
    % 可视化解的分布
    if ~isempty(solutions)
        figure;
        scatter(solutions(:,1), solutions(:,2), 'filled');
        title('数值解空间分布');
        xlabel('x (m)'); ylabel('y (m)');
        grid on; axis equal;
        
        % 添加关键点标注
        hold on;
        plot(0, -2.2, 'ro', 'MarkerSize', 8); % 下焦点
        plot(0, 2.2, 'bo', 'MarkerSize', 8);  % 上焦点
        legend('数值解', '下焦点 (0, -2.2)', '上焦点 (0, 2.2)');
        
        hold off;
    else
        warning('未找到有效解，尝试其他初始值');
    end
end