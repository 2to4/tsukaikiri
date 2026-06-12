import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../shopping/domain/shopping_list.dart';
import '../domain/appliance.dart';
import 'settings_screen.dart';

// ──────────────────────────────────────────────────────────────
// 買い物リスト設定（モバイル）
// デスクトップ版 _ShoppingSection と同じデータ操作:
// getLists 読み込み → 選択（setShoppingList）→ 新規作成（createList）。
// ──────────────────────────────────────────────────────────────
class ShoppingSettingsScreen extends ConsumerStatefulWidget {
  const ShoppingSettingsScreen({super.key});

  @override
  ConsumerState<ShoppingSettingsScreen> createState() =>
      _ShoppingSettingsScreenState();
}

class _ShoppingSettingsScreenState
    extends ConsumerState<ShoppingSettingsScreen> {
  bool _loading = false;
  List<ShoppingList>? _lists;
  String? _error;
  final _newListController = TextEditingController();

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lists = await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() {
        _lists = lists;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).settingsShoppingLoadError;
      });
    }
  }

  Future<void> _createList() async {
    final name = _newListController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final created =
          await ref.read(shoppingListServiceProvider).createList(name);
      await ref
          .read(settingsRepositoryProvider)
          .setShoppingList(created.id, created.name);
      _newListController.clear();
      if (!mounted) return;
      setState(() {
        _lists = [...?_lists, created];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).settingsShoppingLoadError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final currentId = settingsAsync.value?.shoppingListId;
    final currentName = settingsAsync.value?.shoppingListName;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingsNavBar(title: l10n.settingsShoppingHeading),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                children: [
                  // 連携先アプリ + 現在の選択
                  SettingsSection(
                    note: l10n.settingsShoppingCurrent(
                        currentName ?? l10n.settingsShoppingNone),
                    children: [
                      SettingsRow(
                        icon: Icons.checklist,
                        label: l10n.settingsShoppingLinkedApp,
                        value: l10n.settingsShoppingReminders,
                        last: true,
                      ),
                    ],
                  ),
                  // リスト読み込み + 一覧
                  SettingsSection(
                    children: [
                      SettingsRow(
                        icon: Icons.refresh,
                        label: _loading
                            ? l10n.settingsShoppingLoading
                            : l10n.settingsShoppingLoad,
                        last: _lists == null || _lists!.isEmpty,
                        onTap: _loading ? null : _loadLists,
                      ),
                      if (_lists != null)
                        for (var i = 0; i < _lists!.length; i++)
                          SettingsRow(
                            label: _lists![i].name,
                            last: i == _lists!.length - 1,
                            trailing: SettingsRadioMark(
                                on: _lists![i].id == currentId),
                            onTap: () => ref
                                .read(settingsRepositoryProvider)
                                .setShoppingList(
                                    _lists![i].id, _lists![i].name),
                          ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.over,
                        ),
                      ),
                    ),
                  // 新規リスト作成
                  SettingsSection(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newListController,
                                onSubmitted: (_) => _createList(),
                                style: const TextStyle(
                                    fontSize: 13.5, color: AppColors.ink),
                                decoration: InputDecoration(
                                  hintText: l10n.settingsShoppingNewName,
                                  hintStyle: const TextStyle(
                                      fontSize: 13, color: AppColors.faint),
                                  isDense: true,
                                  filled: true,
                                  fillColor: AppColors.bg,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: AppColors.line),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: AppColors.line),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: AppColors.green),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _loading ? null : _createList,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(l10n.settingsShoppingCreate,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 調理家電設定（モバイル）
// デスクトップ版 _ApplianceSection と同じデータ操作（setAppliances）。
// ──────────────────────────────────────────────────────────────
class ApplianceSettingsScreen extends ConsumerWidget {
  const ApplianceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingsNavBar(title: l10n.settingsApplianceHeading),
            Expanded(
              child: settingsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (settings) {
                  final appliances = settings.appliances;
                  Appliance? find(ApplianceType type) =>
                      appliances.where((a) => a.type == type).firstOrNull;

                  Future<void> update(
                      ApplianceType type, Appliance? next) async {
                    final others =
                        appliances.where((a) => a.type != type).toList();
                    final list = next != null ? [...others, next] : others;
                    await ref
                        .read(settingsRepositoryProvider)
                        .setAppliances(list);
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                    children: [
                      _ApplianceTile(
                        type: ApplianceType.hotcook,
                        name: l10n.settingsApplianceHotcook,
                        icon: Icons.soup_kitchen_outlined,
                        appliance: find(ApplianceType.hotcook),
                        seriesOpts: applianceSeriesOptions[ApplianceType.hotcook]!,
                        capacityOpts: applianceCapacityOptions[ApplianceType.hotcook]!,
                        onChanged: (a) => update(ApplianceType.hotcook, a),
                      ),
                      _ApplianceTile(
                        type: ApplianceType.healsio,
                        name: l10n.settingsApplianceHealsio,
                        icon: Icons.microwave_outlined,
                        appliance: find(ApplianceType.healsio),
                        seriesOpts: applianceSeriesOptions[ApplianceType.healsio]!,
                        capacityOpts: applianceCapacityOptions[ApplianceType.healsio]!,
                        onChanged: (a) => update(ApplianceType.healsio, a),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        child: Text(
                          l10n.settingsApplianceNote,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: AppColors.faint,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 家電1台分のカード（所有トグル + 型・容量の選択）。
class _ApplianceTile extends StatelessWidget {
  const _ApplianceTile({
    required this.type,
    required this.name,
    required this.icon,
    required this.appliance,
    required this.seriesOpts,
    required this.capacityOpts,
    required this.onChanged,
  });

  final ApplianceType type;
  final String name;
  final IconData icon;
  final Appliance? appliance;
  final List<String> seriesOpts;
  final List<String> capacityOpts;
  final ValueChanged<Appliance?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = appliance != null;
    final series = appliance?.series ?? seriesOpts.first;
    final capacity = appliance?.capacity ?? capacityOpts.first;

    return SettingsSection(
      children: [
        SettingsRow(
          icon: icon,
          label: name,
          value: on ? '$series ・ $capacity' : l10n.settingsApplianceNotOwned,
          last: !on,
          trailing: Switch(
            value: on,
            activeTrackColor: AppColors.green,
            onChanged: (v) => onChanged(v
                ? Appliance(
                    type: type,
                    series: seriesOpts.first,
                    capacity: capacityOpts.first,
                  )
                : null),
          ),
        ),
        if (on) ...[
          _ChipPickerRow(
            label: l10n.settingsApplianceSeries,
            options: seriesOpts,
            selected: series,
            onSelect: (v) => onChanged(
                Appliance(type: type, series: v, capacity: capacity)),
          ),
          _ChipPickerRow(
            label: l10n.settingsApplianceCapacity,
            options: capacityOpts,
            selected: capacity,
            last: true,
            onSelect: (v) => onChanged(
                Appliance(type: type, series: series, capacity: v)),
          ),
        ],
      ],
    );
  }
}

/// ラベル + 選択チップ列の1行。
class _ChipPickerRow extends StatelessWidget {
  const _ChipPickerRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.last = false,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                child: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sub),
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final opt in options)
                      _Chip(
                        label: opt,
                        selected: opt == selected,
                        onTap: () => onSelect(opt),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green : AppColors.bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: selected ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.sub,
            ),
          ),
        ),
      ),
    );
  }
}
