---
name: Flutter 环境与本地运行方式
description: 本项目(热量拍 calorie_snap)的 Flutter SDK 安装位置、国内镜像配置、本地运行命令
type: project
---

本项目是 Flutter 拍照识别食物热量 App(calorie_snap),用户在 Windows 10 上本地运行看效果。

**关键事实**:
- Flutter SDK 装在 `C:\flutter`(git clone stable),命令用完整路径 `C:\flutter\bin\flutter`
- 已设 setx 永久环境变量走清华镜像:PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub、FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
- 平台工程已生成(web + windows),用 `flutter create . --platforms=web,windows` 补齐
- 本地看效果用 `C:\flutter\bin\flutter run -d chrome`(浏览器最快,无需 VS C++ 工具链)

**Why:** 用户网络在国外源下载会卡死(曾因 Dart SDK 下载卡在国外源导致进程死锁,需重启);识别功能需用户自己申请阿里云百炼免费 Key。

**How to apply:** 后续跑/构建都用 C:\flutter\bin\flutter 全路径 + chrome 目标;镜像变量已永久生效无需重设;新终端才能让 setx 变量生效;运行终端需常开,改代码按 r 热重载。