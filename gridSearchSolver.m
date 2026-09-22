function gridSearchSolver()
    % 物理约束设置
    maxX = 5;          % x最大范围(米)
    minX = 0.01;       % 避免x=0的不稳定点
    maxY = 5;          % y最大范围(米)
    
    % 网格精度参数
    coarseSteps = 100;  % 粗搜索步数
    fineSteps = 200;    % 精搜索步数
    fineRadius = 0.5;   % 精搜索半径(米)
    
    % 粗网格搜索
    [xCoarse, yCoarse] = meshgrid(linspace(minX, maxX, coarseSteps), ...
                                  linspace(0, maxY, coarseSteps));
    
    residualCoarse = computeResidual(xCoarse, yCoarse);
    [minRes, idx] = min(residualCoarse(:));
    [row, col] = ind2sub(size(residualCoarse), idx);
    
    % 精网格搜索
    centerX = xCoarse(row, col);
    centerY = yCoarse(row, col);
    
    [xFine, yFine] = meshgrid(linspace(centerX - fineRadius, centerX + fineRadius, fineSteps), ...
                              linspace(centerY - fineRadius, centerY + fineRadius, fineSteps));
    
    residualFine = computeResidual(xFine, yFine);
    [minRes, idx] = min(residualFine(:));
    [row, col] = ind2sub(size(residualFine), idx);
    
    solution = [xFine(row, col), yFine(row, col)];
    
    % 结果显示
    fprintf('网格搜索最优解: x = %.6f m, y = %.6f m\n', solution(1), solution(2));
    fprintf('综合残差: %.4e\n', minRes);
    
    % 验证并绘制解
    validateAndPlot(solution);
    
    % 残差计算函数
    function residual = computeResidual(x, y)
        % 计算方程1：角度关系方程
        term1 = sin(3*pi/8 - atan2(x, 2.2 + y));
        term2 = sin(pi/8 - atan2(2.2 - y, x)); % 使用atan2避免奇点
        eq1 = term1 - term2 - 0.81;
        
        % 计算方程2：双曲线方程
        dist1 = sqrt(x.^2 + (y + 2.2).^2);
        dist2 = sqrt(x.^2 + (y - 2.2).^2);
        eq2 = dist1 - dist2 - 1.8;
        
        % 综合残差（几何平均）
        residual = sqrt(eq1.^2 + eq2.^2);
    end
    
    % 解验证和可视化函数
    function validateAndPlot(sol)
        xSol = sol(1); ySol = sol(2);
        
        % 计算方程值
        term1 = sin(3*pi/8 - atan2(xSol, 2.2 + ySol));
        term2 = sin(pi/8 - atan2(2.2 - ySol, xSol));
        eq1 = term1 - term2;
        
        dist1 = sqrt(xSol^2 + (ySol + 2.2)^2);
        dist2 = sqrt(xSol^2 + (ySol - 2.2)^2);
        eq2 = dist1 - dist2;
        
        % 输出方程满足情况
        fprintf('方程1: sin(...) - sin(...) = %.6f (目标: 0.81)\n', eq1);
        fprintf('方程2: sqrt(...) - sqrt(...) = %.6f m (目标: 1.8 m)\n', eq2);
        
        % 创建可视化
        figure('Position', [100, 100, 1200, 500]);
        
        % 残差曲面
        subplot(1, 2, 1);
        [X, Y] = meshgrid(linspace(xSol-0.5, xSol+0.5, 50), ...
                          linspace(ySol-0.5, ySol+0.5, 50));
        R = computeResidual(X, Y);
        
        surf(X, Y, R, 'EdgeColor', 'none');
        hold on;
        plot3(xSol, ySol, minRes, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        title('残差曲面与最优解');
        xlabel('x (m)'); ylabel('y (m)'); zlabel('残差');
        colormap jet; colorbar;
        view(-30, 30);
        
        % 等高线图
        subplot(1, 2, 2);
        contourf(X, Y, R, 50, 'LineColor', 'none');
        hold on;
        
        % 绘制双曲线分支
        theta = linspace(0, 2*pi, 100);
        f1x = zeros(size(theta));
        f1y = -2.2*ones(size(theta));
        f2x = zeros(size(theta));
        f2y = 2.2*ones(size(theta));
        plot3(f1x, f1y, ones(size(f1y))*max(R(:)), 'b-', 'LineWidth', 1.5);
        plot3(f2x, f2y, ones(size(f2y))*max(R(:)), 'b-', 'LineWidth', 1.5);
        
        % 标记解点
        plot(xSol, ySol, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        
        title('残差等高线与焦点');
        xlabel('x (m)'); ylabel('y (m)');
        colormap jet; colorbar;
        axis equal;
        
        % 标注焦点
        text(-0.2, -2.3, '焦点 (0, -2.2)', 'FontSize', 10);
        text(-0.2, 2.3, '焦点 (0, 2.2)', 'FontSize', 10);
    end
end