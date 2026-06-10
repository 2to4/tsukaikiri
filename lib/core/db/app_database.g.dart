// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngredientCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<IngredientCategory>($IngredientsTable.$convertercategory);
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    category,
    quantity,
    unit,
    expiryDate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      category: $IngredientsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IngredientCategory, String, String>
  $convertercategory = const EnumNameConverter<IngredientCategory>(
    IngredientCategory.values,
  );
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String id;
  final String name;

  /// 名寄せキー（言語非依存）。AI 連携前は name を流用し、AI 実装後にバックフィルする。
  final String normalizedName;

  /// 列挙子名で保存（言語非依存の固定キー）。
  final IngredientCategory category;

  /// 数量は小数許可。
  final double quantity;

  /// 定義済み単位は [UnitOption] の列挙子名、カスタムは自由文字列。
  final String unit;

  /// 賞味期限は任意。
  final DateTime? expiryDate;
  final DateTime updatedAt;
  const Ingredient({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    {
      map['category'] = Variable<String>(
        $IngredientsTable.$convertercategory.toSql(category),
      );
    }
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      category: Value(category),
      quantity: Value(quantity),
      unit: Value(unit),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      updatedAt: Value(updatedAt),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      category: $IngredientsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'category': serializer.toJson<String>(
        $IngredientsTable.$convertercategory.toJson(category),
      ),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? normalizedName,
    IngredientCategory? category,
    double? quantity,
    String? unit,
    Value<DateTime?> expiryDate = const Value.absent(),
    DateTime? updatedAt,
  }) => Ingredient(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    category,
    quantity,
    unit,
    expiryDate,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.expiryDate == this.expiryDate &&
          other.updatedAt == this.updatedAt);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<IngredientCategory> category;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<DateTime?> expiryDate;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    required IngredientCategory category,
    required double quantity,
    required String unit,
    this.expiryDate = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       category = Value(category),
       quantity = Value(quantity),
       unit = Value(unit),
       updatedAt = Value(updatedAt);
  static Insertable<Ingredient> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? category,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<DateTime>? expiryDate,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<IngredientCategory>? category,
    Value<double>? quantity,
    Value<String>? unit,
    Value<DateTime?>? expiryDate,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $IngredientsTable.$convertercategory.toSql(category.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localePrefMeta = const VerificationMeta(
    'localePref',
  );
  @override
  late final GeneratedColumn<String> localePref = GeneratedColumn<String>(
    'locale_pref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _shoppingListIdMeta = const VerificationMeta(
    'shoppingListId',
  );
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
    'shopping_list_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shoppingListNameMeta = const VerificationMeta(
    'shoppingListName',
  );
  @override
  late final GeneratedColumn<String> shoppingListName = GeneratedColumn<String>(
    'shopping_list_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedProviderMeta = const VerificationMeta(
    'selectedProvider',
  );
  @override
  late final GeneratedColumn<String> selectedProvider = GeneratedColumn<String>(
    'selected_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gemini'),
  );
  static const VerificationMeta _syncEnabledMeta = const VerificationMeta(
    'syncEnabled',
  );
  @override
  late final GeneratedColumn<bool> syncEnabled = GeneratedColumn<bool>(
    'sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliancesJsonMeta = const VerificationMeta(
    'appliancesJson',
  );
  @override
  late final GeneratedColumn<String> appliancesJson = GeneratedColumn<String>(
    'appliances_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localePref,
    shoppingListId,
    shoppingListName,
    selectedProvider,
    syncEnabled,
    lastSyncedAt,
    appliancesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locale_pref')) {
      context.handle(
        _localePrefMeta,
        localePref.isAcceptableOrUnknown(data['locale_pref']!, _localePrefMeta),
      );
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
        _shoppingListIdMeta,
        shoppingListId.isAcceptableOrUnknown(
          data['shopping_list_id']!,
          _shoppingListIdMeta,
        ),
      );
    }
    if (data.containsKey('shopping_list_name')) {
      context.handle(
        _shoppingListNameMeta,
        shoppingListName.isAcceptableOrUnknown(
          data['shopping_list_name']!,
          _shoppingListNameMeta,
        ),
      );
    }
    if (data.containsKey('selected_provider')) {
      context.handle(
        _selectedProviderMeta,
        selectedProvider.isAcceptableOrUnknown(
          data['selected_provider']!,
          _selectedProviderMeta,
        ),
      );
    }
    if (data.containsKey('sync_enabled')) {
      context.handle(
        _syncEnabledMeta,
        syncEnabled.isAcceptableOrUnknown(
          data['sync_enabled']!,
          _syncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('appliances_json')) {
      context.handle(
        _appliancesJsonMeta,
        appliancesJson.isAcceptableOrUnknown(
          data['appliances_json']!,
          _appliancesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localePref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_pref'],
      )!,
      shoppingListId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shopping_list_id'],
      ),
      shoppingListName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shopping_list_name'],
      ),
      selectedProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_provider'],
      )!,
      syncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_enabled'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      appliancesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appliances_json'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final int id;

  /// 'ja' / 'en' / 'system'
  final String localePref;

  /// macOS/iOS=calendarIdentifier / Android=tasklist id
  final String? shoppingListId;

  /// UI 表示用リスト名（識別子で引き当てた現在名）
  final String? shoppingListName;

  /// 'gemini' / 'claude' / 'openai' / 'grok'
  final String selectedProvider;
  final bool syncEnabled;
  final DateTime? lastSyncedAt;

  /// [{"type":"hotcook","capacity":"2.4L"}, ...] の形式で保存。
  final String appliancesJson;
  const AppSettings({
    required this.id,
    required this.localePref,
    this.shoppingListId,
    this.shoppingListName,
    required this.selectedProvider,
    required this.syncEnabled,
    this.lastSyncedAt,
    required this.appliancesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['locale_pref'] = Variable<String>(localePref);
    if (!nullToAbsent || shoppingListId != null) {
      map['shopping_list_id'] = Variable<String>(shoppingListId);
    }
    if (!nullToAbsent || shoppingListName != null) {
      map['shopping_list_name'] = Variable<String>(shoppingListName);
    }
    map['selected_provider'] = Variable<String>(selectedProvider);
    map['sync_enabled'] = Variable<bool>(syncEnabled);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['appliances_json'] = Variable<String>(appliancesJson);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      localePref: Value(localePref),
      shoppingListId: shoppingListId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingListId),
      shoppingListName: shoppingListName == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingListName),
      selectedProvider: Value(selectedProvider),
      syncEnabled: Value(syncEnabled),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      appliancesJson: Value(appliancesJson),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<int>(json['id']),
      localePref: serializer.fromJson<String>(json['localePref']),
      shoppingListId: serializer.fromJson<String?>(json['shoppingListId']),
      shoppingListName: serializer.fromJson<String?>(json['shoppingListName']),
      selectedProvider: serializer.fromJson<String>(json['selectedProvider']),
      syncEnabled: serializer.fromJson<bool>(json['syncEnabled']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      appliancesJson: serializer.fromJson<String>(json['appliancesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localePref': serializer.toJson<String>(localePref),
      'shoppingListId': serializer.toJson<String?>(shoppingListId),
      'shoppingListName': serializer.toJson<String?>(shoppingListName),
      'selectedProvider': serializer.toJson<String>(selectedProvider),
      'syncEnabled': serializer.toJson<bool>(syncEnabled),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'appliancesJson': serializer.toJson<String>(appliancesJson),
    };
  }

  AppSettings copyWith({
    int? id,
    String? localePref,
    Value<String?> shoppingListId = const Value.absent(),
    Value<String?> shoppingListName = const Value.absent(),
    String? selectedProvider,
    bool? syncEnabled,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? appliancesJson,
  }) => AppSettings(
    id: id ?? this.id,
    localePref: localePref ?? this.localePref,
    shoppingListId: shoppingListId.present
        ? shoppingListId.value
        : this.shoppingListId,
    shoppingListName: shoppingListName.present
        ? shoppingListName.value
        : this.shoppingListName,
    selectedProvider: selectedProvider ?? this.selectedProvider,
    syncEnabled: syncEnabled ?? this.syncEnabled,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    appliancesJson: appliancesJson ?? this.appliancesJson,
  );
  AppSettings copyWithCompanion(SettingsTableCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      localePref: data.localePref.present
          ? data.localePref.value
          : this.localePref,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      shoppingListName: data.shoppingListName.present
          ? data.shoppingListName.value
          : this.shoppingListName,
      selectedProvider: data.selectedProvider.present
          ? data.selectedProvider.value
          : this.selectedProvider,
      syncEnabled: data.syncEnabled.present
          ? data.syncEnabled.value
          : this.syncEnabled,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      appliancesJson: data.appliancesJson.present
          ? data.appliancesJson.value
          : this.appliancesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('localePref: $localePref, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('shoppingListName: $shoppingListName, ')
          ..write('selectedProvider: $selectedProvider, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('appliancesJson: $appliancesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localePref,
    shoppingListId,
    shoppingListName,
    selectedProvider,
    syncEnabled,
    lastSyncedAt,
    appliancesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.localePref == this.localePref &&
          other.shoppingListId == this.shoppingListId &&
          other.shoppingListName == this.shoppingListName &&
          other.selectedProvider == this.selectedProvider &&
          other.syncEnabled == this.syncEnabled &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.appliancesJson == this.appliancesJson);
}

class SettingsTableCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<String> localePref;
  final Value<String?> shoppingListId;
  final Value<String?> shoppingListName;
  final Value<String> selectedProvider;
  final Value<bool> syncEnabled;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> appliancesJson;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.localePref = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.shoppingListName = const Value.absent(),
    this.selectedProvider = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.appliancesJson = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.localePref = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.shoppingListName = const Value.absent(),
    this.selectedProvider = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.appliancesJson = const Value.absent(),
  });
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<String>? localePref,
    Expression<String>? shoppingListId,
    Expression<String>? shoppingListName,
    Expression<String>? selectedProvider,
    Expression<bool>? syncEnabled,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? appliancesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localePref != null) 'locale_pref': localePref,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (shoppingListName != null) 'shopping_list_name': shoppingListName,
      if (selectedProvider != null) 'selected_provider': selectedProvider,
      if (syncEnabled != null) 'sync_enabled': syncEnabled,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (appliancesJson != null) 'appliances_json': appliancesJson,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? localePref,
    Value<String?>? shoppingListId,
    Value<String?>? shoppingListName,
    Value<String>? selectedProvider,
    Value<bool>? syncEnabled,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? appliancesJson,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      localePref: localePref ?? this.localePref,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      shoppingListName: shoppingListName ?? this.shoppingListName,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      appliancesJson: appliancesJson ?? this.appliancesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localePref.present) {
      map['locale_pref'] = Variable<String>(localePref.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (shoppingListName.present) {
      map['shopping_list_name'] = Variable<String>(shoppingListName.value);
    }
    if (selectedProvider.present) {
      map['selected_provider'] = Variable<String>(selectedProvider.value);
    }
    if (syncEnabled.present) {
      map['sync_enabled'] = Variable<bool>(syncEnabled.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (appliancesJson.present) {
      map['appliances_json'] = Variable<String>(appliancesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('localePref: $localePref, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('shoppingListName: $shoppingListName, ')
          ..write('selectedProvider: $selectedProvider, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('appliancesJson: $appliancesJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ingredients,
    settingsTable,
  ];
}

typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      required IngredientCategory category,
      required double quantity,
      required String unit,
      Value<DateTime?> expiryDate,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<IngredientCategory> category,
      Value<double> quantity,
      Value<String> unit,
      Value<DateTime?> expiryDate,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngredientCategory, IngredientCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IngredientCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (
            Ingredient,
            BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
          ),
          Ingredient,
          PrefetchHooks Function()
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<IngredientCategory> category = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                category: category,
                quantity: quantity,
                unit: unit,
                expiryDate: expiryDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                required IngredientCategory category,
                required double quantity,
                required String unit,
                Value<DateTime?> expiryDate = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                category: category,
                quantity: quantity,
                unit: unit,
                expiryDate: expiryDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (
        Ingredient,
        BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
      ),
      Ingredient,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<String> localePref,
      Value<String?> shoppingListId,
      Value<String?> shoppingListName,
      Value<String> selectedProvider,
      Value<bool> syncEnabled,
      Value<DateTime?> lastSyncedAt,
      Value<String> appliancesJson,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<String> localePref,
      Value<String?> shoppingListId,
      Value<String?> shoppingListName,
      Value<String> selectedProvider,
      Value<bool> syncEnabled,
      Value<DateTime?> lastSyncedAt,
      Value<String> appliancesJson,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localePref => $composableBuilder(
    column: $table.localePref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shoppingListName => $composableBuilder(
    column: $table.shoppingListName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedProvider => $composableBuilder(
    column: $table.selectedProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliancesJson => $composableBuilder(
    column: $table.appliancesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localePref => $composableBuilder(
    column: $table.localePref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shoppingListName => $composableBuilder(
    column: $table.shoppingListName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedProvider => $composableBuilder(
    column: $table.selectedProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliancesJson => $composableBuilder(
    column: $table.appliancesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localePref => $composableBuilder(
    column: $table.localePref,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shoppingListName => $composableBuilder(
    column: $table.shoppingListName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedProvider => $composableBuilder(
    column: $table.selectedProvider,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appliancesJson => $composableBuilder(
    column: $table.appliancesJson,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          AppSettings,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            AppSettings,
            BaseReferences<_$AppDatabase, $SettingsTableTable, AppSettings>,
          ),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localePref = const Value.absent(),
                Value<String?> shoppingListId = const Value.absent(),
                Value<String?> shoppingListName = const Value.absent(),
                Value<String> selectedProvider = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> appliancesJson = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                localePref: localePref,
                shoppingListId: shoppingListId,
                shoppingListName: shoppingListName,
                selectedProvider: selectedProvider,
                syncEnabled: syncEnabled,
                lastSyncedAt: lastSyncedAt,
                appliancesJson: appliancesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localePref = const Value.absent(),
                Value<String?> shoppingListId = const Value.absent(),
                Value<String?> shoppingListName = const Value.absent(),
                Value<String> selectedProvider = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> appliancesJson = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                localePref: localePref,
                shoppingListId: shoppingListId,
                shoppingListName: shoppingListName,
                selectedProvider: selectedProvider,
                syncEnabled: syncEnabled,
                lastSyncedAt: lastSyncedAt,
                appliancesJson: appliancesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      AppSettings,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        AppSettings,
        BaseReferences<_$AppDatabase, $SettingsTableTable, AppSettings>,
      ),
      AppSettings,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
