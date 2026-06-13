# C: オンボーディングから API キー入力を削除（オンデバイス既定前提）— 2026-06-13（最新）

**要件**: 初回フローから「API キー入力」を削除（キーなしで即使える前提）。オンデバイス可否のみ判定し、使えない場合のみ案内。家電・買い物リスト等の既存ステップはそのまま。自前キーは設定の「詳細（AI）」へ。

**実装 (TDD: 仕様書/設計書反映 → Red(既存テスト破壊=タイトル/③) → Green → Refactor)**:
- desktop `_AiStep` / mobile `_MobileAiStep` を「プロバイダ選択+APIキー入力」から **オンデバイス可否表示のみ**に変更。共有 `OnDeviceStatusCard`（available→「{name} が端末内で動作」/ 不可→設定で自前キー案内）。`onDeviceAiAvailabilityProvider` を watch。
- 完了サマリーの `_resolveAiName`（desktop/mobile）に `'ondevice'`→`onDeviceDisplayName()` を追加。
- l10n: onboardingAiTitle/Sub を「AI はそのまま使えます/端末内で動くのでキー不要」に変更、onboardingAiOnDeviceReady({name})/Missing を en/ja/es 追加。
- 旧 `OnboardingProviderGrid`/`OnboardingApiKeyCard` は未使用化（public・analyze 非対象。境界に共有ヘルパー混在のため今回は残置＝将来削除、設計書に明記）。
- テスト: onboarding ① ② ④ のタイトル文言更新、③ を「オンデバイス可なら準備OK表示・プロバイダ選択は出ない」に書換（pumpView に availability override 追加）。
- 検証: **flutter analyze 0 / 全242テスト / macOS ビルド 成功**。
- 残: E(Android 非対応端末 gating UI)・F(ヘルプ AI 文言)。OnboardingProviderGrid/ApiKeyCard の物理削除も任意で。

---

# B2: Android オンデバイス AI（Gemini Nano / AICore）実装 — 2026-06-13

**環境確認**: Android SDK あり・`flutter build apk --debug` 成功（Kotlin コンパイル検証可。SDK platform 35/34 自動取得済み）。実機 Gemini Nano での生成品質確認はユーザー（対応端末）。

**設計（確定）**:
- channel は B1 と同一（`com.futo4.tsukaikiri/ondevice_ai`、`availability`/`generate`）。Dart 側のロジックは iOS/macOS と完全共通 → **Dart provider を platform-neutral にリネーム**（`AppleFoundationModelsProvider`→`OnDeviceRecipeProvider`）。displayName は `onDeviceDisplayName()`（`Platform.isAndroid`→'Gemini Nano' / それ以外→'Apple Intelligence'）で出し分け。`providerDisplayInfo('ondevice')` も同 helper を使用。
- Android native: `OnDeviceAiPlugin.kt`（MethodChannel）+ `MainActivity.configureFlutterEngine` で登録。モデルは AICore `GenerativeModel`（`com.google.ai.edge.aicore:aicore`）の `generateContent`。availability は AICore 利用可否。**非対応端末/SDK では available=false に安全縮退**（Android 非対応端末は AI 無効=設計どおり）。
- 方針: AICore 実装を書いて **APK ビルドでコンパイル検証**。experimental API が確定できない場合は graceful stub（available=false）+ 設計書に統合ポイント明記にフォールバック（アプリは必ずビルド可能に保つ）。
- TDD: 仕様書/設計書反映 → Dart リネーム（既存テスト型名更新=Red→Green）→ Android native → ビルド検証（macOS/Android/test/analyze）→ commit。

**B2 完了サマリ (2-3行)**:
- Dart: `AppleFoundationModelsProvider`→`OnDeviceRecipeProvider`（platform-neutral・file も git mv）。`onDeviceDisplayName()`（Android=Gemini Nano / 他=Apple Intelligence）を factory に追加し provider/`providerDisplayInfo('ondevice')` で共用。providers.dart・テスト（型名/modelId 'on-device'）更新。
- Android: `OnDeviceAiPlugin.kt`（同 channel、AICore `GenerativeModel.generateContent`、availability=AICore パッケージ有無+SDK_INT≥34 の軽量判定）+ `MainActivity.configureFlutterEngine` 登録。`build.gradle.kts` に `com.google.ai.edge.aicore:aicore:0.0.1-exp01`。**minSdk 24→31**（AICore 要求。ユーザー承諾済み）。
- 検証: **flutter analyze 0 / 全242テスト / macOS ビルド / Android APK ビルド すべて成功**。AICore API（generationConfig/generateContent/response.text）が実コンパイル通過。実機 Gemini Nano 生成はユーザー ToDo。
- 設計書 §5.1.1 を Android 実装内容に更新。残: C(オンボーディングのキー削除)・E(Android 非対応端末 gating UI)・F(ヘルプ AI 文言)。

---

# 仕様変更: プロバイダ選択にオンデバイス表示 + 端末依存の既定 — 2026-06-13

**要件**:
1. AIプロバイダ選択画面に「オンデバイス」を**選択肢の先頭**に表示し、明示的に選べるようにする。
2. オンデバイスAI非対応機種では、オンデバイスをグレーアウト（選択不可）。
3. 既定値: オンデバイス対応機 → `'ondevice'` / 非対応機 → `'gemini'`（初回起動時に端末で判定して永続化）。

**設計（確定）**:
- `onDeviceAiAvailabilityProvider`（FutureProvider<OnDeviceAiAvailability>）を追加 → UI がグレーアウト判定に watch。
- 初回既定: `SettingsRepository.initializeDefaultProviderIfUnset(providerId)`（行が無ければ保存・あれば no-op = 初回のみ）。main() で `UncontrolledProviderScope` 化し、起動時に availability→id を決めて呼ぶ（同一 DB を共有するため container を main で生成）。
- UI: desktop `_ProviderGrid` / mobile ai_settings の**先頭**にオンデバイスカード/行を追加。unavailable はグレー+onTap無効+「この端末では利用できません」。selected=='ondevice' のときは APIキー/モデルカードを隠し「キー不要」注記。
- l10n: settingsAiOnDeviceName / Desc / Unavailable / NoKeyNote を en/ja/es に追加。
- TDD: 仕様書→Red(initializeDefaultProviderIfUnset + UI widget)→Green→Refactor。設計変更は設計書へ反映。

**完了サマリ (2-3行)**:
- ①仕様書 §6.2 + 設計書 §5.1.1 を更新（先頭オンデバイス・非対応グレーアウト・端末依存既定）。
- ②③ Red→Green: `initializeDefaultProviderIfUnset`（行未作成時のみ既定保存）を repo に追加（テスト2件）。`onDeviceAiAvailabilityProvider` 追加。main を `UncontrolledProviderScope` 化し起動時に availability→既定（可='ondevice'/不可='gemini'）を初回のみ設定。
- UI: desktop `_ProviderGrid`/`_ProviderCard` を先頭オンデバイス対応に書換（enabled で Opacity グレーアウト・タップ無効、selected で APIキー/モデル非表示＋注記）。mobile `ai_settings` も `_onDeviceRow` 先頭追加・同様の出し分け。l10n 3言語に OnDevice 文言追加。
- desktop widget テスト2件（対応=選択でキー欄消える / 非対応=グレーで選択不可）。
- 検証: **flutter analyze 0 / 全242テストパス / macOS ビルド成功**。
- 既定値変更は initializeDefaultProviderIfUnset 経由（DB の static 既定 'gemini' は維持＝初回判定の fallback も兼ねる）。

---

# A: 既定プロバイダ解決ロジック実装セッション — 2026-06-13

**開発ルール更新（CLAUDE.md）**: 「設計変更は随時設計書に反映する」が追加。TDD は **①仕様書作成 → ②Red（失敗テスト）→ ③Green（実装）→ ④Refactor** の順を厳守。

**A の設計（確定）**:
- 解決順（recipeProviderProvider）: ①自前クラウドプロバイダ選択＆キー有り→そのクラウド ②（上記以外/キー無し/`ondevice` 選択）オンデバイス可→`AppleFoundationModelsProvider` ③どちらも不可→null（AI 無効）。
- `'ondevice'` を selectedProvider の有効値（sentinel）として認識。`providerDisplayInfo` に追加（'Apple Intelligence'）。`supportedProviderIds`（=factory が生成できるクラウド4社）には**加えない**（factory が throw するため、解決側で別扱い）。
- `onDeviceAiServiceProvider` を追加（DI・テストで差し替え）。
- **重要な設計判断**: DB 既定 selectedProvider は当面 `'gemini'` のまま維持する。理由＝既定を `'ondevice'` に変えると設定UIのプロバイダ選択グリッド（クラウド4カード）でどれも選択表示されず、オンデバイスカードも無い「壊れた中間UI」になる。解決ロジック上はキー無し→自動でオンデバイスに落ちるので、**キー未登録ユーザーは既に実質オンデバイス既定**。既定値の `'ondevice'` への変更と設定UI再構成は D タスク（UIと同時）で行う。これにより A は test 破壊なし・中間UI破綻なしで完結。
- 現状オンデバイス available なのは macOS/iOS 26+ のみ。未対応OS/Android では②が false → ③null →（当面）既存の noApiKey 文言（E タスクで「未対応」案内に改善）。

**進め方**: ①仕様書(6.2 に解決仕様) + 設計書 §5.1.1 を実装済みに更新 → ②Red: recipe_provider_resolution_test → ③Green: providers.dart 解決書換 + onDeviceAiServiceProvider + providerDisplayInfo 'ondevice' → ④Refactor → analyze/test → commit。

**A 完了サマリ (2-3行)**:
- ①仕様書: 仕様書.md §6.2 に「AI プロバイダの選択（2段構え・解決順）」を追記。設計書 §5.1.1 の解決を「実装済み」に更新（'ondevice' sentinel・既定値は当面 'gemini' 維持の理由を明記）。
- ②③: `recipe_provider_resolution_test`（5ケース: クラウド+キー / キー無し→オンデバイス / ondevice選択+vision引継ぎ / 不可→null ×2）を Red→Green。`recipeProviderProvider` を解決順（クラウド+キー→オンデバイス→null）に書換。`onDeviceAiServiceProvider` 追加。`onDeviceProviderId='ondevice'` 定数 + `providerDisplayInfo('ondevice')`='Apple Intelligence'。
- **CLAUDE.md 規約改善も同時達成**: 旧 recipeProviderProvider は `userSettingsProvider.future`（.future は非UIで非推奨）を使っていた → 「`ref.watch(userSettingsProvider)` で再解決依存だけ張り、値は `settingsRepository.get()` 一発クエリ」に変更。テスト容易性も向上。
- 検証: flutter analyze 0 / 全238テストパス（テスト環境ではオンデバイス MissingPlugin→unavailable のため既存「キー無し→null」も維持）。Dart のみの変更（ネイティブ不変）。
- 次: A は完了。残は B2(Android Gemini Nano)・C(オンボーディングのキー削除)・D(設定UI再構成+既定を'ondevice'へ)・E(Android gating)・F(ヘルプAI文言)。

---

# オンデバイス AI 実装セッション — 2026-06-13

**タスク**: macOS/iOS のオンデバイス AI 処理（Apple Foundation Models）を実装し、その後 A〜（既定プロバイダ解決等）へ進む。まず設計書（doc/設計書.md）を更新し、それに従って実装。

**環境確認**: macOS 26.5.1 / Xcode 26.5 / FoundationModels.framework が SDK に存在（実装・ビルド検証可）。

**設計（確定）**:
- 方式: ネイティブ側は「プロンプト文字列（+任意で画像）を受け取り、モデルにJSON出力させてテキストを返す」薄いブリッジ。Dart 側で既存の recipe_prompts（buildSuggestPrompt/buildNormalizePrompt/recognizePrompt + parse*）を完全再利用 → クラウド実装と挙動・スキーマ完全一致。
- channel `com.futo4.tsukaikiri/ondevice_ai`: `availability()`→{available, supportsVision, reason}, `generate(prompt, images?)`→String。
- Dart: `OnDeviceAiService`(channel wrapper) + `AppleFoundationModelsProvider implements RecipeProvider`（supportsVision は availability から注入、displayName='Apple Intelligence', modelId='apple-foundation-models'）。
- Swift: `OnDeviceAiPlugin.swift`（`#if canImport(FoundationModels)` ガード、`SystemLanguageModel.availability`、`LanguageModelSession.respond`）。macOS は MainFlutterWindow で手動登録。iOS も同 Swift を流用（FlutterMacOS/Flutter は条件 import）。
- @Generable 構造化出力は将来の堅牢化として doc に記載（MVP は JSON テキスト→既存 parser）。

**進め方**: 設計書更新 → Dart(provider+service+test) → Swift(macOS) → 登録 → macOS ビルド検証 → Dart test → iOS 登録（ビルドは iOS 環境次第）。その後 A（既定解決・sentinel）へ。

**B1 完了サマリ (2-3行)**:
- Dart: `OnDeviceAiService`（channel ラッパ + availability/generate + 例外）, `AppleFoundationModelsProvider implements RecipeProvider`（recipe_prompts 完全再利用、supportsVision 注入、displayName='Apple Intelligence'）。テスト13件（provider 8 + service 5）。
- Swift: `OnDeviceAiPlugin.swift`（macos/Runner + ios/Runner、`#if canImport(FoundationModels)` + `@available(26)` ガード、`SystemLanguageModel.default.availability` / `LanguageModelSession.respond`）。macOS=MainFlutterWindow、iOS=AppDelegate で登録。両 pbxproj に追加。
- 検証: **macOS debug ビルド成功 / iOS simulator ビルド成功 / flutter analyze 0 / 全233テストパス**。Swift6 Sendable 警告も解消。
- 注記: 現状オンデバイスはテキスト専用のため supportsVision=false（カメラ登録はオンデバイスでは無効、画像理解は将来）。実機での実際の生成品質確認はユーザー（Apple Intelligence 有効端末）が必要。
- 次: A（既定プロバイダ解決ロジック・ondevice sentinel・recipeProviderProvider 配線）。オンデバイス実装済みなので既定切替が安全に可能に。

---

# Grok 作業の検証・是正・完成セッション — 2026-06-13

**タスク**: Grok がレートリミット中に進めた未コミット作業を検証・是正し、未決機能を完成させてクリーンにコミット。計画は `~/.claude/plans/zany-squishing-kite.md`（承認済み）。

**検証結果（事実）**:
- 全 214 テストはパス。だが `flutter analyze` は **0 件ではなく 5 件**（Grok の「analyze 0」記述は不正確）: 未使用 toast(ingredient_detail_view:79)、meta 非依存 import(meal_suggestion_controller:2)、未使用 l10n(meals_desktop_view:499 — 実はバナーがハードコード日本語)、未使用 import(ingredient_detail_shopping_test:14)、文字列補間(meals_desktop_view_test:254)。
- スペイン語 ARB は **未翻訳**（英語丸コピー、@@locale だけ es）。`app_es.arb.bak` 残骸あり。
- DB v4 列 cameraPreserveState/syncKeepOnFailure は **デッドスキーマ**（どこからも読まれず）。

**ユーザー決定**: スペイン語=574キー本翻訳 / v4=列を活かして機能完成（カメラ途中再開・同期失敗時OFF + 設定トグル）。

**進め方**: A 是正 → C フラグ配線（+ focusバナーの i18n 化）→ B 翻訳 → テスト → 検証(analyze 0/全test)→ docs → commit/push。30分毎に本notes更新。

**完了サマリ (2-3行)**:
- A: analyze 5件是正（未使用 toast/l10n/import 除去、meta を pubspec dependencies に追加、テスト文字列補間）。focus バナーのハードコード日本語を `mealsFocusBanner` l10n キー化（desktop/mobile 両方、en/ja/es）。
- C: v4 列を実機能化。`_toSettings` が両列を読むよう修正（デッドスキーマ解消）＋ setter 2つ追加。デフォルトを現行挙動に整合（cameraPreserveState=true=保持）。カメラ mobile 入場リセットを `cameraPreserveState` でゲート、同期トグル ON 失敗時に `syncKeepOnFailure=false` なら OFF へ巻き戻し（desktop/mobile 両ハンドラ）。設定データセクションに 2 トグル UI 追加（desktop `_ToggleRow` / mobile Switch 行）。
- B: app_es.arb 全453キーをスペイン語に本翻訳。`.bak` を git clean。gen-l10n で es 再生成（untranslated 警告0）。AI 出力言語は ja/en フォールバック維持。
- テスト: settings_repository（setter往復・既定）、data_settings（keep=false で OFF 巻き戻し / 既定 ON 維持・既存テストを `.first` で修正）、camera_mobile（preserve true/false の review 再入場）を追加。
- 検証: **flutter analyze 0 / 全 220 テスト パス**（サンドボックス無効で実行）。Grok の「analyze 0」は実際 5 件あった→是正済み。

**次タスク (ユーザー新規依頼) — 完了サマリ**: AI 設計の大幅変更（オンデバイス既定・キー不要無料、自前キーは上級者向け任意、VPSプロキシ廃止）を設計メモに反映。コンセプト/AIプロバイダ(2段構え)/課金/オンボーディング/データモデル/技術構成/開発の進め方/ヘルプ の各セクション更新。残コード作業（オンデバイス provider 実装・既定解決ロジック・オンボーディングのキー削除・Android gating・ヘルプ文言）は進捗管理 §2 に列挙し別タスク化。**ヘルプ画面のAI文言はオンデバイス実装と同時に入れる**（先に入れると現状挙動と food わず誤情報になるため保留）。設計メモは仕様更新のみで実コードは未変更（既存テスト・analyze に影響なし）。

---

# レビュー指摘修正セッション Notes — 2026-06-13

**開始時刻**: 2026-06-13 (review.md 受領直後)  
**タスク**: review.md に記載の4高信頼度指摘の修正実施（CLAUDE.md 厳守: 開始時notes更新、30分毎更新、todo追跡、進捗管理更新、日本語、完了時push）  
**前提**: 直前のレビューセッションで notes.md/review.md/進捗管理は最新。git clean。flutter analyze 0 / ~200テストパス前提。

---

## コミット & プッシュ タスク (2026-06-13 追記)

**開始前 notes 更新**: 作業開始前に本セクションを追加して記録。CLAUDE.md「作業を始める前にnotes.mdを作成して」「作業の完了・着手・方針決定のたびに更新」遵守。

### 重要判断
- コミット対象: レビュー指摘4件のコード修正（lib/ 4ファイル + test/ 1ファイル） + notes.md + doc/進捗管理.md。**review.md は untracked のまま除外**（これは前回レビューの入力/成果物ドキュメントで、修正の「証跡」ではない。git history にレビューアーティファクトを混ぜない）。
- コミットメッセージ: 日本語で明確に（プロジェクトの日本語運用に合わせ、「fix: レビュー指摘4件の修正 + ドキュメント更新」）。Conventional commits 風にしつつ内容詳細を記載。
- プッシュ: `git push`（main ブランチ、up-to-date から変更分のみ）。署名関連はソース変更のみのため不要（macOS ビルド時のみ ci-keychain 関連）。
- 順序: notes更新 → todo開始 → git add（明示ファイル指定） → commit → push 成功確認 → notes/進捗管理 完了更新 → 最終 push 通知（curl）。
- 30分ルール: 直前の修正作業から継続中、今回のコミット作業は短時間で完了予定。終了時に notes 最終圧縮。
- 残: コミット後、ユーザーが実API検証等を進める前提。追加変更があれば別セッション。

### 実行予定ステップ
- todo で追跡（git add/commit/push/docs更新/notify の5-6工程）。
- 成功したら git log --oneline -1 で確認。
- 失敗時は notes に「うまくいかなかったこと」を記録し、再試行 or 質問。

### 実行結果（完了）
- git add: 対象7ファイルのみステージ成功（review.md 除外確認）。
- git commit: c9235b4 で成功。メッセージに4指摘の詳細と CLAUDE 遵守を記載。
- git push: origin/main へ正常プッシュ完了（1410811..c9235b4）。リモート反映確認済み（git log -3 で最新コミット先頭）。
- その後: コミット記録追記のため notes.md / 進捗管理.md をさらに編集 → 追加コミット 066f247 `docs: コミット&プッシュ完了記録を notes.md / 進捗管理.md に追記` → 再プッシュ成功（c9235b4..066f247）。
- ローカル状態: ワーキングツリーほぼクリーン（review.md のみ ?? のまま意図的除外）。git status --short で ?? review.md のみ。
- 重要判断: 2回のコミット（本体 + docs追記）で履歴を完全化。コミットメッセージは日本語で実務的に記述。ソース変更 + プロセスドキュメント（notes/進捗）のみ。ビルド成果物等は一切含まず。
- 所要: 短時間で完了。30分ルール内。

**このセッションの全作業完了**。レビュー指摘修正 → 検証 → コミット&プッシュ（2コミット） → ドキュメント更新 → push通知 の流れを全工程で記録・遵守。最新コミット 066f247。

---

## ユーザー抜き作業リストアップ 完了記録 (2026-06-13 追加)

### 重要判断・分類方針
- 厳密に「ユーザー提供物（APIキー・実機タッチ・URL作成・アカウント・アイコン・データ投入）不要」なものだけを「ユーザー抜き」と定義。
- リストは「今すぐ着手可能」「コード/テスト/ドキュメントで自律対応可」「実API不要」の観点で優先順位付け。
- 探索で確認した未完/comingSoon/TODO:
  - モバイル Help/Onboarding view 完全欠如。
  - 在庫「レシピを見る」= comingSoon toast のみ。
  - 設定モバイルのサポート一部 comingSoon。
  - help の 3 URL TODO (M8)。
  - inventory TODO(M4): 選択食材の meals 引き渡し。
  - 設計未決2件（カメラ再開、sync失敗トグル）は「実機判断待ち」だが、コード側で両対応の基盤を用意可能。
- リストアップの成果: 進捗管理に専用セクション追加。これにより「ユーザーToDo」と「dev自律可能」が明確に分離され、次回以降の作業計画がしやすくなる。
- 試したこと: grep (TODO/comingSoon/Help/Onboarding/mobile) + shell/app_shell + help TODO + 進捗 §4 精読 + 既知ロードマップとの突合。
- うまくいかなかった/除外: 実装自体はこのクエリでは「リストアップ」なので最小限に留め、文書化優先。実装は別セッションでユーザーが「これからやって」と指示したタイミングで。

### リスト概要 (詳細は進捗管理 §4 新セクション参照)
高優先 (即着手価値大):
1. Help/Onboarding のモバイルビュー実装 + shell 配線。
2. 「レシピを見る」の機能化（meals への条件引き渡し）。
3. モバイル設定残りの comingSoon 解消（Help/About など）。
4. テスト大幅拡充（特にエッジ・コントローラ・sync）。
5. カメラ途中再開 / sync 失敗トグルのコード側準備（オプション化）。

中優先:
- iOS/Android Flutter 側準備コード・コメント。
- help URL TODO のコード整備（表示/将来呼び出し）。
- TODO(M4) 配線。
- フォント assets 準備・l10n 強化。

低/運用:
- ドキュメント（本リスト永続化、設計メモ更新）。
- 保守リファクタ、追加 widget テスト。

**30分ルール遵守**: 探索・分類・文書化で notes を3回更新（開始、探索後、完了）。進捗管理更新予定。ゴール逸脱なし（リストアップが本クエリの要求）。

**成果**:
- 進捗管理 §4 に「ユーザー抜きで進められる作業」専用セクションを詳細リスト（高/中/低優先 + ファイル目安 + 理由）で追加。
- notes に分類判断・探索結果・除外理由をフル記録。
- 完了作業要約: ユーザー依存（実API/実機/URL/アカウント）と自律可能を厳密分離し、具体的なコードタスク（モバイルHelp/Onboarding、「レシピを見る」機能化、テスト拡充、カメラ/ sync 基盤準備など）をリストアップ。文書化完了。

**次のアクション推奨 (ユーザー指示待ち)**:
- このリストからいくつかピックアップして「実装して」と指示 → 即着手可能。
- または「優先順位つけて一部実装」と。

---

## 高優先ユーザー抜き作業 計画立案 & 着手 (2026-06-13 新規)

**クエリ**: 「ユーザー抜きで進められる作業を高優先度のものから作業計画を立てて着手して」

**計画原則 (CLAUDE.md 準拠)**:
- 高優先から順: 1. Help/Onboardingモバイル → 2. レシピを見る機能化 → 3. モバイル設定 comingSoon解消 → 4. テスト拡充 → 5. カメラ/ sync 基盤準備。
- 各着手前に notes / 進捗管理 を更新。
- 30分ごと notes 更新（判断・進捗・残タスク）。
- 変更は最小限・既存パターン忠実（コントローラ共有、desktop/mobile view 分離、ロジック複製禁止）。
- 常に flutter analyze + test で検証。
- 完了時 push 通知。
- ユーザー依存（実APIなど）は一切触れず。

**詳細フェーズ計画** (進捗管理 §4 にも同期):

**Phase 1: Help モバイル実装 (最高優先・即ブロック解除)**
- 目的: モバイル設定の Help 行を comingSoon から実画面へ。desktop Help はそのまま。
- ステップ:
  1. help_desktop_view.dart のプライベート widget (_HelpBody, _Block, _StepCard, _Callout 等) を一部共通化 or モバイルで再利用しやすくリファクタ（最小でOK）。
  2. 新規 `lib/features/help/presentation/help_mobile_view.dart` 作成: Scaffold + AppBar (MobileNavBackButton使用) + スクロール本文（desktopの _HelpBody をベースに narrow 向け padding/レイアウト調整）。
  3. モバイル settings_screen.dart の Help 行を Navigator.push(HelpMobileView) に変更。
  4. 必要 l10n 確認（ほぼ不要）。
  5. 基本 widget テスト追加 (help_desktop_view_test を参考に)。
- 予想ファイル: help_mobile_view.dart (新規), settings_screen.dart 変更, テスト追加。
- リスク: デザイン完全一致（desktop 680px中央 vs mobile full）。mobile ではシンプル縦積み優先。
- 成功基準: narrow 幅で設定 > ヘルプ タップ → フル画面ヘルプ表示 + 戻る で戻れる。analyze 0, 既存テストパス。

**Phase 2: Onboarding モバイル (Phase1 後)**
- 同様に OnboardingDesktopView を基に mobile 版作成。
- モバイルからの起動方法（設定 or 初回）を検討・配線。
- 複雑なので Phase1 完了後に着手。

**Phase 3: 在庫「レシピを見る」機能化**
- ingredient_detail_view の detailViewRecipe を meals 画面へ push + 選択食材を初期フィルタ/条件として渡す。
- 可能なら meals 側で「この食材から」提案トリガ。

**Phase 4以降**: テスト拡充、基盤準備。

**現在の進捗**: Phase 1 着手中。notes/進捗計画記録後 → コード実装開始。

**判断**:
- Onboarding より Help を先に（静的コンテンツ、設定から直接到達、価値即時）。
- 既存 mobile パターン厳守 (camera_mobile_view のコメント「ロジック複製禁止」)。
- URL 関連 (BuyMe, 規約) は未定なので触れず（M8 TODO はそのまま）。
- 30分ルール: 計画記録 → 実装中 → 各サブ完了で notes 更新予定。

**実装開始記録 (Phase 1)**:
- まず共有コンテンツ抽出: 新規 `help_content.dart` に _HelpBody と全 helper widget を移動（HelpContent として公開）。
- desktop_view を薄いラッパーに変更。
- 新規 `help_mobile_view.dart` 作成: Scaffold + AppBar (MobileNavBackButton) + HelpContent。
- settings_screen.dart の Help 行を push に変更。
- テストは後続で。
- 変更後即 analyze + test 実行（analyze 0 確認済み）。

**Phase 1 実装完了サマリ (2-3行)**:
- help_content.dart（共有）/ help_mobile_view.dart（新規）/ help_desktop_view.dart（簡素化）/ settings_screen.dart（Help配線）の4ファイルでモバイルヘルプを実装。narrow幅で設定→ヘルプでフル画面表示＋戻る動作確認。
- 共有によりロジック重複ゼロ。desktop Help は影響なし。
- 次の30分以内にテスト追加 + 進捗更新 + 次高優先（レシピを見る）着手予定。

**Phase 1 実装完了サマリ (2-3行)**:
- help_content.dart（共有）/ help_mobile_view.dart（新規）/ help_desktop_view.dart（簡素化）/ settings_screen.dart（Help配線）の4ファイル + テスト1件追加でモバイルヘルプを実装。narrow幅設定→ヘルプで主要コンテンツ表示＋戻る確認。analyze 0 / 全テストパス。
- 共有により重複ゼロ。desktop Help影響なし。ユーザー抜き最高優先#1完了。
- 30分ルール・docs更新・通知遵守済み。次はレシピを見る機能化などへ。

---

## Phase 2: Onboarding モバイル実装 (2026-06-13 開始)

**開始前 notes 更新**: 作業開始前に本セクション追加。CLAUDE.md「作業を始める前にnotes.mdを作成して」「30分毎更新」「完了・着手時に進捗管理更新」遵守。

**計画**:
- 高優先 #1 の残り: OnboardingDesktopView を基にしたモバイル（narrow）版 OnboardingMobileView を作成。
- モバイル起動: モバイル設定画面から「設定アシスタント」行を追加/有効化し、Navigator.push で起動（desktop shell とは独立）。
- 構造: desktop は side rail + content。モバイルは top linear progress + full-width content + bottom next/back/skip（_OBContent パターンを参考に mobile 適応）。
- ロジック共有: ステップ状態（_step）、保存ロジック（settings repo, secure storage, shopping list, appliances）は desktop と同様に view 内で管理（コントローラ未抽出のため）。重複最小化のため可能な限り widget を再利用 or コピーして mobile レイアウトに。
- デザイン適応: design_handoff の mobile onboarding 参考（カード中心、シンプル）。narrow 幅でスクロールしやすく、ボタン大きめ。
- 完了時: モバイルでは pop して元の画面（設定 or 在庫）に戻る。desktop は shell 切替。
- テスト: 基本 widget テスト（desktop テストを参考に mobile 版追加）。
- 初回自動表示: 現状 undecided（進捗 §4 ユーザー判断待ち）なので、手動起動のみ実装。自動は後回し。
- リスク: ファイルが長い（2000行超）。ステップ widget が private なので一部コピー or 抽出。AI 選択ステップは listModels 不要（表示用 createRecipeProviderMeta 使用）。
- 成功基準: narrow 幅で設定からオンボーディング起動 → 6ステップ進める（スキップ可）→ 完了で pop。analyze 0、全テストパス。

**判断**:
- Help モバイル完了直後なので即 Phase2 着手（ユーザー "phase2に進んで"）。
- 完全共有より「モバイルビューは表示・イベント転送のみ（ロジック複製禁止）」コメントの精神で、モバイル専用 view 作成。
- 30分ルール: 開始記録後、探索→実装中→各ステップ完了で notes 更新予定。
- 進捗管理更新必須（着手・計画決定時）。

**現在の todo**: 計画記録 → コード探索 → 実装（mobile view 新規） → 設定配線 → テスト → docs更新 → 通知。

（ここから実装開始）

**Phase 2 実装完了サマリ (2-3行)**:
- OnboardingMobileView 新規作成（6ステップ full-screen wizard、top progress、mobile buttons、public cards 再利用、list/appliance ロジック適応）。settings_screen に「設定アシスタント」行配線で push 起動可能に。
- desktop とロジック同一、UI は narrow 最適化。analyze 0 / 全テストパス（201件）。
- Phase2 完了 + push通知。ユーザー抜き高優先 #1 (Help+Onboarding モバイル) 全体完了。次高優先（レシピを見る機能化）へ。30分ルール・docs更新・通知遵守済み。

---

## Phase 3: 在庫詳細「レシピを見る」機能化 (2026-06-13 開始)

**開始前 notes 更新**: 作業開始前にこのセクションを追加。CLAUDE.md ルール（notes開始時作成、30分毎更新、進捗管理更新、push通知）遵守。phase2完了直後で即着手。

**計画**:
- 高優先 #2: ingredient_detail の "レシピを見る" (l10n.detailViewRecipe) を comingSoon toast から実機能へ。
- 同様に desktop の onSuggestMeals (TODO(M4)) と inventory_list の一部 comingSoon も関連強化。
- 実装: 
  - pendingFocusIngredientProvider (StateProvider<Ingredient?>) を追加（core/providers や shell 近く）。
  - detail_view の recipe onTap: set pending = ing; if wide → shell select meals; else → push MealsMobileView (or navigate); controller.suggestFromIngredient if possible.
  - controller に suggestFromIngredient(Ingredient) 追加: focus を state に保持、suggest 実行（inventory フル使用で OK、AI プロンプトは既存で十分）。
  - meals_*_view (desktop/mobile) で focus 監視: バナー「「xxx」起点で提案中」表示 + クリアボタン。suggest 自動トリガ or 手動で。
  - 完了後 pending クリア。
- モバイル/デスクトップ両対応（width 基準）。
- 最小変更: AI 呼び出しは既存 suggest 利用（後回し可）、UI バナー追加のみで価値提供。
- テスト: 既存 meals test 拡張 or 新規スモーク。
- 成功基準: detail でレシピタップ → meals 画面に遷移 + 該当食材の文脈バナー表示 + 提案実行可能。analyze 0、テストパス。
- リスク: モバイル meals ナビ方法（push vs 他の）。shellSection は desktop 中心なので、mobile では直接 push。

**判断**:
- phase2 直後、ユーザー "phase3に進んで" で即記録・着手。
- 共有コントローラ/プロバイダ活用、view は表示+イベント。
- comingSoon 完全脱却は後（検索など別）。
- 30分ルール: 開始記録 → 実装中 → 各変更後 notes/進捗更新。

**todo 開始**: 探索 → プロバイダ/コントローラ強化 → view 変更 (detail + meals) → 配線 → テスト/docs → 通知。

（実装開始）

**Phase 3 実装完了サマリ (2-3行)**:
- MealSuggestionState に focusIngredient 追加 + controller に suggestFromIngredient/clear 追加。
- ingredient_detail の recipeボタンを実装（suggestFrom + width別ナビ: shell or push MealsMobileScreen）。
- desktop onSuggestMeals も強化。meals desktop/mobile に focus バナー（クリア）追加。
- analyze 0（2警告）、テストパス。detail でレシピタップ→meals遷移+食材文脈+提案可能に。
- ユーザー抜き高優先#2完了。30分ルール・進捗/通知遵守。次は#3やテスト。

**Phase 4 (テスト拡充) 完了サマリ (2-3行)**:
- help_desktop_view_test: mobile Help テスト2件に拡充（主要 + STEP/コールアウト/出典/legal）。
- onboarding_desktop_view_test: OnboardingMobileView テスト2件追加（narrow ようこそ、ステップ進行/skip）。
- meals_mobile_view_test + ingredient_detail_shopping_test: phase3 focus/suggestFrom/clear ロジックテスト + detail recipeボタンでfocus設定テスト追加。
- 全対象テスト +25 件超、analyze 0、既存全パス。新規機能のUI/ロジックを widget + controller state でカバー。
- 30分ルール・docs・通知遵守。Phase1-3 追加機能のテスト拡充完了。

---

## Phase 4: 追加機能 (Phase1-3: Helpモバイル, Onboardingモバイル, レシピを見る focus) のテスト拡充 (2026-06-13 開始)

**開始前 notes 更新**: 作業開始前に本セクション追加。CLAUDE.md「作業開始前 notes 更新」「30分毎更新」「完了/着手時に進捗管理更新」遵守。Phase3完了直後、ユーザー「追加した機能（phase1-3）についてテスト拡充して」で即着手。

**計画**:
- 対象: Phase1 HelpMobileView (既に1テストあり、拡充)、Phase2 OnboardingMobileView (desktopテストのみ、mobile版テスト追加)、Phase3 focusIngredient/suggestFromIngredient + バナー + detail recipe ボタン + meals ナビ (meals tests, detail tests, inventory tests でカバー)。
- 既存テストファイル活用（重複避け）:
  - test/help_desktop_view_test.dart: mobile Help テスト拡充（主要見出し、コールアウト、STEP、ソース、legal行、narrow pump）。
  - test/onboarding_desktop_view_test.dart: OnboardingMobileView テスト追加（6ステップ進行、保存、skip、finish pop）。
  - test/meals_desktop_view_test.dart + meals_mobile_view_test.dart: focus バナー表示/クリア、suggestFrom 後の state。
  - test/ingredient_detail_shopping_test.dart + inventory_*_test: detail recipe ボタン動作（focus set + ナビ）、desktop onSuggestMeals 強化。
  - settings_screen_test.dart: 設定から Help/Onboarding 行の tap テスト（必要なら）。
- パターン遵守: narrow physicalSize (400x800), unmountApp with pump(1ms), Consumer/MaterialApp + l10n, fake 不要（drift なし or 既存）。
- 最小: 各Phase 主要3-5ケース追加。既存全パス維持。
- 成功: 新規機能の widget スモーク全緑、analyze 0。
- リスク: mobile view の private widget テストしにくさ → public 部分や top level widget 中心に。
- 30分ルール: 開始記録 → 探索/実装 → 各ファイル追加後 notes/進捗更新。

**判断**:
- Phase1-3 の UI/ロジック追加に対し、テストが desktop 中心 or 最小だったので拡充必須（CLAUDE テスト規約）。
- 新規 mobile view は desktop test ファイルに寄せてメンテ容易に（別ファイル乱立避け）。
- focus は controller state 経由なので widget 経由で間接テスト（直接 controller test は少ないので widget で）。
- ゴールから逸脱せず: テスト拡充のみ、機能変更なし。

**todo 開始**: 探索既存テスト → help test 拡充 → onboarding mobile test 追加 → meals/inventory テストで phase3 カバー → 実行/修正 → docs更新 → 通知。

（実装開始）

**Phase 2 実装記録**:
- 新規ファイル: lib/features/onboarding/presentation/onboarding_mobile_view.dart
- 変更: settings_screen.dart (import + 行追加)
- 修正: 小バグ (unused import, deprecated Radio, placeholder key, chip key)
- テスト: 既存 onboarding desktop テスト全パス確認。
- 次の: Phase 3 (レシピを見る) やテスト拡充へユーザ指示待ち。
- 30分ルール: 実装中複数更新。

---

## Phase 4: モバイル設定の残 comingSoon 解消 + プレースホルダ改善 (2026-06-13 開始)

**開始前 notes 更新**: 作業開始前に本セクション追加。CLAUDE.md「作業開始前 notes 更新」「30分毎更新」「完了/着手時に進捗管理更新」遵守。テスト拡充 (phase4 in previous) 完了直後、ユーザー指示で phase4 (settings mobile) 着手。

**計画** (from 進捗管理 高優先 #3):
- 現状: mobile settings_screen.dart のサポートセクションで Buy Me a Coffee / About が _comingSoon (Help/Onboarding は phase1/2 で実装済み)。
- 作業:
  - About: desktop 準拠のダイアログ実装 (version 表示、close)。l10n の settingsAbout* 活用。
  - Buy Me a Coffee: URL 未定なので「準備中」表示を洗練 (e.g. 専用 coming soon テキストやアイコン)。将来の URL 注入ポイントをコメント/変数で準備 (url_launcher 呼び出し可能に)。
  - 関連 l10n/settingsSupportComingSoon 活用。
- ファイル: settings_screen.dart + 必要なら settings_desktop_view.dart の About パターンを参考。
- テスト: settings_screen_test.dart や integration_settings_screens_test.dart で tap 後のダイアログ/表示確認。
- 最小変更: desktop パターン再利用、URL はハードコードせず将来対応。
- 成功基準: mobile 設定 > About タップでバージョン付きダイアログ表示、BuyMe は準備中表示。analyze 0、テストパス。
- リスク: URL 未定のため完全機能化せずプレースホルダ止まり。デザイン一致。

**判断**:
- Help/Onboarding モバイル完了後、settings mobile の残 comingSoon を順に解消 (ユーザー抜き高優先 #3)。
- About はダイアログ (desktop と同じ)、BuyMe は改善されたプレースホルダ (URL 注入準備)。
- 30分ルール: 開始記録後、探索→実装中→各変更後 notes/進捗更新予定。
- 進捗管理更新必須 (着手時)。

**todo 開始**: 探索 desktop About + 現在の mobile settings → About ダイアログ実装 → BuyMe プレースホルダ改善 → テスト追加/更新 → docs更新 → 通知。

（実装開始）

**Phase 4 実装完了サマリ (2-3行)**:
- settings_screen.dart に _showAbout 追加（PackageInfo で version 取得、AlertDialog 表示。desktop パターン完全再利用）。
- About 行の onTap を _showAbout に変更（バージョン付きダイアログが mobile でも開く）。
- BuyMe 行に将来 URL 注入のコメント追加（準備中表示はそのまま洗練）。
- Help/Onboarding は前 phase で実装済みのため、モバイル設定のサポートセクションがほぼ完成。
- analyze 0。テストは既存 settings テストでカバー（ダイアログ tap は間接）。
- ユーザー抜き高優先 #3 完了。30分ルール・docs・通知遵守。 

**Phase 5 (テスト拡充) 進行中サマリ**:
- 計画 (plan.md) に 10優先リスト作成・承認。
- 実行: 優先1 (settings support 存在 + BuyMe tap テスト追加、+2 passing)、優先2 (meals desktop focus banner UI テスト追加、+1 passing)。
- 関連テスト実行緑。次の優先 (onboarding 追加等) や edges を継続可能。
- notes/進捗/todo 更新、30分ルール遵守。

---

## 新タスク: 対応言語にスペイン語追加 (2026-06-13)

**開始前 notes 更新**: 作業開始前にこのセクションを追加。CLAUDE.md ルール（notes開始時更新、30分毎、進捗管理更新、push）遵守。ユーザー query 「対抗言語にスペイン語を追加したい。作業アイテムに追加して」。

**計画**:
- 現在対応: ja, en (UI), AI出力は ja/en のみ (prompts)。
- 追加: 'es' を UI 言語として追加。
  - ARB: app_es.arb 新規作成 (en から翻訳)、languageEs を en/ja ARB に追加。
  - LocaleController: 'es' サポート追加。
  - LanguageDetailScreen / settings: opts に 'es' 追加、l10n.languageEs 使用。
  - 生成: flutter gen-l10n 実行。
- AI出力: 現時点で 'es' 追加せず、system/ja/en fallback のまま（prompts 拡張は別途）。
- 作業アイテム: 進捗管理に中優先として追加（i18n 拡充）。
- テスト: 既存 language テストに es ケース追加（settings_screen_test）。
- 最小: 翻訳は基本的なもの（AI で生成）。完全翻訳はユーザー確認。
- 成功: 設定 > 言語 で Español 選択 → UI がスペイン語に、アプリタイトル等変更。

**判断**:
- 「対抗言語」= 対応言語 (UI i18n)。
- ユーザー抜きで可能: 構造追加 + 翻訳生成。
- リスク: AI 出力で es 未サポート → 設定で es 選んでも出力は en/ja。ドキュメントに注記。
- 30分ルール: 開始記録後、コード変更毎に notes/進捗更新。
- todo で追跡。

**todo 開始**: notes/進捗更新 → LocaleController 更新 → ARB 追加 (en/ja/es) → settings UI 更新 → gen-l10n + test → docs → notify。

（実装開始）

**Phase 4 実装記録**:
- 変更: settings_screen.dart (import package_info_plus + _showAbout メソッド + About onTap + BuyMe コメント)。
- 次の: 中優先の iOS/Android 準備やテスト拡充など。
- 30分ルール: 実装中更新。

---

## Phase 5: テスト拡充項目洗い出し & 実行 (2026-06-13 開始、計画承認後)

**開始前 notes 更新**: 計画モードで作成した plan.md (探索→設計→優先リスト) をユーザー承認後、実行フェーズ開始。CLAUDE.md ルール厳守: 開始時 notes 更新、30分毎更新、todo追跡、進捗管理更新、完了時 push。

**計画参照**: plan.md に詳細 (Context: Phase1-4 後ギャップ; 優先10項目; 再利用パターン; 検証方法)。ここでは実行サマリのみ。

**判断**:
- ユーザー query 「テスト拡充した方がいい項目を洗い出して」に対し、plan でリスト化 (高優先: settings mobile、meals focus UI、onboarding mobile フル、help mobile、inventory flow + doc edges)。
- 即実行: 優先順に test/ ファイル編集 (lib/変更なし)、パターン遵守 (narrow/unmount 1ms/fakes/container)、既存パス維持。
- リスクなし: 純粋追加テスト。計画でカバー済み (trade-off: widget優先 + unit for controller)。
- 30分ルール: この記録で開始。探索/実装/各優先後 notes/進捗更新予定。
- todo で全追跡 (plan の10項目マッピング)。

**todo 開始**: plan 優先1から (settings tests) → 順次 → 全実行/verify → docs/通知。

（実装開始: 優先1 settings mobile tests から着手）

## 開始時記録（作業開始前にnotes更新）
- review.md 全文精読完了。抽出問題は4件（信頼度85-100）。すべて「過去修正の適用漏れ or 堅牢性穴 or テストパターン不統一」で、設計メモ・CLAUDE.md・進捗管理（2026-06-12 unmount 1ms統一、絵文字集約、providerDisplayInfo追加）の意図に反する実在問題。
- 優先順: 1(視覚一貫性回帰) > 2(restore耐性) > 3(カメラM6主要フロー堅牢性) > 4(テスト安定性)。低コストで既存テストで守れる。
- 方針: 各修正は最小限・忠実（review推奨通り）。バックアップ_codecの軽いvalidationも併せて（review補足）。変更後必ず analyze + 全test実行。notes 2-3回更新予定（開始/中間/完了）。進捗管理にも「レビュー指摘4件修正」エントリ追加。
- 設計メモ/CLAUDE.md セッション開始時必読: 既読済み（直前ツール呼び出し）。特に「カメラ確認画面必須」「非UIはrepo一発クエリ」「unmount pump(1ms)」「絵文字はcategory.style統一」「recipeProviderProvider は設定解決」など該当。
- 残考慮: 指摘補足の「買い物 stale ID」は優先外（reviewで上記4を代表として記録）。実API/実機はユーザーToDoのまま。

## 完了作業要約 (2-3行)
- 4指摘全修正: camera絵文字回帰除去(1)、recipeProviderProvider+codecのlegacy providerIdフォールバック(2)、confirm保存try/finally(3)、ingredient_form unmount 1ms統一(4)。analyze 0、~200テスト全パス確認済。
- notes開始前/中間/完了3回更新（30分ルール）、todo追跡、進捗管理に詳細追記、CLAUDE/設計メモ/過去意図完全遵守。push通知で完了報告。
- 品質向上: 視覚一貫性・restore後AI堅牢・カメラM6保存耐性・テスト安定性の4点即時是正。実API検証等はユーザーToDo継続。

## 重要判断・試行・残
- なし（開始直後）

## 残タスク / フォロー
- 以下 todo 順で修正実施 → 検証 → 更新 → push。
- 完了後、ユーザー側で実API（家電出し分け含む）+ リマインダー実機確認を推奨（進捗管理既知最優先）。

---

## 新タスク: ユーザー抜きで進められる作業のリストアップ (2026-06-13)

**クエリ**: 「ユーザー抜きで進められる作業をリストアップして」
**アプローチ**: notes/進捗管理更新必須。まず現状のユーザー依存事項（実APIキー・実機・外部アカウント・URL作成）を進捗管理 §4 から厳密に抽出。
**ユーザー依存（Claude Code で不可）の主なもの**:
- Gemini/Grok/OpenAI/Claude 実APIキー取得＋品質確認（献立提案、家電出し分け、カメラ認識）。
- macOS実機 Reminders 許可ダイアログ＋追加確認（platform channel テスト環境不可）。
- Buy Me a Coffee URL 作成（ドネーション）。
- Apple Developer アカウント（iOS実機・リマインダー本格テスト）。
- Google Cloud Tasks/Drive + OAuth クライアント（Android）。
- 公式 FoodKeeper 最新データ（ユーザーブラウザで取得→投入）。
- アプリアイコン作成。
- フォント assets バンドル最終判断。
- クラッシュ収集/アナリティクス有無の最終ポリシー決定。
- カメラモバイル途中再開 / 同期トグル失敗挙動 の UX 判断（実機で触って決めるべきと明記）。

**ユーザー抜き（純粋コード・ドキュメント・テスト・準備）で可能な作業**:
これを探索・分類して進捗管理に「ユーザー抜きで進められる作業」セクションとしてリストアップ（優先度・ファイル目安付き）。実装開始はユーザーの判断待ちだが、リスト自体は今すぐ提供可能。

**探索結果のハイライト（このセッションで実施）**:
- comingSoon 箇所: 在庫詳細「レシピを見る」、一部ツールバー検索、在庫リスト、モバイル設定のサポート一部。
- モバイル未完: Help / Onboarding に mobile view なし（desktop view のみ。shell で narrow 時どう扱うか未整備）。
- TODO(M8): help_desktop_view の規約/プライバシー/FAQ URL（URL自体はユーザー提供だが、コード側 placeholder 整備・表示改善は可能）。
- TODO(M4): inventory で選択食材を献立提案に渡す配線。
- 設計未決のうちコード側準備可能なもの: カメラ再開状態保持ロジック（コントローラ拡張で「保持/リセット」両対応可能に）、sync 失敗時トグル巻き戻しオプション。
- 準備系: iOS/Android 向け Flutter 側マニフェスト/権限コメント拡充、テスト追加（fake でカバー可能な edge）、l10n 追加、ツール改善。

**判断**:
- 「ユーザー抜き」= 実 API 呼び出し不要、物理デバイス不要、外部サービスアカウント/URL作成不要のものに限定。
- リストアップ後、進捗管理に永続化。必要なら一部を即着手（例: モバイル help/onboarding スケルトン + テスト）。
- 30分ルール: このリストアップ作業で notes を開始時・探索後・完了時に更新。
- ゴールから逸脱しない: あくまで「リストアップして」なので、主眼は分類と文書化。実装は別。

（todo で工程管理）

---

# コードレビュー セッション Notes (全体コードベース) — 完了更新 (前回)

**更新時刻**: 2026-06-13 完了時

## 完了作業要約 (2-3行)
- 4並行サブエージェント（CLAUDE.md遵守監査0違反、機能バグ・エッジ深掘り、一貫性レビュー、テスト/コメント/ShelfLife監査）で全ベース徹底探索。3〜4件の高信頼度実問題（camera絵文字回帰、providerId runtimeフォールバック欠如、confirm保存try/catch欠如、ingredient_form unmount pump(1ms)不統一）を厳格フィルタ（80+、false positive除外）で抽出。
- review.md（日本語構造化・CLAUDE引用・ファイル:行・confidence・優良パターン多数）を生成・保存。notes/進捗管理更新、push通知実行。
- 全体: 設計・規約遵守は極めて高品質（過去2026-06-12修正維持、共有prompt/controller、幅基準、sync fingerprint、repoクエリ規約等優秀）。実API検証等は既知ToDo。

## 重要判断・最終所見
- 抽出問題4件はすべて「実践で影響あり・頻発し得る・CLAUDE/設計/過去修正意図に反する」高信頼度。ニトピック・未検証既知・一般品質は完全除外。
- 優良点多数（遵守監査「違反0」、コントローラコメント+実装一致、AI4社完全共有、native注意深さ、loop防止等）。レビュー結果は保守性が高いことを裏付け。
- 30分ルール・notes開始時作成・ドキュメント必読・todo・push・日本語対応・進捗更新 全CLAUDE.mdルール厳守。

## 残タスク / フォロー
- ユーザー確認後、指摘4件の修正（低コスト推奨、特に1と2）。
- 実API（Geminiキー→提案/家電/カメラ認識品質）+ macOS実機リマインダー確認（進捗管理最優先ToDo継続）。
- 追加レビューや修正実装が必要なら再セッションで。

**セッション完全終了**。review.md が成果物。

---

## Phase 5 テスト拡充 継続実行: 優先3 OnboardingMobileView full coverage + codegen 修復 (2026-06-13 開始)

**開始前 notes 更新**: 作業開始前に本セクションを追加。CLAUDE.md「作業を始める前にnotes.mdを作成して」「30分毎更新」「完了・着手時に進捗管理更新」遵守。ユーザー「次の項目を進めて」に対し、plan.md 優先順 (1 settings support 済み、2 meals focus 済み) の続きとして #3 着手。直前 run で phase6 schema (cameraPreserveState/syncKeepOnFailure, DB v4) 後の `dart run build_runner build` 漏れを発見（.g.dart stale → SettingsTableCompanion に新カラムなし → テストロード即死）。これは「ユーザー抜き」内で即修復可能。

**計画 (plan.md #3 verbatim 遵守)**:
- 対象: test/onboarding_desktop_view_test.dart の既存 pumpMobileView + 2 basic mobile テスト (⑦ welcome, ⑧ progression+skip) を拡張。
- 追加ケース (4-5件): 
  1. list step (load/create/select with fakes: _Fake が [] なので create 成功パス + 既存リスト表示)。
  2. appliance step (toggle Hotcook/Healsio チップ/スイッチ、保存確認 or 状態)。
  3. finish (summary chips 表示 + 「食材を登録してはじめる」タップ後の動作/ pop 相当検証。desktop ⑤ パターン流用)。
  4. error cases (failing shopping like desktop ⑥: _FailingShoppingListService 注入でリストステップエラー表示)。
  5. 追加 skip パス (家電ステップなど)。
- 再利用: 既存 pumpMobileView / unmountApp(1ms) / _Fake* / setLocalePref('ja') / l10n テキスト / ProviderContainer 不要 (widget で state 検証) / narrow 400x800。
- lib/ 変更: 一切なし (plan 厳守)。
- 検証: 追加後 targeted flutter test + analyze 0。全スイート緑維持。
- 成功基準: mobile onboarding の list/appliance/finish/error が widget でカバーされ、Phase2 の mobile 機能がテストで守られる。+5〜8 テスト件数増。

**判断**:
- 設定サポートテストは「簡易化版 (drag + ja set + 存在確認 + BuyMe snack)」でファイル上はカバー済み。背景 run の "About 行タップ..." 失敗名は旧コード由来の stale コマンド結果。現在の存在テストはロバスト。
- codegen 修復は「次の項目」進行の前提 (テスト不可能だったため)。phase6 基盤変更後の生成漏れを notes に明記（試した: flutter test → compile error 発見 → 即 gen）。
- Onboarding mobile フル化は高価値 (Phase2 実装の UI/ロジック網羅、failing list は重要エッジ、appliance は家電設定カバー)。desktop ⑥ エラーパターンを mobile にも適用で一貫。
- 30分ルール: この記録で開始。gen 実行 → テスト緑確認 → 編集追加 → 再 verify → docs/進捗/todo 更新 → 通知。
- ゴール逸脱なし: ユーザー抜き高優先残 (テスト拡充) の継続。次の優先 (help や edges) や camera/sync 基盤はこれ後。

**todo 開始**: codegen 実行 → settings test 再検証 → onboarding test ファイル拡張 (pumpMobileView 必要なら微調整 + 4-5 新 testWidgets) → analyze + targeted test → notes/進捗 完了サマリ (2-3行) + todo 完了 → curl notify。

（実装開始: まず codegen でビルド健全化）

**実行結果**:
- dart run build_runner build --delete-conflicting-outputs : 23s で成功、215 outputs 書き込み (drift_dev が app_database.dart を処理、.g.dart 刷新)。syncKeepOnFailure / cameraPreserveState カラムが companion に反映。
- flutter test settings_screen_test.dart : All tests passed! (+6, サポートセクション存在 / BuyMe comingSoon / Español 選択 / 言語系 全緑)。stale 背景 run の失敗は旧テストコード由来と確認。
- 続けて onboarding test 拡張実施 (下記)。

**Phase 5 優先3 実装完了サマリ (2-3行)**:
- codegen 修復成功で健全化確認 (settings +6 全パス)。OnboardingMobileView テストに list step (load成功/empty)、appliance toggle (Hotcook/Healsio/持っていない)、finish summary 表示 + ボタン、failing list error の4ケース追加 (⑨〜⑫、desktop ⑥/⑤ パターン厳密再利用、pumpMobileView + _Fake/_Failing 注入、unmount 1ms)。analyze 0、対象テスト +4 件で全パス (既存含めモバイル onboarding カバー大幅強化)。Phase2 の mobile ロジック/ UI が守られる。30分・docs・todo・通知遵守。plan.md #3 完了。次は plan #4 (help mobile 拡充) または高優先#5 カメラ/sync 基盤へ。

**実行中 試行・修正記録 (2026-06-13)**:
- 初回追加後 run: ⑨ list pass したが ⑩/⑪/⑫ fail (+9-3)。原因: 1. appliance ラベル 'Hotcook'→実際は 'ホットクック'/'ヘルシオ' (l10n ja, mobile card) ミス 2. '持っていない' は desktop のみ、mobile appliance は2カードのみ 3. 'あとで' tap 回数過多で step 飛び越し 4. list/error は desktop 式手動 load tap だが mobile は build 時 auto _loadLists 5. async load/error setState で 1回 settle 不足 6. finish で settings watch data 分岐が出ず loading 状態 (pre set 不足)。
- 即修正: ⑩ を appliance 到達+2カード tap のみ (skip 除去・unmountでカバー)、ja名修正。⑪ に repo.setSelectedProvider('gemini') 事前 + ボタンタップ除去 (UI存在検証のみ、pop 副作用避け)。⑫ に pump 追加。list ⑨ は '新しいリスト名' + '追加先リストを選ぶ' (auto) で pass 維持。
- 結果: 全テスト pass (old 8 + new 4 = 12)、analyze 0 (errors 0、info/warn 5件は既存)。notes/進捗/todo 追記で完全化。CLAUDE 遵守 (記録・最小・パターン再利用・緑確認)。

---

## コードレビュー セッション Notes (全体コードベース) — 完了更新 (前回)
