import 'dart:convert';

import '../../../core/db/app_database.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';

/// 全 AI プロバイダで共有するプロンプトとレスポンスのパース処理。
///
/// プロンプト・JSON スキーマをプロバイダ間で完全に一致させることで、
/// プロバイダを切り替えても挙動が変わらないようにする。

/// 献立提案プロンプト。
/// [now] はテストで日付を固定するためのフック（既定は現在時刻）。
String buildSuggestPrompt(
  List<Ingredient> inventory,
  RecipeConstraints constraints, {
  DateTime? now,
}) {
  final lang = switch (constraints.outputLocale) {
        'ja' => '日本語',
        'es' => 'Español',
        _ => 'English',
      };
  final base = now ?? DateTime.now();
  final inventoryLines = inventory.map((i) {
    final daysLeft = i.expiryDate?.difference(base).inDays;
    final expiryNote = daysLeft != null
        ? (daysLeft <= 2 ? '【期限間近$daysLeft日】' : '（あと$daysLeft日）')
        : '';
    return '- ${i.name} ${i.quantity}${i.unit}$expiryNote';
  }).join('\n');

  final applianceLines = constraints.appliances.isEmpty
      ? '（なし）'
      : constraints.appliances
            .map((a) => a.capacity != null
                ? '- ${a.type.name}（容量 ${a.capacity}）'
                : '- ${a.type.name}')
            .join('\n');

  // 家電あり時の調理手順指示（ハルシネーション対策）。
  final applianceInstructions = constraints.appliances.isEmpty
      ? ''
      : '\n・所有家電での調理が向く料理には、その家電を使う手順を steps に含めること（汎用的な調理モード名と加熱時間を明記する）。向かない料理は通常の鍋・フライパン手順でよい（無理に家電を使わない）。機種固有の自動メニュー名・メニュー番号は出力しないこと。';

  // 条件チップ → プロンプトの自然文表現（言語非依存の指示文。出力言語とは独立）。
  final kindLine = switch (constraints.mealKind) {
    MealKind.auto => '・献立の種類は問いません（主菜・副菜どちらでも可）。',
    MealKind.mainOnly => '・主菜（メインのおかず）のみを提案してください。',
    MealKind.oneMore => '・もう一品ほしいときの軽い副菜・汁物を中心に提案してください。',
    MealKind.quick => '・調理時間が短い（目安15分以内）時短レシピを優先してください。',
  };

  // 在庫が少ないときは買い足し前提の提案を許可する。
  final stockLine = constraints.allowNewIngredients
      ? '・在庫が少ないため、在庫にない食材を買い足す前提の献立も提案して構いません。'
      : '・できるだけ在庫にある食材だけで作れる献立を優先してください。';

  final extra = constraints.extraRequest != null
      ? '\n・追加条件: ${constraints.extraRequest}'
      : '';

  return '''
以下の在庫と条件で献立を${constraints.count}案提案してください。
期限間近の食材を優先して使ってください。

【条件】
$kindLine
$stockLine$applianceInstructions$extra

【在庫】
$inventoryLines

【所有家電】
$applianceLines

返答は以下のJSON形式のみ。前置き・コードフェンス・説明文は一切禁止。
フィールド名は変えず、自然文（title・steps等）は$langで生成すること。
appliance は所有家電に合わせて "hotcook" / "healsio" / null（通常調理）のいずれかにすること。

{"recipes":[{"title":"","ingredients":[{"name":"","amount":""}],"appliance":null,"cookMode":null,"cookMinutes":null,"steps":[""],"usesExpiringSoon":false}]}
''';
}

/// 名寄せプロンプト。
String buildNormalizePrompt(List<String> names) {
  return '''
以下の食材名リストについて、表記ゆれを吸収した言語非依存の正規化キー（英小文字・アンダースコア区切り）を付与してください。
例: "鶏むね" → "chicken_breast", "鶏胸肉" → "chicken_breast"

返答はJSON形式のみ。前置き禁止。
{"normalized":{"<元の名前>":"<キー>", ...}}

食材リスト:
${names.map((n) => '- $n').join('\n')}
''';
}

/// カメラ登録（食材検出）プロンプト。
const String recognizePrompt = '''
冷蔵庫内の画像から食材を検出してください。
返答はJSON形式のみ。前置き禁止。
{"ingredients":[{"name":"","estimatedQuantity":1,"unit":"個","confidence":0.9}]}
''';

/// AI 応答から JSON オブジェクト部分を取り出す。
/// プロンプトで JSON のみを指示しているが、モデルがコードフェンスや
/// 前置きを付けた場合に備えて最初の '{' から最後の '}' までを抽出する。
String extractJson(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw FormatException('AI 応答に JSON が含まれていません', raw);
  }
  return raw.substring(start, end + 1);
}

List<SuggestedRecipe> parseSuggestResponse(String raw) {
  final data = jsonDecode(extractJson(raw)) as Map<String, dynamic>;
  return (data['recipes'] as List)
      .map((e) => SuggestedRecipe.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, String> parseNormalizeResponse(String raw) {
  final data = jsonDecode(extractJson(raw)) as Map<String, dynamic>;
  return Map<String, String>.from(data['normalized'] as Map);
}

List<DetectedIngredient> parseRecognizeResponse(String raw) {
  final data = jsonDecode(extractJson(raw)) as Map<String, dynamic>;
  return (data['ingredients'] as List)
      .map((e) => DetectedIngredient.fromJson(e as Map<String, dynamic>))
      .toList();
}
