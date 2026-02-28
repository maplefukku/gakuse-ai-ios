# 🎓 GakuseAI - iOS App

学生の学習ログを資産に変えるiOSアプリ

## 🚀 機能

### ✅ 実装済み

#### 学習ログ管理
- CRUD操作（作成・読み込み・更新・削除）
- カテゴリ分類（プログラミング、デザイン、ビジネス、語学、クリエイティブ、その他）
- スキル管理（スキル追加・削除、レベル設定）
- 振り返り機能（学んだこと・課題・次のステップ・気づき）
- 公開/非公開設定

#### ポートフォリオ
- 統計表示（学習ログ数、スキル数、継続日数）
- カテゴリ別分析
- 公開ログ一覧

#### AI壁打ち
- チャットUI
- 提案プロンプト
- 履歴管理
- SOUL.mdのビジョンに沿った壁打ちスタイル

#### 認証（Supabase）
- サインアップ
- ログイン
- ログアウト
- パスワードリセット
- セッション管理

#### 設定
- プロフィール編集
- テーマ切り替え（ライト/ダーク/システム）
- 通知設定
- 自動保存設定
- データエクスポート（TODO）

### ⚠️ 要実装

- API連携（バックエンドAPIと統合）
- プッシュ通知
- データ同期
- オフライン対応

## 🛠 技術スタック

- **Framework:** SwiftUI
- **Language:** Swift 6.0
- **Architecture:** MVVM
- **iOS:** 17.0+
- **Backend:** Supabase (Auth)
- **Storage:** ローカルJSON (PersistenceService)

## 📁 プロジェクト構成

```
GakuseAI/
├── Models/              # データモデル
│   └── LearningLog.swift
├── ViewModels/          # ビューモデル
│   ├── AuthViewModel.swift
│   ├── ContentViewModel.swift
│   ├── LearningLogViewModel.swift
│   ├── PortfolioViewModel.swift
│   ├── AIChatViewModel.swift
│   └── ProfileViewModel.swift
├── Views/               # ビュー
│   ├── ContentView.swift
│   ├── LearningLogView.swift
│   ├── PortfolioView.swift
│   ├── AIChatView.swift
│   ├── ProfileView.swift
│   └── Auth/
│       ├── LoginView.swift
│       └── SignUpView.swift
├── Services/            # サービス
│   ├── APIService.swift
│   ├── PersistenceService.swift
│   └── Auth/
│       ├── SupabaseManager.swift
│       └── AuthService.swift
└── GakuseAIApp.swift    # エントリーポイント
```

## 🎨 設計哲学

SOUL.mdのビジョンに基づいて設計：

- **「人は入力しない」** → 自動保存、シームレスなUX
- **「学習ログを資産に変える」** → ポートフォリオ機能、公開設定
- **「AI壁打ち」** → 意図→仮説→実験のエンジン
- **「採用や案件は副産物」** → ポートフォリオは成長の記録として捉える

## 🔧 セットアップ

### 前提条件

- Xcode 16.0+
- XcodeGen (`brew install xcodegen`)

### 手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-org/gakuse-ai-ios.git
cd gakuse-ai-ios

# 2. Xcodeプロジェクトを生成
xcodegen generate

# 3. Xcodeで開く
open GakuseAI.xcodeproj

# 4. Supabase設定
# - SupabaseManager.swift の URL と Key を更新
```

## 📱 スクリーンショット

（TODO: 追加）

## 🗺 ロードマップ

### v1.0（現在）
- ✅ 基本機能実装
- ✅ 認証機能
- ⚠️ ローカルデータ保存

### v1.1
- 🔲 API連携
- 🔲 データ同期
- 🔲 プッシュ通知

### v1.2
- 🔲 ウィジェット対応
- 🔲 Siri Shortcuts
- 🔲 WatchOS対応

## 📄 ライセンス

MIT

---

**開発者:** GakuseAI Team
**更新日:** 2026-03-01
