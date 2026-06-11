import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/shelf_life/shelf_life.dart';
import '../../../core/utils/quantity_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ingredient_category.dart';
import '../domain/unit_option.dart';

const _uuid = Uuid();
const _customUnitSentinel = '__custom__';

/// 食材の追加・編集フォーム。[ingredient] が null なら新規。
class IngredientFormScreen extends ConsumerStatefulWidget {
  const IngredientFormScreen({super.key, this.ingredient});

  final Ingredient? ingredient;

  @override
  ConsumerState<IngredientFormScreen> createState() =>
      _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _customUnitCtrl;

  late IngredientCategory _category;

  /// 選択中の定義済み単位。null のときはカスタム入力。
  UnitOption? _unitOption;
  DateTime? _expiry;
  bool _expiryManuallySet = false;

  bool get _isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();
    final ing = widget.ingredient;
    _nameCtrl = TextEditingController(text: ing?.name ?? '');
    _quantityCtrl = TextEditingController(
      text: ing != null ? formatQuantity(ing.quantity) : '1',
    );

    if (ing != null) {
      _category = ing.category;
      _unitOption = UnitOption.values
          .where((u) => u.name == ing.unit)
          .cast<UnitOption?>()
          .firstOrNull;
      _customUnitCtrl = TextEditingController(
        text: _unitOption == null ? ing.unit : '',
      );
      _expiry = ing.expiryDate;
      _expiryManuallySet = true; // 既存値は維持する
    } else {
      _category = IngredientCategory.vegetable;
      _unitOption = UnitOption.piece;
      _customUnitCtrl = TextEditingController();
      // 初期値はカテゴリ目安のみ（名前は空なのでテーブル照合はしない）。
      _expiry = defaultExpiryFrom(_category, DateTime.now());
    }
  }

  /// 名前・カテゴリから期限を再計算する。ユーザーが手動変更済みなら何もしない。
  void _recalcExpiry() {
    if (_expiryManuallySet) return;
    final table = ref.read(shelfLifeTableProvider);
    setState(() {
      _expiry = expiryFromName(
        table,
        _nameCtrl.text.trim(),
        _category,
        DateTime.now(),
      );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _customUnitCtrl.dispose();
    super.dispose();
  }

  void _onCategoryChanged(IngredientCategory value) {
    _category = value;
    // ユーザーが期限を触っていなければ名前＋カテゴリ目安で更新する。
    if (_expiryManuallySet) {
      setState(() {});
    } else {
      _recalcExpiry();
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _expiry = picked;
        _expiryManuallySet = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    final quantity = double.parse(_quantityCtrl.text.trim().replaceAll(',', '.'));
    final unitToken = _unitOption?.name ?? _customUnitCtrl.text.trim();
    if (unitToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationUnitRequired)),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.ingredient;
    final ingredient = Ingredient(
      id: existing?.id ?? _uuid.v4(),
      name: name,
      // AI 連携前は name を名寄せキーに流用（後でバックフィル）。
      normalizedName: existing?.normalizedName ?? name,
      category: _category,
      quantity: quantity,
      unit: unitToken,
      expiryDate: _expiry,
      updatedAt: now,
    );
    await ref.read(inventoryRepositoryProvider).save(ingredient);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editIngredient : l10n.addIngredient),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.fieldName),
              textInputAction: TextInputAction.next,
              // 編集モードでは既存値維持のため再計算しない（_expiryManuallySet）。
              onChanged: (_) => _recalcExpiry(),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.validationNameRequired
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IngredientCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.fieldCategory),
              items: [
                for (final c in IngredientCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label(l10n))),
              ],
              onChanged: (v) => v == null ? null : _onCategoryChanged(v),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityCtrl,
                    decoration: InputDecoration(labelText: l10n.fieldQuantity),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final parsed =
                          double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return l10n.validationQuantityInvalid;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildUnitField(l10n)),
              ],
            ),
            if (_unitOption == null) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customUnitCtrl,
                decoration: InputDecoration(labelText: l10n.customUnitLabel),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fieldExpiryOptional),
              subtitle: Text(
                _expiry != null ? dateFmt.format(_expiry!) : l10n.expiryNone,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiry != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.actionClear,
                      onPressed: () => setState(() {
                        _expiry = null;
                        _expiryManuallySet = true;
                      }),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickExpiry,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitField(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _unitOption?.name ?? _customUnitSentinel,
      decoration: InputDecoration(labelText: l10n.fieldUnit),
      isExpanded: true,
      items: [
        for (final u in UnitOption.values)
          DropdownMenuItem(value: u.name, child: Text(u.label(l10n))),
        DropdownMenuItem(
          value: _customUnitSentinel,
          child: Text(l10n.unitCustom),
        ),
      ],
      onChanged: (v) => setState(() {
        _unitOption = v == _customUnitSentinel
            ? null
            : UnitOption.values.firstWhere((u) => u.name == v);
      }),
    );
  }
}
