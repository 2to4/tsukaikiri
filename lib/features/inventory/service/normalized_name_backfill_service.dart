import '../../recipe/service/recipe_provider.dart';
import '../data/inventory_repository.dart';

/// 在庫の normalizedName（名寄せキー）を AI で一括付与するサービス。
///
/// AI 連携前に登録した食材は normalizedName に name を流用しているため、
/// それらを対象に [RecipeProvider.normalize] でキーを取得して埋める。
/// 冪等（付与済みの行には触れない）なので、献立提案フローの後などに
/// 繰り返し呼んでよい。
class NormalizedNameBackfillService {
  NormalizedNameBackfillService(this._repository, this._provider);

  final InventoryRepository _repository;
  final RecipeProvider _provider;

  /// 1回の normalize に渡す名前数の上限（プロンプト肥大の防止）。
  static const _chunkSize = 50;

  /// バックフィルを実行し、更新した行数を返す。対象がなければ AI を呼ばない。
  /// 通信失敗時は [RecipeProviderException] 等が伝播する。
  Future<int> run() async {
    final targets = await _repository.findUnnormalized();
    if (targets.isEmpty) return 0;

    final names = targets.map((i) => i.name).toSet().toList();
    final keysByName = <String, String>{};
    for (var i = 0; i < names.length; i += _chunkSize) {
      final chunk = names.sublist(
          i, i + _chunkSize > names.length ? names.length : i + _chunkSize);
      keysByName.addAll(await _provider.normalize(chunk));
    }

    // キーが名前と同一なら書き込んでも意味がないので除外する。
    keysByName.removeWhere((name, key) => key == name);
    if (keysByName.isEmpty) return 0;
    return _repository.applyNormalizedNames(keysByName);
  }
}
