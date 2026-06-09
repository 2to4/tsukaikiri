import 'package:flutter/material.dart';

import '../../domain/category_style.dart';
import '../../domain/ingredient_category.dart';

/// カテゴリ色のタイルに代表絵文字を載せた角丸タイル（Claude Design の CatTile）。
class CatTile extends StatelessWidget {
  const CatTile({super.key, required this.category, this.size = 52});

  final IngredientCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = category.style;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.tile,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Text(style.emoji, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}
