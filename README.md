# 热量拍 (Calorie Snap)

一个 Flutter 双端(Android + iOS)App:拍照识别食物 → 估算热量 → 结合身高体重给出健康建议。

## 功能

- 📷 拍照 / 相册选图,调用多模态大模型识别食物并估算热量、蛋白质、碳水、脂肪
- 🧮 根据身高、体重、年龄、性别、活动水平、目标计算 BMI / BMR / TDEE / 每日推荐摄入
- 📊 今日摄入进度、历史饮食记录(本地保存)
- 🔑 支持自行配置大模型 API Key

## 项目结构

```
lib/
├── main.dart                 # 入口 + 底部导航
├── models/
│   ├── food_result.dart      # 食物 / 一餐结果模型
│   └── user_profile.dart     # 用户资料模型
├── services/
│   ├── health_calculator.dart      # 健康指标计算
│   ├── food_recognition_service.dart # 大模型识别
│   └── storage_service.dart        # 本地存储
├── state/
│   └── app_state.dart        # 全局状态 (Provider)
└── pages/
    ├── recognize_page.dart   # 拍照识别
    ├── history_page.dart     # 历史记录
    └── profile_page.dart     # 我的 / 资料设置
```

## 环境准备

本机需要先安装 Flutter SDK(当前机器尚未安装)。

1. 下载并安装 Flutter:https://docs.flutter.dev/get-started/install
2. 配置好 `flutter` 命令到 PATH
3. 验证:

```bash
flutter --version
flutter doctor
```

## 运行与构建

在项目根目录执行:

```bash
# 安装依赖
flutter pub get

# 连接手机 / 启动模拟器后运行
flutter run

# 打包安卓 APK(输出在 build/app/outputs/flutter-apk/)
flutter build apk --release

# 打包 iOS(需要 macOS + Xcode)
flutter build ios --release
```

> 首次运行前,如果没有 `android/`、`ios/` 目录,先在项目根目录执行:
> ```bash
> flutter create .
> ```
> 这会补齐平台工程文件,同时保留已有的 `lib/`、`pubspec.yaml`。

## 配置 API Key

1. 打开 App → 底部「我的」页面
2. 在「大模型 API Key」中填入你的 Key,点击保存
3. 默认使用阿里云百炼(通义千问 `qwen-vl-plus`)的 OpenAI 兼容接口

申请地址:阿里云百炼控制台 https://bailian.console.aliyun.com

### 换成其他模型

编辑 [`food_recognition_service.dart`](lib/services/food_recognition_service.dart):
- 修改 `_endpoint` 与 `_model`
- 若接口格式不同(如 Gemini / GPT-4o),调整请求体 `body` 与响应解析部分

## 权限说明

拍照 / 相册功能需要在平台工程中声明权限:

- **Android**:`android/app/src/main/AndroidManifest.xml` 添加相机权限
- **iOS**:`ios/Runner/Info.plist` 添加 `NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription`

(`image_picker` 插件的官方文档有完整示例)

## 注意

- 大模型对热量的估算为**近似值**,仅供参考,不能作为医疗或营养诊断依据
- 识别需要联网,且会消耗对应大模型的 API 调用额度