import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/ingredient_category.dart';
import 'ingredient_form_screen.dart';
import 'inventory_providers.dart';
import 'widgets/ingredient_detail_view.dart';
import 'widgets/ingredient_tile.dart';

/// 二ペイン表示に切り替える画面幅のしきい値。
const double _tabletBreakpoint = 720;

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  void _openForm(BuildContext context, {Ingredient? ingredient}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IngredientFormScreen(ingredient: ingredient),
      ),
    );
  }

  void _openDetailNarrow(BuildContext context, Ingredient ingredient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(ingredient.name)),
          body: IngredientDetailView(
            ingredient: ingredient,
            onDeleted: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncList = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _CategoryFilterBar(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _tabletBreakpoint;
            final list = _InventoryList(
              items: items,
              isWide: isWide,
              onTapNarrow: (ing) => _openDetailNarrow(context, ing),
            );
            if (!isWide) return list;
            return Row(
              children: [
                Expanded(flex: 2, child: list),
                const VerticalDivider(width: 1),
                Expanded(flex: 3, child: _DetailPane(items: items)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InventoryList extends ConsumerWidget {
  const _InventoryList({
    required this.items,
    required this.isWide,
    required this.onTapNarrow,
  });

  final List<Ingredient> items;
  final bool isWide;
  final void Function(Ingredient) onTapNarrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.emptyInventory, textAlign: TextAlign.center),
        ),
      );
    }
    final selectedId = ref.watch(selectedIngredientIdProvider);
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final ing = items[i];
        return IngredientTile(
          ingredient: ing,
          selected: isWide && ing.id == selectedId,
          onTap: () {
            if (isWide) {
              ref.read(selectedIngredientIdProvider.notifier).set(ing.id);
            } else {
              onTapNarrow(ing);
            }
          },
          onDecrement: () =>
              ref.read(inventoryRepositoryProvider).decrement(ing.id),
        );
      },
    );
  }
}

class _DetailPane extends ConsumerWidget {
  const _DetailPane({required this.items});

  final List<Ingredient> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedId = ref.watch(selectedIngredientIdProvider);
    final selected =
        items.where((e) => e.id == selectedId).cast<Ingredient?>().firstOrNull;

    if (selected == null) {
      return Center(child: Text(l10n.selectIngredientPrompt));
    }
    return IngredientDetailView(
      ingredient: selected,
      onDeleted: () =>
          ref.read(selectedIngredientIdProvider.notifier).set(null),
    );
  }
}

class _CategoryFilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(categoryFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.filterAll),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(categoryFilterProvider.notifier).set(null),
            ),
          ),
          for (final c in IngredientCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c.label(l10n)),
                selected: selected == c,
                onSelected: (_) =>
                    ref.read(categoryFilterProvider.notifier).set(c),
              ),
            ),
        ],
      ),
    );
  }
}
