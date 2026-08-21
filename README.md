# tsty_app

一个基于 Flutter 开发的彝语学习应用，提供沉浸式的语言学习体验。

## 项目简介

本项目是一款专注于彝语学习的移动应用，通过语音测评、AI 对话等功能，帮助用户高效学习彝语。应用包含声母、韵母、汉字、词语等多个学习模块，支持语音合成和语音识别技术。

## 功能特性

### 核心功能
- **学习模块**：包含声母、韵母、汉字、词语等多个学习单元
- **语音测评**：基于讯飞语音引擎的实时语音评测功能
- **AI 对话**：集成火山引擎 RTC 的实时语音对话功能
- **课堂测评**：自定义测评内容，支持字、词、句、篇四种类型
- **家长中心**：家长控制和使用时长管理

### 技术亮点
- **语音合成**：使用 Edge TTS 实现高质量语音播放
- **语音识别**：集成讯飞语音评测引擎
- **实时通信**：基于火山引擎 RTC 的音视频通话
- **本地存储**：使用 SharedPreferences 持久化用户数据

## 技术栈

- **框架**：Flutter 3.10.7+
- **语言**：Dart
- **状态管理**：Provider
- **网络请求**：Dio
- **本地存储**：SharedPreferences
- **音频处理**：AudioPlayers, Record
- **语音引擎**：
  - 讯飞语音评测（ISE）
  - Edge TTS 语音合成
  - 火山引擎 RTC

## 环境要求

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Android Studio / VS Code
- Android SDK（Android 开发）
- Xcode（iOS 开发，仅 macOS）

## 安装步骤

### 1. 克隆项目

```bash
git clone <repository-url>
cd tsty-master
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置环境

在项目根目录创建 `.env` 文件，配置相关 API 密钥：

```env
# 讯飞语音评测配置
XFYUN_APP_ID=your_app_id
XFYUN_API_KEY=your_api_key
XFYUN_API_SECRET=your_api_secret

# 火山引擎 RTC 配置
VOLC_APP_ID=your_app_id
```

### 4. 运行项目

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 项目结构

```
lib/
├── api/                    # API 接口
│   ├── ai_voice_chat.dart  # AI 对话接口
│   ├── auth.dart           # 认证接口
│   ├── child.dart          # 儿童信息接口
│   ├── ise.dart            # 语音评测接口
│   ├── learn.dart          # 学习内容接口
│   ├── parent_report.dart  # 家长报告接口
│   ├── tts.dart            # 语音合成接口
│   └── app_version.dart    # 版本更新接口
├── components/             # 公共组件
│   ├── ai_chat/           # AI 对话组件
│   ├── common/            # 通用组件
│   ├── custom_eval/       # 课堂测评组件
│   ├── learn/             # 学习模块组件
│   ├── login/             # 登录组件
│   ├── main/              # 主页面组件
│   ├── mine/              # 我的页面组件
│   ├── profile/           # 个人资料组件
│   └── settings/          # 设置组件
├── constants/             # 常量定义
├── pages/                 # 页面
│   ├── ai_chat/           # AI 对话页面
│   ├── custom_eval/       # 课堂测评页面
│   ├── learn/             # 学习页面
│   ├── login/             # 登录页面
│   ├── main/              # 主页面
│   ├── mine/              # 我的页面
│   └── settings/          # 设置页面
├── routes/                # 路由管理
├── services/              # 服务层
│   ├── app_update_service.dart      # 应用更新服务
│   ├── custom_evaluation_flow.dart  # 课堂测评流程
│   ├── flutter_tts_service.dart     # Flutter TTS 服务
│   ├── learning_duration_tracker.dart # 学习时长追踪
│   ├── learning_tts_player.dart     # 学习 TTS 播放器
│   ├── level_audio_player.dart      # 关卡音频播放器
│   ├── level_evaluation_flow.dart   # 关卡测评流程
│   ├── parental_control.dart        # 家长控制服务
│   ├── realtime_ai_voice_chat_session.dart # 实时 AI 语音对话
│   └── rtc_audio_call_service.dart  # RTC 音频通话服务
├── style/                 # 样式
│   └── app_theme.dart     # 应用主题
├── utils/                 # 工具类
│   ├── custom_eval_store.dart      # 课堂测评存储
│   ├── dio_utils.dart              # Dio 工具
│   ├── parent_center_prefs.dart    # 家长中心配置
│   ├── toast_utils.dart            # Toast 工具
│   ├── user_prefs.dart             # 用户配置
│   ├── yi_file_bytes.dart          # 文件字节数据
│   ├── yi_recorder.dart            # 录音器
│   ├── yi_speech_evaluator.dart    # 语音评测器
│   └── yi_tts_synthesizer.dart     # TTS 合成器
├── viewmodels/            # 视图模型
│   ├── learn.dart         # 学习视图模型
│   └── level_detail_view_model.dart # 关卡详情视图模型
├── main.dart              # 应用入口
└── splash_video.dart      # 启动视频页面
```

## 主要依赖

| 依赖包 | 版本 | 说明 |
|--------|------|------|
| flutter | sdk | Flutter SDK |
| cupertino_icons | ^1.0.8 | iOS 风格图标 |
| shared_preferences | ^2.2.3 | 本地存储 |
| dio | ^5.9.1 | 网络请求 |
| crypto | ^3.0.3 | 加密工具 |
| audioplayers | ^6.1.0 | 音频播放 |
| record | ^6.2.0 | 录音功能 |
| path_provider | ^2.1.5 | 路径获取 |
| path | ^1.9.1 | 路径操作 |
| web_socket_channel | ^3.0.3 | WebSocket 通信 |
| pretty_dio_logger | ^1.4.0 | 网络日志 |
| volc_engine_rtc | ^3.58.5 | 火山引擎 RTC |
| video_player | ^2.9.0 | 视频播放 |
| edge_tts_dart | git | Edge TTS 语音合成 |

## 开发指南

### 代码规范

- 遵循 Dart 官方代码风格指南
- 使用 `flutter analyze` 检查代码问题
- 使用 `flutter format` 格式化代码

### 构建发布

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 注意事项

1. **API 密钥**：请确保正确配置讯飞和火山引擎的 API 密钥
2. **网络权限**：Android 需要在 `AndroidManifest.xml` 中配置网络权限
3. **麦克风权限**：语音功能需要麦克风权限，请在对应平台配置
4. **存储权限**：录音和音频播放需要存储权限

## 常见问题

### 1. 依赖安装失败

```bash
flutter clean
flutter pub get
```

### 2. iOS 构建失败

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### 3. 语音评测失败

- 检查讯飞 API 密钥是否正确配置
- 确认网络连接正常
- 检查麦克风权限是否已授予

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题或建议，请联系开发团队。

---

**注意**：本项目使用第三方服务（讯飞、火山引擎等），请确保遵守相关服务条款。
