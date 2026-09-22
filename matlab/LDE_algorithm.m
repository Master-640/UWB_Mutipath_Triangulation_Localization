% function [fp_index, fp_index_fractional] = LDE_algorithm(cir, window_size, lde_thresh, required_consecutive)
% 
% % 输入：
% % cir: 复数CIR数据（长度N）
% % window_size: 滑动窗口大小 (建议4~8)
% % lde_thresh: 阈值系数 (建议3~6)
% % required_consecutive: 连续超阈tap数 (建议4~8)
% 
% % 输出：
% % fp_index：整数tap（LDE检测结果）
% % fp_index_fractional：亚tap精度结果（通过抛物线拟合）
% 
%     % 1. 计算CIR能量（功率）
%     cir_power = abs(cir).^2;
% 
%     % 2. 滑动均值滤波 (平滑噪声)
%     cir_power_smooth = movmean(cir_power, window_size);
% 
%     % 3. 估计噪声阈值
%     noise_floor = mean(cir_power_smooth(1:100)); % 取前100个tap为噪声
%     threshold = noise_floor * lde_thresh;
% 
%     % 4. First Path检测
%     consecutive_count = 0;
%     fp_index = -1;
% 
%     for i = 1:length(cir_power_smooth)
%         if cir_power_smooth(i) > threshold
%             consecutive_count = consecutive_count + 1;
%             if consecutive_count >= required_consecutive
%                 fp_index = i - required_consecutive + 1; % 取第一次连续超阈的起点
%                 break;
%             end
%         else
%             consecutive_count = 0;
%         end
%     end
% 
%     if fp_index == -1
%         warning('No First Path detected!');
%         fp_index_fractional = NaN;
%         return;
%     end
% 
%     % 5. 抛物线拟合（亚tap位置计算）
%     if fp_index > 1 && fp_index < length(cir_power)-1
%         y1 = cir_power(fp_index - 1);
%         y2 = cir_power(fp_index);
%         y3 = cir_power(fp_index + 1);
% 
%         delta = 0.5 * (y1 - y3) / (y1 - 2*y2 + y3);
%         fp_index_fractional = fp_index + delta;
%     else
%         fp_index_fractional = fp_index; % 边界点，无插值
%     end
% 
%     % 6. 画图显示（可选）
%     figure;
%     plot(10*log10(cir_power),'b'); hold on;
%     plot(fp_index,10*log10(cir_power(fp_index)),'ro','MarkerSize',8,'LineWidth',2);
%     plot(fp_index_fractional,10*log10(cir_power(round(fp_index_fractional))),'gx','MarkerSize',8,'LineWidth',2);
%     title('LDE Algorithm First Path Detection');
%     xlabel('CIR Tap Index'); ylabel('Power (dB)');
%     legend('CIR Power','Integer FP','Fractional FP');
%     grid on;
% 
% end
function [fp_indices, fp_indices_fractional] = LDE_algorithm(cir, window_size, lde_thresh, required_consecutive, max_paths)
% 输入：
% cir: 复数CIR数据（长度N）
% window_size: 滑动窗口大小 (建议4~8)
% lde_thresh: 阈值系数 (建议3~6)
% required_consecutive: 连续超阈tap数 (建议4~8)
% max_paths: 期望检测的最大路径数（如2表示检测直射+反射）

% 输出：
% fp_indices：整数tap索引（可能多个）
% fp_indices_fractional：对应的亚tap精度结果（通过抛物线拟合）

    cir_power = abs(cir).^2;
    cir_power_smooth = movmean(cir_power, window_size);

    noise_floor = mean(cir_power_smooth(1:min(100, end))); % 取前100个tap为噪声
    threshold = noise_floor * lde_thresh;

    above_thresh = cir_power_smooth > threshold;
    regions = bwlabel(above_thresh); % 标记连续区域
    fp_indices = [];
    fp_indices_fractional = [];

    for k = 1:max(regions)
        idxs = find(regions == k);
        if length(idxs) >= required_consecutive
            [~, max_idx_local] = max(cir_power(idxs));
            peak_idx = idxs(max_idx_local);

            % 抛物线插值
            if peak_idx > 1 && peak_idx < length(cir_power)-1
                y1 = cir_power(peak_idx - 1);
                y2 = cir_power(peak_idx);
                y3 = cir_power(peak_idx + 1);
                delta = 0.5 * (y1 - y3) / (y1 - 2*y2 + y3);
                peak_idx_frac = peak_idx + delta;
            else
                peak_idx_frac = peak_idx;
            end

            fp_indices(end+1) = peak_idx;
            fp_indices_fractional(end+1) = peak_idx_frac;
        end
    end

    % 若多于 max_paths，取最大能量的前 max_paths 个
    if length(fp_indices) > max_paths
        powers = cir_power(fp_indices);
        [~, idx_sort] = sort(powers, 'descend');
        fp_indices = fp_indices(idx_sort(1:max_paths));
        fp_indices_fractional = fp_indices_fractional(idx_sort(1:max_paths));
    end

    % 可选绘图
    figure;
    plot(10*log10(cir_power),'b'); hold on;
    plot(fp_indices,10*log10(cir_power(fp_indices)),'ro','MarkerSize',8,'LineWidth',2);
    for k = 1:length(fp_indices_fractional)
        x = fp_indices_fractional(k);
        if round(x) <= length(cir_power)
            plot(x, 10*log10(cir_power(round(x))), 'gx', 'MarkerSize',8,'LineWidth',2);
        end
    end
    title('LDE Algorithm Multi-path Detection');
    xlabel('CIR Tap Index'); ylabel('Power (dB)');
    legend('CIR Power','Integer Peak','Fractional Peak');
    grid on;

end
