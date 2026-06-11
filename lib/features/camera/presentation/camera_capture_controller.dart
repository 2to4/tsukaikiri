// camera_capture_controller.dart
// カメラ登録画面（M6）のコントローラ。
// ShoppingConfirmController のパターン（enum フェーズ + Notifier）に従う。

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../../core/shelf_life/shelf_life.dart';
import '../../../core/db/app_database.dart';
import '../../inventory/domain/ingredient_category.dart';
import '../../recipe/domain/detected_ingredient.dart';
import '../../recipe/service/recipe_provider.dart';

const _uuid = Uuid();

// ──────────────────────────────────────────────────────────────
// UI 用のフェーズ定義
// ──────────────────────────────────────────────────────────────

/// カメラ登録画面が取り得るフェーズ。
enum CameraCapturePhase {
  /// 画像収集前。ドロップゾーン・サムネイルを表示。
  capture,

  /// AI 解析中。パルスアニメーション表示。
  analyzing,

  /// 候補確認。二ペインで候補リスト＋編集ペイン。
  review,

  /// エラー。
  error,
}

// ──────────────────────────────────────────────────────────────
// エラー種別
// ──────────────────────────────────────────────────────────────

/// エラーの分類。UI がメッセージ・導線を分けるために使う。
enum CameraErrorKind {
  /// API キー未登録。
  noApiKey,

  /// 選択プロバイダが Vision に非対応。
  noVision,

  /// ネットワークエラー（API 呼び出し失敗）。
  network,
}

// ──────────────────────────────────────────────────────────────
// UI 用候補エントリ（DetectedIngredient + UI 状態）
// ──────────────────────────────────────────────────────────────

/// 候補確認画面で 1 行分の状態を保持する UI モデル。
class CameraCandidate {
  const CameraCandidate({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.confidence,
    required this.checked,
    this.normalizedName,
  });

  /// 行を一意に識別する内部 ID（UUID）。
  final String id;

  /// 食材名（編集可）。
  final String name;

  /// 数量（編集可）。
  final double quantity;

  /// 単位（編集可）。
  final String unit;

  /// カテゴリ（編集可）。
  final IngredientCategory category;

  /// 確信度 0.0〜1.0。
  final double confidence;

  /// チェックが入っているなら在庫保存対象。
  final bool checked;

  /// AI が返した名寄せキー（あれば）。
  final String? normalizedName;

  /// 確信度のバケット（high/mid/low）。
  /// - high: ≥ 0.75
  /// - mid:  0.4〜0.75
  /// - low:  < 0.4
  String get confidenceBucket {
    if (confidence >= 0.75) return 'high';
    if (confidence >= 0.40) return 'mid';
    return 'low';
  }

  CameraCandidate copyWith({
    String? name,
    double? quantity,
    String? unit,
    IngredientCategory? category,
    bool? checked,
  }) =>
      CameraCandidate(
        id: id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        category: category ?? this.category,
        confidence: confidence,
        checked: checked ?? this.checked,
        normalizedName: normalizedName,
      );
}

// ──────────────────────────────────────────────────────────────
// 画面状態スナップショット
// ──────────────────────────────────────────────────────────────

class CameraCaptureState {
  const CameraCaptureState({
    this.phase = CameraCapturePhase.capture,
    this.images = const [],
    this.candidates = const [],
    this.selectedCandidateId,
    this.errorKind,
    this.showMaxPhotosHint = false,
  });

  final CameraCapturePhase phase;

  /// 縮小済み画像バイト列のリスト。
  final List<Uint8List> images;

  /// AI が検出した候補のリスト（review フェーズで使う）。
  final List<CameraCandidate> candidates;

  /// review ペインで選択中の候補 ID。
  final String? selectedCandidateId;

  /// error フェーズ時のエラー種別。
  final CameraErrorKind? errorKind;

  /// 10枚上限を超えた際のヒントを表示するか。
  final bool showMaxPhotosHint;

  /// チェックが入った候補の数。
  int get checkedCount =>
      candidates.where((c) => c.checked).length;

  CameraCaptureState copyWith({
    CameraCapturePhase? phase,
    List<Uint8List>? images,
    List<CameraCandidate>? candidates,
    String? selectedCandidateId,
    CameraErrorKind? errorKind,
    bool? showMaxPhotosHint,
    bool clearError = false,
    bool clearSelectedCandidate = false,
  }) =>
      CameraCaptureState(
        phase: phase ?? this.phase,
        images: images ?? this.images,
        candidates: candidates ?? this.candidates,
        selectedCandidateId: clearSelectedCandidate
            ? null
            : (selectedCandidateId ?? this.selectedCandidateId),
        errorKind: clearError ? null : (errorKind ?? this.errorKind),
        showMaxPhotosHint: showMaxPhotosHint ?? this.showMaxPhotosHint,
      );
}

// ──────────────────────────────────────────────────────────────
// 画像縮小ユーティリティ
// ──────────────────────────────────────────────────────────────

/// 長辺を [maxSide] に収める縮小 + JPEG エンコードを行う。
/// 元の画像が [maxSide] 以下であっても JPEG 再エンコードは行う（品質統一のため）。
Uint8List _resizeToJpeg(Uint8List src, {int maxSide = 1024, int quality = 80}) {
  final decoded = img.decodeImage(src);
  if (decoded == null) return src;

  img.Image resized;
  if (decoded.width > maxSide || decoded.height > maxSide) {
    resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxSide : null,
      height: decoded.height > decoded.width ? maxSide : null,
      maintainAspect: true,
    );
  } else {
    resized = decoded;
  }

  final encoded = img.encodeJpg(resized, quality: quality);
  return Uint8List.fromList(encoded);
}

/// DetectedIngredient から UI 用カテゴリを推測するヒューリスティック。
/// AI は name だけ返すため、カテゴリは other で初期化し UI で変更可能にする。
IngredientCategory _guessCategory(String name) {
  // 将来的には AI が category を返すフィールドを追加しても良い。現状は other 固定。
  return IngredientCategory.other;
}

// ──────────────────────────────────────────────────────────────
// コントローラ
// ──────────────────────────────────────────────────────────────

class CameraCaptureController extends Notifier<CameraCaptureState> {
  @override
  CameraCaptureState build() => const CameraCaptureState();

  // ---- 画像操作 ----

  /// 画像を追加する。縮小処理はここで実施。最大 10 枚上限を超えた分は無視する。
  Future<void> addImages(List<Uint8List> rawImages) async {
    final current = state.images;
    final capacity = 10 - current.length;
    if (capacity <= 0) {
      state = state.copyWith(showMaxPhotosHint: true);
      return;
    }

    final bool exceeded = rawImages.length > capacity;
    final toAdd = rawImages.take(capacity).toList();

    // 縮小処理（同期だが I/O なし: image パッケージは純 Dart）。
    final resized = toAdd.map((b) => _resizeToJpeg(b)).toList();

    state = state.copyWith(
      images: [...current, ...resized],
      showMaxPhotosHint: exceeded,
    );
  }

  /// 指定インデックスの画像を削除する。
  void removeImage(int index) {
    final images = [...state.images];
    if (index < 0 || index >= images.length) return;
    images.removeAt(index);
    state = state.copyWith(images: images, showMaxPhotosHint: false);
  }

  // ---- 解析実行 ----

  /// 選択中の画像を AI で解析し、候補確認フェーズへ遷移する。
  Future<void> analyze() async {
    if (state.images.isEmpty) return;

    state = state.copyWith(phase: CameraCapturePhase.analyzing);

    try {
      // RecipeProvider を解決する。
      final recipeProvider = await ref.read(recipeProviderProvider.future);
      if (recipeProvider == null) {
        state = state.copyWith(
          phase: CameraCapturePhase.error,
          errorKind: CameraErrorKind.noApiKey,
          clearError: false,
        );
        return;
      }
      if (!recipeProvider.supportsVision) {
        state = state.copyWith(
          phase: CameraCapturePhase.error,
          errorKind: CameraErrorKind.noVision,
          clearError: false,
        );
        return;
      }

      final detected = await recipeProvider.recognizeIngredients(state.images);
      final candidates = _toCandidates(detected);

      // 先頭を初期選択にする。
      final firstId = candidates.isEmpty ? null : candidates.first.id;

      state = state.copyWith(
        phase: CameraCapturePhase.review,
        candidates: candidates,
        selectedCandidateId: firstId,
        clearError: true,
      );
    } on RecipeProviderException {
      state = state.copyWith(
        phase: CameraCapturePhase.error,
        errorKind: CameraErrorKind.network,
        clearError: false,
      );
    } catch (_) {
      state = state.copyWith(
        phase: CameraCapturePhase.error,
        errorKind: CameraErrorKind.network,
        clearError: false,
      );
    }
  }

  List<CameraCandidate> _toCandidates(List<DetectedIngredient> detected) {
    return detected.map((d) {
      // low 確信度（< 0.4）は初期チェック OFF。
      final checked = d.confidence >= 0.40;
      return CameraCandidate(
        id: _uuid.v4(),
        name: d.name,
        quantity: d.estimatedQuantity,
        unit: d.unit,
        category: _guessCategory(d.name),
        confidence: d.confidence,
        checked: checked,
      );
    }).toList();
  }

  // ---- 候補操作 ----

  /// 選択する候補を切り替える。
  void selectCandidate(String id) {
    state = state.copyWith(selectedCandidateId: id);
  }

  /// 候補のチェック状態をトグルする。
  void toggleCandidate(String id) {
    state = state.copyWith(
      candidates: state.candidates
          .map((c) => c.id == id ? c.copyWith(checked: !c.checked) : c)
          .toList(),
    );
  }

  /// 候補の名前・数量・単位・カテゴリを更新する。
  void updateCandidate({
    required String id,
    String? name,
    double? quantity,
    String? unit,
    IngredientCategory? category,
  }) {
    state = state.copyWith(
      candidates: state.candidates
          .map((c) => c.id == id
              ? c.copyWith(
                  name: name,
                  quantity: quantity,
                  unit: unit,
                  category: category,
                )
              : c)
          .toList(),
    );
  }

  // ---- 確定して在庫保存 ----

  /// チェックが入った候補を在庫に保存し、capture フェーズへ戻す。
  Future<void> confirm() async {
    final checked = state.candidates.where((c) => c.checked).toList();
    if (checked.isEmpty) {
      _resetToCapture();
      return;
    }

    final repo = ref.read(inventoryRepositoryProvider);
    final table = ref.read(shelfLifeTableProvider);
    final now = DateTime.now();

    for (final c in checked) {
      final category = c.category;
      final expiry = expiryFromName(table, c.name, category, now);
      final ingredient = Ingredient(
        id: _uuid.v4(),
        name: c.name,
        // AI が normalizedName を返した場合はそれを使い、なければ name を流用する。
        normalizedName: c.normalizedName ?? c.name,
        category: category,
        quantity: c.quantity,
        unit: c.unit,
        expiryDate: expiry,
        updatedAt: now,
      );
      await repo.save(ingredient);
    }

    _resetToCapture();
  }

  void _resetToCapture() {
    state = const CameraCaptureState(phase: CameraCapturePhase.capture);
  }

  // ---- リセット ----

  /// capture フェーズへ戻す（エラーからのリトライ等）。
  void reset() => _resetToCapture();

  // ---- 確信度ヒント非表示 ----
  void dismissMaxPhotosHint() {
    state = state.copyWith(showMaxPhotosHint: false);
  }
}

final cameraCaptureControllerProvider =
    NotifierProvider<CameraCaptureController, CameraCaptureState>(
  CameraCaptureController.new,
);
