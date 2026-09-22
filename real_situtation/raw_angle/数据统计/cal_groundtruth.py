import math
import csv


def angle_diff(dir_angle, face_angle):
    """计算方向角度与朝向角度的差值，并调整到[-180, 180)范围"""
    diff = dir_angle - face_angle
    while diff > 180:
        diff -= 360
    while diff <= -180:
        diff += 360
    return diff


def compute_angles_and_distances(A, angle_A, B, angle_B):
    """计算设备A和设备B之间的直射径和反射径夹角及路径长度"""
    # 直射径方向
    theta_A_direct = math.degrees(math.atan2(B[1] - A[1], B[0] - A[0]))
    theta_B_direct = math.degrees(math.atan2(A[1] - B[1], A[0] - B[0]))

    # 计算A的反射径方向（A到反射点P）
    B_sym = (B[0], -B[1])  # B关于y=0的对称点
    t = -A[1] / (B_sym[1] - A[1])
    P_x = A[0] + t * (B_sym[0] - A[0])
    P = (P_x, 0.0)
    theta_A_refl = math.degrees(math.atan2(P[1] - A[1], P[0] - A[0]))

    # 计算B的反射径方向（B到反射点Q）
    A_sym = (A[0], -A[1])  # A关于y=0的对称点
    s = -B[1] / (A_sym[1] - B[1])
    Q_x = B[0] + s * (A_sym[0] - B[0])
    Q = (Q_x, 0.0)
    theta_B_refl = math.degrees(math.atan2(Q[1] - B[1], Q[0] - B[0]))

    # 计算夹角差值
    diff_A_direct = -angle_diff(theta_A_direct, angle_A)
    diff_A_refl = -angle_diff(theta_A_refl, angle_A)
    diff_B_direct = -angle_diff(theta_B_direct, angle_B)
    diff_B_refl = -angle_diff(theta_B_refl, angle_B)

    # 计算路径长度
    direct_distance = math.sqrt((B[0] - A[0]) ** 2 + (B[1] - A[1]) ** 2)

    # 反射路径长度 = A到P + P到B
    reflect_distance = (math.sqrt((P[0] - A[0]) ** 2 + (P[1] - A[1]) ** 2) +
                        math.sqrt((B[0] - P[0]) ** 2 + (B[1] - P[1]) ** 2))

    # 路径长度差值
    path_diff = reflect_distance - direct_distance

    return (diff_A_direct, diff_A_refl, diff_B_direct, diff_B_refl,
            direct_distance, reflect_distance, path_diff)


def main():
    """主程序"""
    # 定义设备和朝向
    lt = (-1, 1.5)
    angle_lt = 0.0
    angle_rt = -180.0
    rt_nodes = [(1, 1.5), (1, 2), (1.5, 2.5), (2, 2)]

    # 计算并输出CSV
    with open('angle_results1.csv', 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)

        # 写入表头
        writer.writerow(['序号', 'rt_x', 'rt_y', 'lt直射夹角', 'lt反射夹角',
                         'rt直射夹角', 'rt反射夹角', '直射径长度', '反射径长度', '反射径-直射径长度'])

        # 计算并写入每个节点
        for i, rt in enumerate(rt_nodes, 1):
            (d_lt_dir, d_lt_refl, d_rt_dir, d_rt_refl,
             direct_dist, reflect_dist, path_diff) = compute_angles_and_distances(lt, angle_lt, rt, angle_rt)

            writer.writerow([
                i, rt[0], rt[1],
                f"{d_lt_dir:.2f}", f"{d_lt_refl:.2f}",
                f"{d_rt_dir:.2f}", f"{d_rt_refl:.2f}",
                f"{direct_dist:.4f}", f"{reflect_dist:.4f}", f"{path_diff:.4f}"
            ])

    print("计算结果已保存到 angle_results1.csv")
    print("\n结果预览:")
    print("序号, rt_x, rt_y, lt直射夹角, lt反射夹角, rt直射夹角, rt反射夹角, 直射径长度, 反射径长度, 反射径-直射径长度")
    for i, rt in enumerate(rt_nodes, 1):
        (d_lt_dir, d_lt_refl, d_rt_dir, d_rt_refl,
         direct_dist, reflect_dist, path_diff) = compute_angles_and_distances(lt, angle_lt, rt, angle_rt)

        print(f"{i}, {rt[0]}, {rt[1]}, "
              f"{d_lt_dir:.2f}, {d_lt_refl:.2f}, "
              f"{d_rt_dir:.2f}, {d_rt_refl:.2f}, "
              f"{direct_dist:.4f}, {reflect_dist:.4f}, {path_diff:.4f}")


if __name__ == "__main__":
    main()