import '../../settings/domain/appliance.dart';

/// 献立提案の絞り込み条件（UI の条件チップに対応）。
/// 値（識別子）は言語非依存。プロンプトでの自然文表現は recipe_prompts.dart 側で持つ。
enum MealKind {
  /// おまかせ（指定なし）
  auto,

  /// 主菜のみ
  mainOnly,

  /// あと1品（副菜・汁物など軽めの一品）
  oneMore,

  /// 時短（短時間で作れるもの）
  quick,
}

/// AI への献立提案リクエストに付随する制約条件。
class RecipeConstraints {
  const RecipeConstraints({
    this.appliances = const [],
    required this.outputLocale,
    this.mealKind = MealKind.auto,
    this.allowNewIngredients = false,
    this.extraRequest,
    this.count = 3,
  });

  /// 所有家電。調理手順の出し分けに使う。
  final List<Appliance> appliances;

  /// 出力言語（'ja' / 'en'）。AI に返答言語として指示する。
  final String outputLocale;

  /// 条件チップで選ばれた献立の種類。
  final MealKind mealKind;

  /// 在庫が少ないとき、在庫にない新規食材を含む提案を許可するか。
  /// true のとき、AI は買い足し前提の献立も提案してよい。
  final bool allowNewIngredients;

  /// 追加の絞り込み条件（自由文。将来の拡張用）。
  final String? extraRequest;

  /// 提案する献立数。
  final int count;
}
