# 日持ち目安データ（ShelfLifeRule）生成パイプライン

冷蔵庫の食材名から賞味期限の初期値を提案するための「目安日数」データを
ビルド時に生成し、アプリに同梱する仕組み。実行時に外部 API は呼ばない。

すべての値は **あくまで目安** であり、ユーザーが手動修正する前提。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `foodkeeper_ingredients.csv` | 入力①: FoodKeeper ミラー CSV（出典は下記） |
| `ja_mapping.json` | 入力②: 日本語マッピング + 和食材補完（人手レビュー対象） |
| `shelf_life_compute.dart` | 生成の純ロジック（CSV パース・Metric 換算・行照合）。テスト対象 |
| `generate.dart` | CLI 本体。`assets/shelf_life/shelf_life_rules.json` を生成 |

出力: `../../assets/shelf_life/shelf_life_rules.json`（`pubspec.yaml` で同梱）。

## 出典・ライセンス

- 元データ: **USDA FoodKeeper（2019-06 版）**。
- 取得経路（ミラー）: `https://raw.githubusercontent.com/jelera/food-shelflife-db/master/lib/seeds/ingredients.csv`
- 取得日: **2026-06-11**
- ライセンス: **CC0**（FoodKeeper は米国政府著作物。ミラーも CC0）

> 公式配布元（fsis.usda.gov の JSON/XLS）は本開発環境から Akamai により 403 で
> ブロックされ自動取得できなかったため、CC0 ミラーの CSV を固定値として
> コミットしている。FoodKeeper は更新頻度が低く、本アプリの用途（目安表示）
> では 2019 年版で実用上問題ないと判断した。

## 生成方法

```bash
dart run tool/shelf_life/generate.dart
```

- 冪等。同じ入力に対しては常に同じ出力（再実行で `git diff` なし）。
- 出力は `normalizedKey` 昇順・2 スペースインデント・末尾改行で安定化。

### 生成ロジックの要点

- 冷蔵日数 = `Refrigerate Min/Max` の中央値 `round((min+max)/2)`。
  - Metric 換算: `Days=1` / `Weeks=7` / `Months=30` / `Years=365`（下限 1 日）。
  - 数値化できない Metric（`Package use-by date` / `When Ripe` /
    `Indefinitely` / `Not Recommended` 等）はその源をスキップ。
- 保存源の優先順: `Refrigerate` → `DOP_Refrigerate`（購入日起算）→
  `Pantry` → `DOP_Pantry`。最初に数値化できたものを採用。
- **日本語エイリアスを持つ項目のみ出力**（全 663 行は出さない）。
- どの源も数値化できない FoodKeeper 項目は警告を出してスキップ
  （アプリ側はカテゴリ別フォールバック日数で代替する）。

## 公式最新データへの差し替え手順

FoodKeeper の公式最新版に更新したくなったとき（急ぎではない）:

1. ブラウザで [Data.gov の FSIS FoodKeeper Data](https://catalog.data.gov/dataset/fsis-foodkeeper-data)
   を開く（または fsis.usda.gov 内で「FoodKeeper Data」を検索）。
2. **English の JSON または XLS** をダウンロードする（ES/PT 版は不要）。
3. ダウンロードしたファイルを本ディレクトリ（`tool/shelf_life/`）に置く。
4. 公式 JSON/XLS を本パイプラインの CSV スキーマ（`foodkeeper_ingredients.csv`
   と同じ列名: `Name` / `Name_subtitle` / `Refrigerate_Min/Max/Metric` /
   `DOP_Refrigerate_*` / `Pantry_*` / `DOP_Pantry_*` …）に整形して
   `foodkeeper_ingredients.csv` を上書きする。
5. `ja_mapping.json` の `foodkeeper` 各エントリの `match`（`Name` +
   `Name_subtitle` 部分一致）が新データでも 1 行に解決するか確認する
   （`generate.dart` は解決できない項目に warning を出す）。
6. 再生成して差分を確認:

   ```bash
   dart run tool/shelf_life/generate.dart
   flutter test test/shelf_life_table_test.dart test/shelf_life_generate_test.dart
   ```

Claude Code に「公式データに差し替えて再生成して」と伝えれば、整形・再生成・
テストまで対応する。

## ja_mapping.json の編集

- `foodkeeper`: FoodKeeper の 1 行を `match.name`(+`match.subtitle`) で特定し、
  日本語エイリアス・`normalizedKey`（言語非依存キー）・`category`
  （`IngredientCategory` の列挙子名文字列）を与える。
- `supplement`: FoodKeeper に無い和食材。`days`（冷蔵保存の保守的な目安）を直接指定。
- `_note` 等の `_` 始まりのキーは根拠メモ用で、生成側は無視する。
