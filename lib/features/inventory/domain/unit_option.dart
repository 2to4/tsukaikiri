import '../../../l10n/app_localizations.dart';

/// あらかじめ用意した単位の選択肢。
///
/// DB の `unit` 列には、定義済み単位なら列挙子名（例: `piece`）を、
/// ユーザーが自由入力したカスタム単位ならその文字列をそのまま保存する。
/// これにより UI 表示言語が変わっても保存値は安定する。
enum UnitOption {
  piece,
  gram,
  kg,
  ml,
  l,
  bottle,
  sheet,
  pack,
  bag,
  go,
  cup,
  can;

  String label(AppLocalizations l10n) => switch (this) {
        UnitOption.piece => l10n.unitPiece,
        UnitOption.gram => l10n.unitGram,
        UnitOption.kg => l10n.unitKg,
        UnitOption.ml => l10n.unitMl,
        UnitOption.l => l10n.unitL,
        UnitOption.bottle => l10n.unitBottle,
        UnitOption.sheet => l10n.unitSheet,
        UnitOption.pack => l10n.unitPack,
        UnitOption.bag => l10n.unitBag,
        UnitOption.go => l10n.unitGo,
        UnitOption.cup => l10n.unitCup,
        UnitOption.can => l10n.unitCan,
      };
}

/// 保存された単位トークンを表示用ラベルに変換する。
/// 定義済み単位ならローカライズし、カスタムならトークンをそのまま返す。
String unitLabel(String token, AppLocalizations l10n) {
  for (final u in UnitOption.values) {
    if (u.name == token) return u.label(l10n);
  }
  return token;
}
