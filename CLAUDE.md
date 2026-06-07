# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 応答言語

**ユーザーとのやり取りは常に日本語で行う。**

## プロジェクト概要

**つかいきり (Tsukaikiri)** — 冷蔵庫の在庫を起点に献立を AI が提案し、不足食材を買い物リスト（iOS=リマインダー / Android=Google ToDo）へ自動追加する Flutter アプリ。

設計の全詳細は [doc/献立アプリ_設計メモ.md](doc/献立アプリ_設計メモ.md) に記載。セッション開始時に必ず読むこと。仕様書・設計書も [doc/](doc/) 配下にある。

- アプリ ID: `com.futo4.tsukaikiri`
- Flutter パッケージ名: `tsukaikiri`
- 対象: iOS 26 + Android（Flutter 既定の最低 API レベル）
- iOS を優先して先に縦通しし、その後 Android 対応

## 開発の進め方

設計メモの段階的な順序に従う:

1. `flutter create tsukaikiri`（iOS + Android ターゲット）
2. 在庫管理の最小版（ローカル DB のみ。AI・買い物リスト連携なし）— **i18n の土台（flutter_localizations + ARB）もこの段階で入れる**
3. `ShoppingListService` 抽象で買い物リスト連携（iOS から）
4. AI プロバイダ抽象化レイヤー + 最初の1社（Gemini Flash 無料枠）
5. 追加プロバイダ（OpenAI 互換: Grok/OpenAI はまとめて、Claude/Gemini は個別）
6. 所有家電に応じた調理手順（Hotcook / Healsio）
7. カメラ登録（半自動）— AI レイヤー完成後
8. データ同期（`SyncService`: iOS=iCloud、Android=Google Drive App Data）
9. ヘルプ/このアプリについて（USDA FoodKeeper 出典表記）+ ドネーションリンク（Buy Me a Coffee）

## コマンド

Flutter プロジェクト作成後に使用:

```bash
flutter run                         # 接続済みデバイス/シミュレータで実行
flutter run -d <device-id>          # デバイス指定
flutter test                        # 全テスト
flutter test test/path/to_test.dart # 単一テストファイル
flutter analyze                     # 静的解析
flutter build ios --release         # iOS リリースビルド
flutter build apk --release         # Android リリースビルド
flutter gen-l10n                    # ARB からローカライズファイルを再生成
```

## アーキテクチャ

### 抽象レイヤー（OS ごとに実装を差し替える）

**`RecipeProvider`** — AI プロバイダ共通インターフェース  
メソッド: `suggestRecipes(inventory, constraints)` / `normalize(names)` / `recognizeIngredients(images)`  
実装: Claude（Anthropic Messages API REST）、Gemini（REST 直叩き）、OpenAI / Grok（OpenAI 互換 — エンドポイント URL とキーを差し替えるだけで同一クライアント流用）  
`RecipeConstraints` に `appliances`（所有家電）と `outputLocale`（出力言語）を持たせ、プロンプトに反映する。

**`ShoppingListService`** — 買い物リスト共通インターフェース  
メソッド: `getLists()` / `createList(name)` / `addItems(listId, items)`  
実装: iOS = EventKit（Swift platform channel）、Android = Google Tasks REST API（`google_sign_in` で `auth/tasks` スコープ取得）  
`UserSettings` には表示名でなく**識別子**（iOS=calendarIdentifier、Android=tasklist id）を保存する。

**`SyncService`** — クラウド同期共通インターフェース  
実装: iOS = iCloud Documents、Android = Google Drive App Data フォルダ（`drive.appdata` スコープ）  
当面は丸ごとバックアップ/復元で十分。差分同期は将来拡張。

### 重要な設計方針

- **レイアウト**: OS ではなく `LayoutBuilder`/`MediaQuery` の**画面幅**で分岐。スマホ（狭い）= 単一ペイン、タブレット/横向き（広い）= 二ペイン master-detail。
- **API キー**: `flutter_secure_storage`（iOS=Keychain / Android=Keystore）にプロバイダごとに保存。
- **AI レスポンス**: 必ず JSON 固定で返させる。前置き・コードフェンス禁止をプロンプトに明記。JSON フィールド名は言語固定、値（title・steps 等の自然文）だけを指定言語で生成。
- **カメラ登録**: 送信前に画像を縮小（長辺で圧縮）、1回最大10枚。AI 出力を直接在庫に書かず、**必ず確認画面を経由**する。
- **日持ち目安データ（`ShelfLifeRule`）**: USDA FoodKeeper データ + AI 補完の和食材をビルド時に同梱。実行時に API を呼ばない。
- **オフライン時**: 通信を試みて失敗したら「電波の良い場所か Wi-Fi に接続してください」と表示。事前判定でボタンを無効化しない。
- **ドネーション**: `url_launcher` で Buy Me a Coffee を外部リンクで開くだけ。IAP は使わない。全機能が無料（機能差なし）。
- **名寄せキー (`normalizedName`)**: 言語非依存。AI が付与。UI 表示言語が変わってもキーは変えない。

### データモデル

```
Ingredient      id, name, normalizedName, category, quantity, unit, expiryDate, updatedAt
Recipe          id, title, ingredients[], appliance, cookMode, cookMinutes, steps[], usesExpiringSoon, generatedBy
UserSettings    shoppingListId, shoppingListName, selectedProvider, locale, syncEnabled, lastSyncedAt, appliances[]
Appliance       type (hotcook|healsio), series, capacity, modelNumber
ShelfLifeRule   key, days, storage
```

## i18n

- ARB ファイル: `lib/l10n/app_ja.arb`、`lib/l10n/app_en.arb`
- ユーザーは設定画面で言語を上書き可能（`UserSettings.locale`: `ja` / `en` / `system`）
- AI 出力言語も `UserSettings.locale` に連動 — `RecipeConstraints.outputLocale` に乗せてプロンプトで指示する

## 外部準備（Claude Code の指示に従い、その都度対応）

- Google Cloud: Tasks API + Drive API の有効化、OAuth クライアント作成（Android は SHA-1 が必要）
- Gemini API キー: Google AI Studio で取得
- Apple Developer アカウント（年 $99）: 実機リマインダー連携テスト時に必要（シミュレータ開発は不要）
- Buy Me a Coffee URL: ドネーション画面を実装する段階で作成・差し込み
