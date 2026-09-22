function P_opt = localizeReflectionPoint(theta1, theta2, sin_phi_diff, rTOF, d)
    % 输入参数 (角度单位为度)
    % theta1, theta2: 设备1和设备2的到达角 (AOA)
    % sin_phi_diff: sin(φ₁ - φ₂) 的已知测量值
    % rTOF: 路径差对应的时间 (ns)
    % d: 设备间距 (米)
    
    % 角度转弧度
    theta1 = deg2rad(theta1);
    theta2 = deg2rad(theta2);
    
    % 光速 (m/ns)
    c_light = physconst('LightSpeed') * 1e-9;
    path_diff = rTOF * c_light;  % 路径差 b + c - a
    
    % 粗网格搜索范围
    gridRange = 20;     % 20米范围
    coarseStep = 1;     % 粗步长
    [X_coarse, Y_coarse] = meshgrid(-gridRange:coarseStep:gridRange, 0.1:coarseStep:gridRange); % 排除y=0
    coarseGrid = [X_coarse(:), Y_coarse(:)];
    
    % 计算粗网格目标函数
    f_coarse = objectiveFunc(coarseGrid, theta1, theta2, sin_phi_diff, path_diff, d);
    [~, idx] = min(f_coarse);
    P0 = coarseGrid(idx, :);  % 初始点
    
    % 细网格迭代 (多级优化)
    fineParams = [
        struct('range', 5, 'step', 0.1)
        struct('range', 1, 'step', 0.01)
    ];
    
    for k = 1:length(fineParams)
        range = fineParams(k).range;
        step = fineParams(k).step;
        x_range = P0(1)-range : step : P0(1)+range;
        y_range = P0(2)-range : step : P0(2)+range;
        [X_fine, Y_fine] = meshgrid(x_range, y_range);
        fineGrid = [X_fine(:), Y_fine(:)];
        
        f_fine = objectiveFunc(fineGrid, theta1, theta2, sin_phi_diff, path_diff, d);
        [~, idx] = min(f_fine);
        P0 = fineGrid(idx, :);
    end
    
    P_opt = P0;
end

function f = objectiveFunc(P, theta1, theta2, sin_phi_diff, path_diff, d)
    % P: 反射点坐标 [x, y] (N×2矩阵)
    x = P(:, 1); y = P(:, 2);
    
    % 计算距离
    dist_AP = sqrt(x.^2 + y.^2);       % |AP| = b
    dist_BP = sqrt((x - d).^2 + y.^2); % |BP| = c
    a = d;  % 设备间距 |AB| = a
    
    % 约束1: AOA (方位角关系)
    f_theta1 = (tan(theta1) - x ./ y).^2;          % tan(θ₁) = x/y
    f_theta2 = (tan(theta2) - (x - d) ./ y).^2;    % tan(θ₂) = (x-d)/y
    
    % 约束2: AOD (几何关系推导)
    % sin(φ₁ - φ₂) = [y * d] / (|AP| * |BP|) 
    sin_phi_calc = (y * d) ./ (dist_AP .* dist_BP); % 理论计算值
    f_phi = (sin_phi_diff - sin_phi_calc).^2;       % 与测量值的误差
    
    % 约束3: 路径差
    f_path = (dist_AP + dist_BP - a - path_diff).^2; % b + c - a = path_diff
    
    % 总目标函数 (加权求和)
    f = f_theta1 + f_theta2 + f_phi + f_path;
end