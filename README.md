# UWB 多径三角定位 (Multipath Triangulation Localization)

基于 **Nordic nRF52840-DK + Qorvo/Decawave DW3000** 的 UWB 多径定位实验平台。
通过提取信道冲激响应 (CIR)，估计各路信号的 **AOA / AOD / rTOF**，再利用多径几何关系反演发射端与接收端的二维坐标。

## 硬件平台

| 部件 | 型号 |
| --- | --- |
| 主控开发板 | Nordic nRF52840-DK (PCA10056) |
| UWB 收发芯片 | DW3000 C0 Arduino Shield |
| 调试器 | SEGGER J-Link (板载) |

## 目录结构

```
.
├── Source/                      固件源码（main.c、平台适配层）
│   ├── main.c                   应用入口，按 example_selection.h 选择示例
│   ├── config/sdk_config.h      Nordic SDK 配置
│   └── platform/                DW3000 平台移植层（SPI / 互斥 / 睡眠）
├── SEGGER/                      SEGGER RTT 调试输出库
├── Setup/                       SEGGER 链接脚本
├── Backup/                      接收端固件实验版本（simple_rx_cir_v1~v4 等）
│
├── matlab/                      MATLAB 脚本（*.mlx 实时脚本 / *.m 函数）
├── docs/                        说明与笔记（算法推导、解析说明）
├── 结果输出/                     散落的结果输出（角度估计 txt、峰值分析 mat）
├── media/                       【本地保留】实验录像与音频素材
│
├── dw3000_api.emProject         SEGGER Embedded Studio 工程文件（构建入口）
├── dw3000_api.emSession         IDE 会话
├── dw3000_api_Debug.jlink       J-Link 调试配置
├── flash_placement.xml          链接配置
├── build.py                     批量编译测试脚本
├── README.md / README.txt       项目说明 / 厂商原始说明
│
├── Data/                        【本地保留】原始采集数据（CIR / RTT 原始日志）
├── Video/                       【本地保留】实验过程录像
├── sdk/                         【本地保留】Nordic nRF5 SDK 17.0.2
├── Output/                      【本地保留】编译产物
│
├── real_situtation/             真实场景实测：原始角度数据与处理结果
├── CDF_choose_data/             不同距离下的角度数据筛选与 CDF 结果
├── CDF_choose_data_packetnum/   数据包数量对角度估计的影响
├── 批量定位结果/                 批量定位结果、几何反演结果与统计摘要
├── 批量定位结果_packet/          按数据包长度分组的批量定位结果
├── angle_result/                角度处理结果
├── result/                      角度标定与候选解
├── overdetermined_equations/    超定方程组求解（7 方程 / 双 AOA）
├── doubleAOA_solution_code/     双 AOA 定位解算
├── backup_localization/         定位算法早期版本
├── 正确的数据处理方案/           数据处理的鲁棒性方案说明
├── 自动化成果/                   数据处理自动化脚本
└── 数据留存/                    【本地保留】峰值分析中间结果
```

> 标记【本地保留】的目录因体积或授权原因未纳入版本管理，见 `.gitignore`。
> 个人材料（学生名单、个人备注、IDE 本地配置）已移出本工程，存放于 `../_personal/nRF52840-DK/`。

## 编译

1. 安装 **SEGGER Embedded Studio for ARM 5.10a**（Windows）。
2. 下载 **nRF5 SDK 17.0.2**，解压到工程根目录下的 `sdk/`。
3. 编辑 `dw3000_api.emProject`，将其中的 `NordicSDKDir` 宏指向本地 SDK 路径。
4. 打开工程，选择 `Build -> Build and Run` 即可编译并下载到开发板。

在 `Source/config/example_selection.h` 中**只保留一个** `#define TEST_*`，用于切换测试示例。

## 数据处理流程

```
DW3000 采集 CIR
      │  (RTT 串口输出, 见 Data/*.log)
      ▼
go_parse*.mlx / process_data_1.py      解析 CIR 原始文本
      │
      ▼
choose_suitable_data*.mlx              峰值筛选（主峰/次峰一致性）
      │
      ▼
filter_fixed_phase_error.mlx           相位误差修正
      │
      ▼
角度估计 (AOA / AOD) + rTOF
      │
      ▼
overdetermined_equations/              多径几何方程组求解
      │
      ▼
批量定位结果/                          坐标反演与 CDF 统计
```

核心思路：发射端坐标与 AOD 确定一条直射线，反射面参数与 AOA 确定一条反射线，
两条直线交点即为接收端位置；多径条件下的过定方程组用最小二乘 / 网格搜索求解。

## 说明

- MATLAB 脚本使用 `.\Data\...` 形式的**相对路径**，请在**工程根目录**下运行 MATLAB。
  脚本与函数已归入 `matlab/`，首次使用先执行 `addpath('matlab')` 以解析函数调用。
- `结果输出/`（根目录散落的结果）与 `result/`（角度标定）是两个不同目录，勿混淆。
- `sdk/`（Nordic nRF5 SDK）与 `Source/` 中的 SEGGER / Decawave 移植代码版权归各自厂商所有，分发需遵守其许可协议。
