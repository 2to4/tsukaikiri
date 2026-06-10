/// AI プロバイダが提供するモデルの情報。
/// 各プロバイダのモデル一覧 API から取得する（ハードコードしない）。
class AiModel {
  const AiModel({required this.id, String? displayName})
      : displayName = displayName ?? id;

  /// API リクエストに渡すモデル ID（例: 'gemini-2.0-flash'）。
  final String id;

  /// UI 表示名。API が表示名を返さないプロバイダ（OpenAI 互換）では id と同じ。
  final String displayName;
}
