# Handoff: つかいきり — 全画面デザイン

## Overview

「つかいきり」は冷蔵庫の在庫を起点に献立を提案し、足りない食材を買い物リストに自動追加する家庭向けアプリです。在庫を「使い切る」ことを助けるのがコンセプト。日常的に毎日使う実用ツールとして設計されています。

## About the Design Files

`design_handoff/screens/` 以下の HTML ファイルは **HTML プロトタイプ（デザインリファレンス）** です。実際の見た目・インタラクション・状態遷移を確認するための参照物であり、本番コードとして直接使うものではありません。

開発タスクは、これらの HTML デザインを **ターゲットコードベースの環境で忠実に再実装すること** です。
- **iOS**: SwiftUI + UIKit
- **Android**: Jetpack Compose
- **macOS**: SwiftUI (AppKit 補完) — Mac Catalyst ではなくネイティブ macOS 推奨

## Platforms

| プラットフォーム | フォームファクタ | レイアウト | 参照ファイル |
|---|---|---|---|
| iOS | スマホ (393×852) | 単一ペイン | `*スマホ（iOS）.html` |
| iOS | iPad 横向き (1194×834) | 二ペイン | `*タブレット（iOS）.html` |
| Android | スマホ (412×892) | 単一ペイン | `*スマホ（Android）.html` |
| Android | タブレット横向き (1194×834) | 二ペイン | `*タブレット（Android）.html` |
| **macOS** | **ウィンドウ (1280×800)** | **サイドバー＋三ペイン** | `つかいきり macOS.html` |

## Fidelity

**High-fidelity（ハイフィデリティ）** — ピクセル精度のモックアップです。色・タイポグラフィ・スペーシング・インタラクション・状態遷移がすべて確定しています。開発者はこの通りに再実装してください。

---

## Design Tokens

### Colors
```
bg:         #F7F5F0  // オフホワイト背景
card:       #FFFFFF  // カード背景
ink:        #2A2723  // 主要テキスト
sub:        #8C877C  // サブテキスト
faint:      #B8B2A6  // 補足テキスト・非アクティブ
line:       #EDE9E1  // 区切り線・ボーダー

// アクセント（緑）
green:      #1F7A55  // プライマリアクション・アクセント
greenInk:   #15613F  // 緑背景上のテキスト
greenSoft:  #E8F3EC  // 緑の薄い背景

// 賞味期限ステータス
plenty:     #A8A296  // 余裕あり（グレー）
plentySoft: #F0EEE7  // 余裕背景
near:       #E0892F  // 期限間近（オレンジ）
nearSoft:   #FBEBD8  // 間近背景
over:       #D14B3D  // 期限超過（赤）
overSoft:   #F8E2DD  // 超過背景
```

### Typography
```
プライマリフォント: 'M PLUS Rounded 1c'  (weight: 500 / 700 / 800)
ブランドフォント:   'Zen Maru Gothic'    (weight: 500 / 700)
フォールバック:     system-ui, sans-serif
```

### Spacing & Radius
```
カード角丸:        16px (標準), 18px (大カード)
ボタン角丸:        18px (主要ボタン), 14px (セカンダリ), 999px (ピル型)
アイコンタイル:    34–46px 正方形, 角丸 10–14px
ステータスバー高さ: iOS = 56px top padding, Android = 12px
```

### Shadows
```
カード: 0 1px 2px rgba(40,39,35,0.04)
主要ボタン: 0 12px 26px rgba(31,122,85,0.30)
FAB: 0 8px 20px rgba(31,122,85,0.32)
```

---

## Screens / Views

### 1. 在庫画面（ホーム）
**ファイル**: `在庫画面 スマホ.html` / `在庫画面 タブレット.html`（iOS） / `在庫画面 Android スマホ.html` / `在庫画面 Android タブレット.html`

**目的**: アプリのホーム。冷蔵庫在庫の一覧。賞味期限が近い順に把握し、献立提案・カメラ登録へ進む。

**スマホレイアウト（390px）**
- 上部: アプリ名「つかいきり」+ 在庫数バッジ + 検索アイコン
- 中部: 期限グループタブ（今日・もうすぐ / 今週のうちに / まだ余裕）でフィルタ
- 食材カード（各: 絵文字アイコン + カテゴリカラータイル / 食材名 / 数量+単位 / 賞味期限バッジ）
- 右スワイプ: 食べた / 左スワイプ: 削除
- 下部固定: 「献立を提案する」バー (高さ62px, bg #1F7A55)
- 右下FAB: カメラアイコン (48×48px, bg #1F7A55, shadow)
- 左下FAB: 手動追加ボタン

**タブレットレイアウト（1194×834）**
- 左ペイン (380px): 食材一覧 + カテゴリフィルタチップ
- 右ペイン: 選択食材の詳細・編集（名前 / 数量 / カテゴリ / 賞味期限 / 保存場所）

**3状態**: 通常 / 空の状態（「食材を登録しましょう」+ カメラ・手動追加ボタンを画面下部に） / 読み込み中（シマーアニメーション）

**賞味期限バッジ色**:
- 超過: bg #F8E2DD, text #D14B3D
- 間近(0–3日): bg #FBEBD8, text #E0892F
- 余裕: bg #F0EEE7, text #8A8278

---

### 2. カメラ登録
**ファイル**: `カメラ登録 スマホ.html` / `カメラ登録 タブレット.html` / Android 各版

**目的**: 冷蔵庫内を撮影→AIが食材候補を出し→人が確認・修正→在庫に登録。

**4ステップフロー**:
1. **撮影前**: ダークカメラUI。シャッターボタン(64px 白丸)・ライブラリボタン。最大10枚、枚数インジケータ。「解析する」ボタンは1枚以上で活性化
2. **解析中**: 緑アイコンのパルスアニメーション + 進捗バー(アニメーション)
3. **候補確認**: 各候補に チェックON/OFF + 名前・数量・単位・カテゴリ編集 + 確信度表示(high/mid/low)。低確信度は薄く表示。「確定して在庫に追加」ボタン
4. **エラー**: 一般エラーメッセージ + 「もう一度試す」ボタン

**タブレット**: 候補確認が二ペイン（左=候補リスト / 右=選択候補の拡大編集）

---

### 3. 献立提案
**ファイル**: `献立提案 スマホ.html` / `献立提案 タブレット.html` / Android 各版

**目的**: 在庫から作れる献立をAIが提案。

**5状態**:
1. **提案前**: 条件選択チップ（おまかせ / 主菜のみ / あと1品 / 時短）+ 「在庫から提案する」ボタン
2. **生成中**: パルスアニメーション + 進捗バー
3. **提案結果**: 献立カード一覧（料理名 / 使う食材チップ / 調理家電バッジ / 調理時間 / 期限間近食材の赤バッジ）。タップで詳細へ
4. **在庫わずか**: 新規食材も含む提案に切り替わる旨を案内バナー付き
5. **エラー**: 一般エラーメッセージ

**詳細画面**: 材料リスト（在庫あり・不足を色分け） + 手順のステップ + 「献立に決める」「不足分を買い物リストへ」ボタン

**タブレット**: 左=献立候補リスト / 右=選択献立の詳細（材料・手順）常時表示

---

### 4. 買い物リスト確認
**ファイル**: `買い物リスト確認 スマホ.html` / `買い物リスト確認 タブレット.html` / Android 各版

**目的**: 献立に不足する食材を外部リストアプリに追加する。

**iOS**: リマインダー連携 / **Android**: Google ToDo 連携

**4状態**:
1. **通常**: 不足食材一覧（チェックON/OFF / 数量ステッパー / 由来献立名タグ）+ 追加先リスト選択カード + 「◯件を追加」ボタン
2. **追加中**: プログレスアニメーション
3. **完了**: 大きなチェックマーク + 追加した食材チップ + 「リマインダー/Google ToDo を開く」ボタン
4. **エラー**: 「リストに追加できませんでした。時間をおいてお試しください。アクセス許可をご確認ください。」

**タブレット**: 左=不足食材一覧 / 右=追加先リスト選択パネル（常時展開）

---

### 5. 初回オンボーディング（6ステップ）
**ファイル**: `オンボーディング スマホ.html` / `オンボーディング タブレット.html` / Android 各版

**全6ステップ**:
1. **ようこそ**: アプリアイコン + 一言説明 + 3つの価値（撮るだけ登録 / 使い切り献立 / 買い物リスト連携）+ 「はじめる」
2. **AIを選ぶ**: Claude / OpenAI / Gemini / Grok からプロバイダ選択（Vision対応バッジ付き）+ APIキー入力 + 各社キー取得ページへのリンク
3. **連携の許可**: iOS = リマインダーアクセス許可 / Android = Googleでサインイン
4. **リストを選ぶ**: 既存リストから選択 or 新規作成
5. **調理家電**: ホットクック・ヘルシオをトグル選択。ONでシリーズ・容量を選択
6. **完了**: 設定サマリー（AI / 連携先 / 調理家電）+ 「食材を登録してはじめる」

**共通UI**: 上部進行インジケータバー + 戻るボタン + 右上スキップ（あとで / 持っていない）

**タブレット**: 左=緑のステップレール（現在地・完了チェック表示）/ 右=各ステップの内容

---

### 6. 設定
**ファイル**: `設定 スマホ.html` / `設定 タブレット.html` / Android 各版

**セクション構成**:
- **一般**: 言語選択（日本語 / English / システムに従う）
- **AI（食材認識・献立提案）**: プロバイダ選択（Claude/OpenAI/Gemini/Grok）+ APIキー登録 + Vision対応表示 + キー未登録時の取得リンク
- **連携**: 買い物リスト（iOS=リマインダー / Android=Google ToDo、リスト変更）+ 調理家電（ホットクック・ヘルシオ、型・容量選択）
- **データ**: iOS=iCloud同期 / Android=Google Drive同期（ON/OFF + 最終同期日時）
- **サポート**: 作者をサポート（Buy Me a Coffee、黄色 #FFDD00 ブランドカラー）+ ヘルプ + このアプリについて

**スマホ**: 各行タップで詳細スライド（translateX トランジション 0.28s）
**タブレット**: 左=設定ナビ（6セクション）/ 右=選択セクション内容

---

### 7. ヘルプ / このアプリについて
**ファイル**: `ヘルプ スマホ.html` / `ヘルプ タブレット.html` / Android 各版

**コンテンツ（読み物レイアウト）**:
1. アプリアイコン + バージョン + 一言紹介
2. **かんたんな使い方** (STEP 1–4): 撮る → 在庫確認 → 献立提案 → 買い物リスト
3. **賞味期限データについて**: USDA/FSIS の FoodKeeper をベースに和食材補完。オレンジのコールアウトで「あくまで目安」明記
4. **出典リンク**: FoodKeeper (foodsafety.gov) / Data.gov
5. **手動修正の案内**: 緑のコールアウト「賞味期限はいつでも詳細画面から修正できます」
6. 規約 / プライバシーポリシー / FAQ へのリンク

**タブレット**: 左=目次（TOC、クリックでスクロール + 現在地ハイライト連動）/ 右=本文（最大680px中央寄せ）

---

## Interactions & Behavior

### アニメーション
| 要素 | 内容 |
|---|---|
| 画面遷移（スマホ詳細） | translateX: 0→-100% / 100%→0、duration 280ms、cubic-bezier(.2,.8,.2,1) |
| カード出現 | scale 0.6→1 + opacity 0→1、duration 500ms、cubic-bezier(.2,.9,.3,1.2) |
| 解析中パルス | scale 1→1.08→1、opacity 1→0.82→1、duration 1500ms、infinite |
| 進捗バー | width 8%→97%、duration 1600–2300ms、ease-in-out |
| トグルスイッチ | bg + knob 位置、duration 200ms |
| スワイプアクション | translateX、reveal action buttons |

### 状態トランジション
- 解析中 → 結果: 2400ms の setTimeout（本番は API レスポンス待ち）
- 追加中 → 完了: 1700ms の setTimeout（本番は API レスポンス待ち）

---

## Platform Differences (iOS vs Android)

| 機能 | iOS | Android |
|---|---|---|
| 買い物リスト | リマインダー | Google ToDo |
| クラウド同期 | iCloud | Google Drive |
| オンボーディング連携 | リマインダーアクセス許可 | Googleでサインイン |
| ステータスバー padding | 56px | 12px |
| デバイスフレーム | Dynamic Island / ホームインジケータ | パンチホール / ナビバー |

---

## Data Model (参考)

```typescript
// 食材
interface FoodItem {
  id: string;
  name: string;
  emoji: string;
  qty: number;
  unit: string;
  cat: '肉' | '魚' | '野菜' | '乳製品' | '調味料' | '常備品';
  days: number;  // 賞味期限までの残り日数（負=超過）
  location?: string;  // 保存場所
}

// 賞味期限ステータス
type ExpiryStatus = 'over' | 'near' | 'plenty';
// over: days < 0, near: 0 <= days <= 3, plenty: days > 3

// 献立
interface Meal {
  id: number;
  name: string;
  emoji: string;
  device: 'hotcook' | 'healsio' | 'normal';
  time: number;  // 分
  useNear: boolean;  // 期限間近食材を使うか
  ingredients: { name: string; emoji: string; inStock: boolean; qty: string }[];
  steps: string[];
}

// 設定
interface AppSettings {
  language: 'ja' | 'en' | 'system';
  aiProvider: 'claude' | 'openai' | 'gemini' | 'grok';
  apiKey: Record<string, string>;
  shoppingListApp: 'reminder' | 'google_todo';
  shoppingList: string;
  hotcook: { enabled: boolean; series: string; capacity: string } | null;
  healsio: { enabled: boolean; series: string; capacity: string } | null;
  cloudSync: boolean;
}
```

---

## Assets

- **フォント**: M PLUS Rounded 1c (Google Fonts), Zen Maru Gothic (Google Fonts)
- **アイコン**: カスタム SVG ラインアイコン（`shared.jsx` の `Icon` コンポーネントに定義。stroke ベース、24×24px グリッド）
- **食材画像**: 絵文字で代替（写真なし）
- **調理家電アイコン**: SVG（pot = ホットクック、oven = ヘルシオ）

---

## Files

| ファイル | 内容 |
|---|---|
| `shared.jsx` | デザイントークン・アイコン・共通UIパーツ（ExpiryBadge, CatTile, EmptyState, LoadingState） |
| `phoneB.jsx` | 在庫画面スマホ（案B確定形） |
| `tabletB.jsx` | 在庫画面タブレット |
| `camera.jsx` | カメラ登録スマホ |
| `cameraTablet.jsx` | カメラ登録タブレット |
| `meals.jsx` | 献立データ定義 |
| `mealsPhone.jsx` | 献立提案スマホ |
| `mealsTablet.jsx` | 献立提案タブレット |
| `shoppingPhone.jsx` | 買い物リストスマホ |
| `shoppingTablet.jsx` | 買い物リストタブレット |
| `onboarding.jsx` | オンボーディングスマホ（6ステップ） |
| `onboardingTablet.jsx` | オンボーディングタブレット |
| `settings.jsx` | 設定スマホ |
| `settingsTablet.jsx` | 設定タブレット（NAV・Pane系） |
| `helpAbout.jsx` | ヘルプ/このアプリについて（HelpBody共有） |
| `helpTablet.jsx` | ヘルプタブレット（TOC+本文） |
| `androidPlatform.jsx` | Androidプラットフォーム差分 |
| `androidSettings.jsx` | Android設定差分（Google ToDo/Drive） |
| `androidOnboarding.jsx` | Androidオンボーディング差分（Googleサインイン） |
| `macos-window.jsx` | macOS Tahoe 風ウィンドウ（Traffic Lights・Liquid Glass） |
| `macosShell.jsx` | macOS シェル（サイドバーナビ・ツールバー・ホバー utilities） |
| `macosOnboarding.jsx` | macOS 設定アシスタント（6ステップ・ステップレール） |
| `macosApp.jsx` | macOS 全7画面コンポーネント＋ルート App |

---

## macOS Screen — つかいきり macOS.html

**ファイル**: `screens/つかいきり macOS.html`（全7画面を1ファイルに統合）

**ウィンドウ構成** (1280×800)
```
MacWindow
├── AppSidebar (216px)  — Traffic Lights + アプリ名 + nav items
└── Content area (1064px)
    ├── MacBar (50px)  — 画面ごとのツールバー（⌘ショートカット付き）
    └── Screen content (750px high)
```

**画面一覧（サイドバーで切替）**

| nav key | 画面 | レイアウト |
|---|---|---|
| `inventory` | 在庫 | 3ペイン（168px フィルタ ＋ リスト ＋ 300px 詳細） |
| `camera` | カメラ登録 | ドロップゾーン → 解析中 → 二ペイン候補確認 |
| `meals` | 献立提案 | 二ペイン（360px リスト ＋ 詳細） |
| `shopping` | 買い物リスト | 二ペイン（チェックリスト ＋ 340px 連携パネル） |
| `settings` | 設定 | 二ペイン（200px セクションナビ ＋ フォーム） |
| `help` | ヘルプ | スクロール読み物 |
| `onboarding` | 設定アシスタント | 二ペイン（220px ステップレール ＋ ステップ内容） |

**macOS UX ポイント（iOS/Androidとの差分）**
- ナビゲーション: 下部タブバー → **左サイドバー（⌘1–4）**
- アクション: FAB → **ツールバーボタン ＋ キーボードショートカット**
- ホバー: 行ホバーで編集・削除アイコン出現
- 選択: クリック → 右ペインに即時反映（ページ遷移なし）
- 在庫は **3ペイン**（カテゴリフィルタ ＋ 一覧 ＋ 詳細）
- 設定アシスタント: macOS Setup Assistant スタイル（緑グラデーションレール）
- 連携: **リマインダー（macOS）**、**iCloud**（iOS と同じ）

**macOS スクリーン実装推奨スタック**
```
SwiftUI + AppKit補完
├── NavigationSplitView (3カラム) — 在庫画面
├── NavigationSplitView (2カラム) — その他画面
├── NSToolbar — ツールバー ＋ キーボードショートカット
├── EventKit — リマインダー連携
└── CloudKit — iCloud 同期
```

---

## Notes for Developer

1. **APIキーの保管**: ユーザーが入力したAPIキーはキーチェーン（iOS）/ Android Keystore に保存してください。`shared.jsx` のプロトタイプでは `useState` ですが、本番は安全なストレージが必須です。
2. **FoodKeeperデータ**: 賞味期限の目安は USDA/FSIS の FoodKeeper データ（パブリックドメイン）をベースにしています。`catalog.data.gov` から最新データを取得してください。
3. **AI連携**: カメラ登録・献立提案ともに選択プロバイダのAPIを直接呼び出す設計です（サーバーサイド不要）。各社のVision APIを使用。
4. **外部リスト連携**: iOS = EventKit（Reminders）、Android = Google Tasks API。
5. **クラウド同期**: iOS = CloudKit、Android = Drive REST API / Room + WorkManager。
