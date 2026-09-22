function [xOpt, yOpt] = locateReceiver(theta1, theta2, sinPhiDiff, bcMinusA)
    % 转换角度为弧度
    theta1 = deg2rad(theta1);
    theta2 = deg2rad(theta2);
    
    % 粗搜索阶段
    [xGrid, yGrid] = ndgrid(-20:0.5:20, -20:0.5:20);
    xy = [xGrid(:), yGrid(:)];
    fvals = computeObjective(xy, theta1, theta2, sinPhiDiff, bcMinusA);
    [~, idx] = min(fvals);
    x0 = xy(idx, :);
    
    % 细优化阶段
    searchParams = {...
        struct('range', 1, 'step', 0.03), ...
        struct('range', 0.1, 'step', 0.005)};
        
    for i = 1:length(searchParams)
        param = searchParams{i};
        xRange = (x0(1)-param.range):param.step:(x0(1)+param.range);
        yRange = (x0(2)-param.range):param.step:(x0(2)+param.range);
        [X, Y] = ndgrid(xRange, yRange);
        fineGrid = [X(:), Y(:)];
        fvals = computeObjective(fineGrid, theta1, theta2, sinPhiDiff, bcMinusA);
        [~, idx] = min(fvals);
        x0 = fineGrid(idx, :);
    end
    
    xOpt = x0(1);
    yOpt = x0(2);
end




function f = computeObjective(xy, theta1, theta2, sinPhiDiff, bcMinusA)
    x = xy(:,1);
    y = xy(:,2);
    
    % 条件1：极角约束（修正为 atan2(y, x) 以处理负坐标）
    phi_dir = atan2(y, x);  % 接收端方向角（相对于发射端）
    term1 = (phi_dir - theta1).^2;  % 直接比较角度（弧度）
    
    % 条件2：反射路径角度约束（修正为镜像法）
    % 反射路径方向角应为接收端镜像点 (x, -y) 的方向角
    phi_reflect = atan2(-y, x);  % 镜像点方向角
    term2 = (phi_reflect - theta2).^2;  % 直接比较角度（弧度）
    
    % 条件3：sin(phi1)-sin(phi2)约束（修正为反射定律）
    % phi1为入射角，phi2为反射角，满足 phi1 = phi2
    % 根据几何关系，phi1 = theta1 - alpha（alpha为反射面法线方向）
    % 此处简化为 phi1 = theta1, phi2 = theta2（需根据实际模型调整）
    term3 = (sin(theta1) - sin(theta2) - sinPhiDiff).^2;
    
    % 条件4：路径长度差约束（修正为镜像法）
    a = sqrt(x.^2 + y.^2);  % 直达路径
    b_c = sqrt(x.^2 + (2*y).^2);  % 反射路径（镜像法）
    term4 = (b_c - a - bcMinusA).^2;
    
    f = term1 + term2 + term3 + term4;
end