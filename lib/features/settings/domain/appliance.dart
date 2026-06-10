enum ApplianceType { hotcook, healsio }

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
