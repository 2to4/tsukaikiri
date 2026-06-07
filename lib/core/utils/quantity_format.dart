/// 数量の表示整形。整数なら小数点を出さず、端数があればそのまま表示する。
String formatQuantity(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toString();
