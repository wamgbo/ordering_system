🍽️ Ordering System

一個使用 Flutter 開發的跨平台點餐系統專案，支援 Android、iOS 與 Web。
此專案可作為課程專題、系統雛型或後續串接後端（如 Firebase / REST API）的基礎架構。

📌 專案簡介

Ordering System 是一套以 Flutter 為核心的前端點餐應用，設計目標為：

快速建立點餐流程 UI

提供清楚的程式結構，方便擴充

作為實務專案或學習 Flutter 架構的範例

✨ 功能概覽

目前專案包含以下功能與設計重點：

📱 Flutter 跨平台支援（Android / iOS / Web）

🧭 基本頁面導覽（Navigator）

🧱 模組化 UI 元件設計

📦 清楚的資料模型結構

🛠️ 易於擴充後端服務（Firebase / API）

本專案著重於「前端架構與流程設計」，後端可依需求自行串接。

🗂️ 專案結構
ordering_system/
├── android/                 # Android 原生設定
├── ios/                     # iOS 原生設定
├── web/                     # Web 設定
├── lib/                     # Flutter 主要程式碼
│   ├── main.dart            # 程式進入點
│   ├── models/              # 資料模型
│   ├── screens/             # 畫面頁面
│   ├── widgets/             # 共用 UI 元件
├── test/                    # 測試程式
├── pubspec.yaml             # 套件與專案設定
└── README.md

🚀 開發環境需求

Flutter SDK（建議使用最新穩定版）

Dart SDK（隨 Flutter 附帶）

Android Studio / VS Code

Android Emulator 或實體裝置
-（iOS 需 macOS + Xcode）

▶️ 執行專案
1️⃣ 下載專案
git clone https://github.com/wamgbo/ordering_system.git
cd ordering_system

2️⃣ 安裝套件
flutter pub get

3️⃣ 執行應用程式
flutter run


指定平台執行：

Android

flutter run -d android


iOS

flutter run -d ios


Web

flutter run -d chrome

📦 建置 Release 版本
Android
flutter build apk --release


或（上架 Play Store）

flutter build appbundle --release

iOS
flutter build ios --release


上架前請完成憑證、簽章與 Firebase（若有）設定。

🧪 測試

執行 Flutter 單元測試：

flutter test

🔧 可擴充方向（建議）

🔐 使用者登入（Firebase Auth）

☁️ 雲端資料庫（Firestore / Realtime Database）

🧾 訂單記錄與歷史查詢

🛎️ 即時訂單狀態更新

💳 金流整合（僅作教學用途）

📄 授權條款

本專案採用 MIT License
可自由使用、修改與散佈。

🙋‍♂️ 作者

GitHub：@wamgbo

如有建議或問題，歡迎提出 Issue 或 Pull Request。
