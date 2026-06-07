import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/unit_option.dart';
import '../ingredient_form_screen.dart';
import 'expiry_badge.dart';

/// 食材の詳細表示。狭い画面では詳細ページ、広い画面では右ペインに置く。
class IngredientDetailView extends ConsumerWidget {
  const IngredientDetailView({
    super.key,
    required this.ingredient,
    this.onDeleted,
  });

  final Ingredient ingredient;

  /// 削除後に呼ばれる（狭い画面では pop、広い画面では選択解除に使う）。
  final VoidCallback? onDeleted;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody(ingredient.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(inventoryRepositoryProvider).deleteById(ingredient.id);
      onDeleted?.call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final qtyText =
        '${formatQuantity(ingredient.quantity)} ${unitLabel(ingredient.unit, l10n)}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(ingredient.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _row(context, l10n.fieldCategory, ingredient.category.label(l10n)),
        _row(context, l10n.fieldQuantity, qtyText),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(l10n.fieldExpiry,
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              ExpiryBadge(expiry: ingredient.expiryDate),
              const SizedBox(width: 8),
              if (ingredient.expiryDate != null)
                Text(dateFmt.format(ingredient.expiryDate!)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.remove),
              label: const Text('-1'),
              onPressed: () =>
                  ref.read(inventoryRepositoryProvider).decrement(ingredient.id),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.edit),
              label: Text(l10n.editIngredient),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => IngredientFormScreen(ingredient: ingredient),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.actionDelete),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
