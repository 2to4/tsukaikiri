# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Push Notification

When you complete a task, send me a push notification:

curl -X POST https://api.getmoshi.app/api/webhook \
  -H "Content-Type: application/json" \
  -d '{"token":"Z7UrrChlosrWOo0dGTh5UbqGqRiBfNHa","title":"Done","message":"Brief summary"}'


## 応答言語

**ユーザーとのやり取りは常に日本語で行う。**

## モデル使い分け方針

実装にあたってはトークンを節約するために**Opus/Sonnetを適切にサブエージェントとして切り出して実行**し、このメインセッション(Fable 5)は設計と監査、レビューに専念する。
実装難易度が特に高いところはこのセッションでやってよい。

## プロジェクト概要

**つかいきり (Tsukaikiri)** — 冷蔵庫の在庫を起点に献立を AI が提案し、不足食材を買い物リスト（macOS/iOS=リマインダー / Android=Google ToDo）へ自動追加する Flutter アプリ。

設計の全詳細は [doc/献立アプリ_設計メモ.md](doc/献立アプリ_設計メモ.md) に記載。セッション開始時に必ず読むこと。仕様書・設計書も [doc/](doc/) 配下にある。UI 実装時は [design_handoff/README.md](design_handoff/README.md)（デザイントークン・全画面のハイフィデリティ仕様）を参照する。

タスクの進捗と要検討事項は [doc/進捗管理.md](doc/進捗管理.md) で管理する。**作業の完了・着手・方針決定のたびに更新すること。**

- アプリ ID: `com.futo4.tsukaikiri` / Flutter パッケージ名: `tsukaikiri`
- 対象: macOS + iOS 26 + Android（Flutter 既定の最低 API レベル）
- **開発優先度: macOS → iOS → Android**（macOS で縦通しし、その後 iOS、Android の順）

## ロードマップと現状

設計メモの段階的な順序に従う。✅ = 実装済み:

1. ✅ Flutter プロジェクト作成（macOS + iOS + Android ターゲット）
2. ✅ 在庫管理の最小版（drift ローカル DB + i18n 土台）
3. ✅ `ShoppingListService` 抽象 + macOS リマインダー実装（`macos/Runner/RemindersPlugin.swift`）
4. ✅ `RecipeProvider` 抽象 + Gemini 実装（`GeminiProvider`、REST 直叩き）
5. ✅ 追加プロバイダ — 優先順位は **Gemini → Grok → OpenAI → Claude**。Grok/OpenAI は `OpenAiCompatibleProvider` を共有、Claude は Messages API。モデル名はハードコードせず `listModels()` で各社 API から取得し、ユーザー選択を `UserSettings.modelOverrides` に保存
6. 所有家電に応じた調理手順（Hotcook / Healsio）
7. カメラ登録（半自動）— AI レイヤー完成後
8. データ同期（`SyncService`: iOS=iCloud、Android=Google Drive App Data）
9. ヘルプ/このアプリについて（USDA FoodKeeper 出典表記）+ ドネーションリンク（Buy Me a Coffee）

UI 面では macOS デスクトップシェル（サイドバー+ツールバー）配下の全7画面（在庫3ペイン・カメラ登録・献立提案・買い物リスト・設定・オンボーディング・ヘルプ）が実装済み（M1〜M8、2026-06-11）。モバイル（狭い幅）は在庫・設定のみで、他画面のモバイル版と実 API/実機での動作確認が未了。

## コマンド

```bash
flutter run -d macos                  # macOS アプリとして実行（開発の基本）
flutter test                          # 全テスト
flutter test test/path/to_test.dart   # 単一テストファイル
flutter analyze                       # 静的解析
dart run build_runner build           # drift のコード生成（app_database.g.dart）
flutter gen-l10n                      # ARB からローカライズファイルを再生成
flutter build macos --release         # macOS リリースビルド
flutter build ios --release           # iOS リリースビルド
flutter build apk --release           # Android リリースビルド
```

`lib/core/db/app_database.dart` のテーブル定義を変更したら `dart run build_runner build` を必ず実行する。

## コード構成

feature-first 構成。状態管理・DI は Riverpod（`flutter_riverpod`）。

```
lib/
  main.dart                 # ProviderScope + MaterialApp（home は在庫画面）
  core/
    providers.dart          # アプリ全体の DI（DB・リポジトリ・サービスの Provider 定義）
    db/app_database.dart    # drift テーブル定義 + マイグレーション（.g.dart は生成物）
    theme/                  # design_handoff のトークンを反映した AppColors / buildAppTheme
    shelf_life/             # 日持ち目安（現状はカテゴリ別フォールバック日数のみ）
    secure_storage/         # API キー保存（flutter_secure_storage）
  features/<feature>/
    domain/                 # モデル・enum
    data/                   # リポジトリ（drift を包む）
    service/                # 抽象インターフェース + 実装（shopping, recipe）
    presentation/           # 画面・ウィジェット・画面用 Provider
  l10n/                     # app_ja.arb / app_en.arb（テンプレートは app_en.arb）
```

新しいサービス・リポジトリは `lib/core/providers.dart` に Provider を追加して配線する。

### 抽象レイヤー（OS / プロバイダごとに実装を差し替える）

**`RecipeProvider`**（`features/recipe/service/`） — AI プロバイダ共通インターフェース。
`suggestRecipes(inventory, constraints)` / `normalize(names)` / `recognizeIngredients(images)` / `listModels()` + `displayName` / `modelId` / `supportsVision`。
実装（全4社済み・REST 直叩き）: Gemini、Grok / OpenAI（`OpenAiCompatibleProvider` — URL とキーの差し替えで共有）、Claude（Anthropic Messages API）。
プロンプトと JSON パースは `recipe_prompts.dart` で全プロバイダ共有。エラーは共通の `RecipeProviderException`。タイムアウト60秒・自動リトライなし。
モデル名はハードコードせず `listModels()` で取得（実装内の既定値はフォールバックのみ）。生成は `createRecipeProvider()`（factory）経由、Riverpod では `recipeProviderProvider` が設定とキーを解決する。
API キーは呼び出し元が `SecureStorageService` から取得してコンストラクタに渡す。
`RecipeConstraints` に `appliances`（所有家電）と `outputLocale`（出力言語）を持たせ、プロンプトに反映する。

**`ShoppingListService`**（`features/shopping/service/`） — 買い物リスト共通インターフェース。
`getLists()` / `createList(name)` / `addItems(listId, items)`。
実装: macOS/iOS = `RemindersShoppingListService`（platform channel `com.futo4.tsukaikiri/reminders` ↔ `RemindersPlugin.swift`、EventKit）、Android = Google Tasks REST API（`google_sign_in` で `auth/tasks` スコープ取得）。
設定には表示名でなく**識別子**（macOS/iOS=calendarIdentifier、Android=tasklist id）を保存する。

**`SyncService`**（未実装） — クラウド同期共通インターフェース。
実装予定: macOS/iOS = iCloud Documents、Android = Google Drive App Data フォルダ（`drive.appdata` スコープ）。当面は丸ごとバックアップ/復元で十分。

### DB（drift）の規約

- `Ingredients` の主キーは UUID 文字列（将来のクラウド同期での競合回避のため）。
- 設定は `SettingsTable` の単一レコード（id=0 固定）。所有家電は `appliancesJson` に JSON 配列で保存。
- カテゴリ・単位など言語非依存のキーは**列挙子名の文字列**で保存する（表示名は l10n で引く）。
- スキーマ変更時は `schemaVersion` をインクリメントし、`MigrationStrategy.onUpgrade` に `from < N` の分岐を追加する。

### テスト

リポジトリ層のテストは `AppDatabase(NativeDatabase.memory())` でインメモリ DB を作る（`test/inventory_repository_test.dart` 参照）。platform channel やネットワークに依存しないロジック（expiry_status、shelf_life 等）は純粋関数として切り出してテストする。

widget テストで drift の stream を購読する画面は、テスト本体の末尾で `pumpWidget(SizedBox.shrink())` → `pump()` でアンマウントしてタイマーを消化する（pending timer エラー回避。`test/inventory_list_screen_test.dart` の `unmountApp` 参照）。

コントローラ等の非 UI コードから在庫・設定を読むときは、StreamProvider の `.future`（リスナー不在だと永遠に解決しない）や drift stream の `.first`（FakeAsync の widget テスト下で pump しても進まない）を使わず、リポジトリの一発クエリ（`InventoryRepository.getInventory()` / `SettingsRepository.get()`）を使う。また widget テストが1件失敗すると drift の後始末が fake クロック上で完了せず、そのテストは 10 分のウォッチドッグ満了までハングする（スイートが固まって見えたら、まず失敗テストを疑う）。

### 重要な設計方針

- **レイアウト**: OS ではなく `LayoutBuilder`/`MediaQuery` の**画面幅**で分岐。スマホ（狭い）= 単一ペイン、タブレット/横向き（広い）= 二ペイン master-detail。
- **API キー**: `flutter_secure_storage`（macOS/iOS=Keychain / Android=Keystore）にプロバイダごとに保存。DB には入れない。
- **AI レスポンス**: 必ず JSON 固定で返させる。前置き・コードフェンス禁止をプロンプトに明記。JSON フィールド名は言語固定、値（title・steps 等の自然文）だけを指定言語で生成。
- **カメラ登録**: 送信前に画像を縮小（長辺で圧縮）、1回最大10枚。AI 出力を直接在庫に書かず、**必ず確認画面を経由**する。
- **日持ち目安データ（`ShelfLifeRule`）**: 最終的には USDA FoodKeeper データ + AI 補完の和食材をビルド時に同梱。実行時に API を呼ばない。現状はカテゴリ別日数のみで、参照は `defaultExpiryFrom` に集約済み（後で JSON 同梱データに差し替える）。
- **名寄せキー (`normalizedName`)**: 言語非依存。AI が付与。UI 表示言語が変わってもキーは変えない。AI 連携前は name を流用し、後でバックフィルする。
- **オフライン時**: 通信を試みて失敗したら「電波の良い場所か Wi-Fi に接続してください」と表示。事前判定でボタンを無効化しない。
- **ドネーション**: `url_launcher` で Buy Me a Coffee を外部リンクで開くだけ。IAP は使わない。全機能が無料（機能差なし）。

## i18n

- ARB ファイル: `lib/l10n/app_ja.arb`、`lib/l10n/app_en.arb`（テンプレートは英語側）。`pubspec.yaml` の `generate: true` により生成されるが、手動再生成は `flutter gen-l10n`。
- ユーザーは設定画面で言語を上書き可能（`localePref`: `ja` / `en` / `system`、`LocaleController` が適用）。
- AI 出力言語も設定に連動 — `RecipeConstraints.outputLocale` に乗せてプロンプトで指示する。

## 外部準備（Claude Code の指示に従い、その都度対応）

- Google Cloud: Tasks API + Drive API の有効化、OAuth クライアント作成（Android は SHA-1 が必要）
- Gemini API キー: Google AI Studio で取得
- Apple Developer アカウント（年 $99）: 実機リマインダー連携テスト時に必要（シミュレータ開発は不要）
- Buy Me a Coffee URL: ドネーション画面を実装する段階で作成・差し込み
