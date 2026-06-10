import '../../settings/domain/appliance.dart';

/// AI への献立提案リクエストに付随する制約条件。
class RecipeConstraints {
  const RecipeConstraints({
    this.appliances = const [],
    required this.outputLocale,
    this.extraRequest,
    this.count = 3,
  });

  /// 所有家電。調理手順の出し分けに使う。
  final List<Appliance> appliances;

  /// 出力言語（'ja' / 'en'）。AI に返答言語として指示する。
  final String outputLocale;

  /// 追加の絞り込み条件（例: 「あと1品」「主菜のみ」）。
  final String? extraRequest;

  /// 提案する献立数。
  final int count;
}
