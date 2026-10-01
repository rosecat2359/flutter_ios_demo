# flutter_ios_demo

一个最小的 Flutter **iOS** 示例应用（单屏待办清单），用于先把「本地开发 → Git → GitHub Actions 云端构建 iOS」这条链路跑通。

- 应用逻辑只有内存状态：不依赖任何第三方包、不联网、不需要 iOS 权限，因此首次构建风险最低。
- iOS 构建**不需要 Apple 开发者账号**：CI 产出未签名的 `Runner.xcarchive` 与模拟器版 `Runner.app`。

## 目录

```
lib/
  main.dart                      应用入口与主题
  models/todo_item.dart          不可变数据模型
  state/todo_controller.dart     纯 Dart 状态逻辑（ChangeNotifier）
  screens/todo_home_page.dart    单屏 UI：输入栏 + 列表 + 空状态
test/
  todo_controller_test.dart      单元测试：增删改、空输入、计数
  todo_home_page_test.dart       widget 测试：添加、勾选、删除、清除已完成
  widget_test.dart               冒烟测试：应用可启动
.github/workflows/ios.yml        iOS 构建与测试流水线
```

## 本地开发

本机是 Linux，**无法本地编译 iOS**（需要 Xcode）。本地只做源码与逻辑验证，iOS 编译正确性由 GitHub Actions 的 macOS runner 保证。

本机环境有一处特殊性：`flutter` 的 snap 启动器在此不可用（它要写只读的 `$HOME/snap/flutter`），系统也没有 git。因此工具链被引导到仓库外层目录：

```
../.tooling/
  env.sh              环境装配（PATH / CA / HOME / PUB_CACHE）
  bootstrap-sdk.sh    下载并解压 Flutter SDK
  flutter/            Flutter SDK 3.47.5
  pub-cache/          依赖缓存
```

首次使用：

```bash
bash .tooling/bootstrap-sdk.sh   # 已执行过则可跳过；下载约 1.5 GB
. .tooling/env.sh                # 装配 PATH、git、flutter
addf                             # 进入应用目录
flutter pub get
flutter analyze
flutter test
```

## CI：iOS 云端构建

`.github/workflows/ios.yml` 在 `push` / `pull_request` 到 `main` 以及手动触发时运行：

| Job | 运行环境 | 内容 |
| --- | --- | --- |
| `build-ios` | `macos-15`（Xcode 16.4） | `pub get` → `doctor -v` → `analyze` → `test` → `flutter build ipa --release --no-codesign`（产出 `Runner.xcarchive`）→ 校验归档结构 |
| `build-simulator` | `macos-15` | `flutter build ios --debug --simulator`，产出可装进模拟器的 `Runner.app` |

产物（Artifacts，保留 14 天）：

- `ios-unsigned-archive`：`Runner.xcarchive`（未签名真机归档）
- `ios-simulator-app`：`Runner.app`（iOS Simulator 版本）

> Flutter 3.47 起 `flutter build ipa` 就是归档命令（别名 `xcarchive`），输出到 `build/ios/archive/Runner.xcarchive`。加 `--no-codesign` 时 Flutter 会**保留归档、显式跳过 ipa 生成**（ipa 步骤依赖签名），所以本流水线不产出 `.ipa`。

工作流中不引用任何 Secret。`macos-15` 是刻意固定的：`macos-latest` 已迁到 macOS 26，工具链会漂移。

## 如何验证构建结果

1. 打开仓库的 **Actions** 标签，进入 `ios` 工作流最近一次运行，确认两个 job 均为绿色。
2. 在该次运行的页面底部 **Artifacts** 处下载 `ios-unsigned-archive` 与 `ios-simulator-app`。
3. 本地校验产物（无需 Mac）：

   ```bash
   unzip -l ios-unsigned-archive.zip   # 应含 Runner.xcarchive/Info.plist 与 Products/Applications/Runner.app
   unzip -l ios-simulator-app.zip      # 应含 Runner.app/Info.plist 等
   ```

模拟器包可在 Mac 上运行验证：

```bash
xcrun simctl boot "iPhone 16"
xcrun simctl install booted Runner.app
xcrun simctl launch booted com.example.flutterIosDemo
```

## 限制：未签名归档不能装到真机

`Runner.xcarchive` 是未签名的，无法安装到真实 iPhone，也不会上架或走 TestFlight。它能证明 iOS 代码真实编译链接通过，并作为后续签名的输入。

要产出**可安装**的 ipa，需要付费 Apple 开发者账号（$99/年），在仓库 Secrets 中加入：

| Secret | 内容 |
| --- | --- |
| `BUILD_CERTIFICATE_BASE64` | `.p12` 分发证书，base64 编码 |
| `P12_PASSWORD` | 导出 `.p12` 时设置的密码 |
| `BUILD_PROVISION_PROFILE_BASE64` | `.mobileprovision`，base64 编码 |
| `KEYCHAIN_PASSWORD` | CI 上临时钥匙串的任意密码 |
| `APPLE_TEAM_ID` | 10 位 Team ID |

然后在 `build-ios` 中**去掉 `--no-codesign`**（Flutter 只有在允许签名时才会执行 ipa 步骤），并增加：导入证书到临时钥匙串 → 安装 provisioning profile 到 `~/Library/MobileDevice/Provisioning Profiles` → `flutter build ipa --release --export-method development`（或 `ad-hoc` / `app-store`）。参考 [Flutter iOS 部署文档](https://docs.flutter.dev/deployment/ios)。

## 版本

- Flutter 3.47.5 stable / Dart 3.13.4（本机与 CI 严格一致，避免行为漂移）
- 仅生成 iOS 平台（无 Android / Web / 桌面端目录）
