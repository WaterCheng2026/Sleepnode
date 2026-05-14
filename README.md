# Sleepnode

睡眠健康管理 App，支持睡眠日记记录、数据可视化、CBT-I 治疗方案引导等功能。

---

## 本地启动

### 前置条件

| 工具 | 版本要求 |
|------|----------|
| Flutter SDK | ≥ 3.11.5 |
| Dart SDK | ≥ 3.11.5（随 Flutter 附带） |
| Android Studio / Xcode | 最新稳定版 |

### 步骤

```bash
# 1. 克隆仓库
git clone https://github.com/WaterCheng2026/Sleepnode.git
cd Sleepnode

# 2. 安装依赖
flutter pub get

# 3. 检查环境（可选）
flutter doctor

# 4. 启动 App
flutter run               # 自动选择已连接设备
flutter run -d android    # 指定 Android
flutter run -d ios        # 指定 iOS（需 macOS + Xcode）
```

---

## 技术栈

### Android

| 层级 | 技术 |
|------|------|
| 语言 | Kotlin |
| 构建工具 | Gradle（Kotlin DSL，`build.gradle.kts`） |
| 编译目标 | Java 17 |
| 包名 | `com.sleepnode.sleepnode` |
| Flutter 接入 | Flutter Gradle Plugin |

### iOS

| 层级 | 技术 |
|------|------|
| 语言 | Swift |
| 项目管理 | Xcode（`.xcodeproj` / `.xcworkspace`） |
| 依赖管理 | CocoaPods（`Podfile`） |
| Bundle ID | `com.sleepnode.sleepnode` |
| 最低系统版本 | 根据 Flutter 最低支持版本 |

### Flutter（跨端共用）

| 类别 | 包 / 版本 |
|------|-----------|
| UI 框架 | Flutter + Material Design |
| 状态管理 | `provider ^6.1.2` |
| 图表可视化 | `fl_chart ^0.68.0` |
| 本地持久化 | `shared_preferences ^2.3.2` |
| 日期国际化 | `intl ^0.19.0` |

---

## 项目结构

```
lib/
├── main.dart                 # 入口，路由与主题初始化
├── theme.dart                # 全局主题配置
├── models/
│   ├── app_state.dart        # 全局状态（Provider）
│   └── sleep_diary.dart      # 睡眠日记数据模型
├── screens/
│   ├── home_screen.dart      # 首页（睡眠概览）
│   ├── diary_screen.dart     # 睡眠日记录入
│   ├── progress_screen.dart  # 数据趋势图表
│   ├── treatment_screen.dart # CBT-I 治疗方案
│   ├── community_screen.dart # 社区
│   └── sos_screen.dart       # 紧急求助
└── widgets/
    ├── app_header.dart       # 顶部导航栏
    ├── bottom_nav_bar.dart   # 底部标签栏
    └── metric_card.dart      # 睡眠指标卡片
```
