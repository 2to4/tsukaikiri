import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/utils/quantity_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/unit_option.dart';
import 'expiry_badge.dart';

/// 在庫一覧の 1 行。タップで詳細、マイナスボタンで 1 減算。
class IngredientTile extends StatelessWidget {
  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.selected,
    required this.onTap,
    required this.onDecrement,
  });

  final Ingredient ingredient;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qtyText =
        '${formatQuantity(ingredient.quantity)} ${unitLabel(ingredient.unit, l10n)}';

    return ListTile(
      selected: selected,
      onTap: onTap,
      title: Text(ingredient.name),
      subtitle: Text('${ingredient.category.label(l10n)} · $qtyText'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpiryBadge(expiry: ingredient.expiryDate),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: '-1',
            onPressed: onDecrement,
          ),
        ],
      ),
    );
  }
}
