/// カメラ登録時に AI が画像から検出した食材候補。
class DetectedIngredient {
  const DetectedIngredient({
    required this.name,
    this.estimatedQuantity = 1.0,
    this.unit = '個',
    required this.confidence,
  });

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) =>
      DetectedIngredient(
        name: json['name'] as String,
        estimatedQuantity: (json['estimatedQuantity'] as num?)?.toDouble() ?? 1.0,
        unit: json['unit'] as String? ?? '個',
        confidence: (json['confidence'] as num).toDouble(),
      );

  final String name;
  final double estimatedQuantity;
  final String unit;

  /// 0.0〜1.0。低い候補は確認画面で薄く表示する。
  final double confidence;
}
