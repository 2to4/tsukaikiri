enum ApplianceType { hotcook, healsio }

/// 設定画面で提示する型（シリーズ）の選択肢（デザイン settings.jsx 由来）。
/// デスクトップ・モバイルの設定 UI で共用する。
const applianceSeriesOptions = <ApplianceType, List<String>>{
  ApplianceType.hotcook: ['KN-HW型', 'KN-HT型'],
  ApplianceType.healsio: ['AX-XA型', 'AX-LSX型'],
};

/// 設定画面で提示する容量の選択肢。
const applianceCapacityOptions = <ApplianceType, List<String>>{
  ApplianceType.hotcook: ['1.0L', '1.6L', '2.4L'],
  ApplianceType.healsio: ['26L', '30L'],
};

class Appliance {
  const Appliance({
    required this.type,
    this.series,
    this.capacity,
    this.modelNumber,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) => Appliance(
        type: ApplianceType.values.byName(json['type'] as String),
        series: json['series'] as String?,
        capacity: json['capacity'] as String?,
        modelNumber: json['modelNumber'] as String?,
      );

  final ApplianceType type;
  final String? series;
  final String? capacity;
  final String? modelNumber;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (series != null) 'series': series,
        if (capacity != null) 'capacity': capacity,
        if (modelNumber != null) 'modelNumber': modelNumber,
      };
}
