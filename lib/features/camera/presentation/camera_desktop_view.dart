// camera_desktop_view.dart
// カメラ登録画面（M6）macOS デスクトップビュー。
// macosApp.jsx の CameraScreen を Flutter で忠実に再現する。
//
// ■ フェーズ
//   capture   : ドロップゾーン + サムネイル + 解析ボタン
//   analyzing : パルスアイコン + 進捗バー（無限アニメーション）
//   review    : 二ペイン（候補リスト | 編集ペイン）
//   error     : エラーメッセージ + 再試行ボタン

import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/domain/category_style.dart';
import '../../inventory/domain/ingredient_category.dart';
import '../../recipe/presentation/ai_unavailable_notice.dart';
import '../../shell/presentation/shell_providers.dart';
import 'camera_capture_controller.dart';

// ──────────────────────────────────────────────────────────────
// 確信度カラー定義
// ──────────────────────────────────────────────────────────────

const _confBg = {
  'high': AppColors.greenSoft,
  'mid': AppColors.nearSoft,
  'low': AppColors.plentySoft,
};

const _confFg = {
  'high': AppColors.greenInk,
  'mid': AppColors.near,
  'low': AppColors.faint,
};

// ──────────────────────────────────────────────────────────────
// メインビュー
// ──────────────────────────────────────────────────────────────

/// macOS カメラ登録ビュー（デスクトップシェルの camera セクション）。
class CameraDesktopView extends ConsumerWidget {
  const CameraDesktopView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraCaptureControllerProvider);

    return switch (state.phase) {
      CameraCapturePhase.capture => _CaptureView(state: state),
      CameraCapturePhase.analyzing => const _AnalyzingView(),
      CameraCapturePhase.review => _ReviewView(state: state),
      CameraCapturePhase.error => _ErrorView(state: state),
    };
  }
}

// ──────────────────────────────────────────────────────────────
// capture フェーズ
// ──────────────────────────────────────────────────────────────

class _CaptureView extends ConsumerStatefulWidget {
  const _CaptureView({required this.state});

  final CameraCaptureState state;

  @override
  ConsumerState<_CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends ConsumerState<_CaptureView> {
  bool _dragging = false;

  /// file_selector でファイルを選択して画像を追加する。
  Future<void> _pickFiles() async {
    const typeGroup = XTypeGroup(
      label: '画像',
      extensions: ['jpg', 'jpeg', 'png', 'heic', 'webp'],
    );
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isEmpty) return;

    final bytes = <Uint8List>[];
    for (final f in files) {
      final b = await f.readAsBytes();
      bytes.add(Uint8List.fromList(b));
    }
    if (mounted) {
      await ref
          .read(cameraCaptureControllerProvider.notifier)
          .addImages(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final photos = state.images;
    // カメラ登録は画像認識が要るため vision 対応で入口を出し分ける。
    // オンデバイス AI はテキスト専用（vision 非対応）なので、AI が使えても
    // 画像認識ができない端末では入口を開かず案内する（解析時の必敗を防ぐ）。
    final visionAvailable = ref.watch(cameraEntryEnabledProvider);
    if (!visionAvailable) {
      // AI 自体は使える（vision 非対応）なら、クラウドキー登録を促す専用文言。
      final aiAvailable = ref.watch(aiEntryEnabledProvider);
      return AiUnavailableNotice(
        title: aiAvailable ? l10n.cameraVisionUnavailableTitle : null,
        body: aiAvailable ? l10n.cameraVisionUnavailableBody : null,
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- ドロップゾーン ----
            DropTarget(
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              onDragDone: (detail) async {
                setState(() => _dragging = false);
                final bytes = <Uint8List>[];
                for (final file in detail.files) {
                  try {
                    final b = await file.readAsBytes();
                    bytes.add(Uint8List.fromList(b));
                  } catch (_) {
                    // 読み込めないファイルは無視する。
                  }
                }
                if (bytes.isNotEmpty && mounted) {
                  await ref
                      .read(cameraCaptureControllerProvider.notifier)
                      .addImages(bytes);
                }
              },
              child: GestureDetector(
                onTap: _pickFiles,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: const BoxConstraints(maxWidth: 640),
                    height: 380,
                    decoration: BoxDecoration(
                      color: _dragging ? AppColors.greenSoft : const Color(0xFFFAFAF7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _dragging ? AppColors.green : AppColors.line,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // カメラアイコンタイル 72px
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _dragging ? AppColors.green : AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 32,
                            color: _dragging ? Colors.white : AppColors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ブランドフォント 20px
                        Text(
                          l10n.cameraDropZoneTitle,
                          style: brandTextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ).copyWith(color: AppColors.ink),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.cameraDropZoneBody,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sub,
                          ),
                        ),
                        // サムネイル列
                        if (photos.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < photos.length; i++)
                                _ThumbnailChip(
                                  bytes: photos[i],
                                  onRemove: () => ref
                                      .read(cameraCaptureControllerProvider
                                          .notifier)
                                      .removeImage(i),
                                ),
                            ],
                          ),
                        ],
                        // 解析ボタン（1枚以上で表示）
                        if (photos.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () {
                              // ドロップゾーンのタップ（_pickFiles）と競合しないよう
                              // stopPropagation に相当する処理: ボタン側で処理する。
                            },
                            child: _PrimaryButton(
                              icon: Icons.auto_awesome_outlined,
                              label: l10n.cameraAnalyzeButton(photos.length),
                              onTap: () => ref
                                  .read(cameraCaptureControllerProvider.notifier)
                                  .analyze(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 上限超過ヒント
            if (state.showMaxPhotosHint)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.cameraMaxPhotosHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.near,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// サムネイルチップ（52px 角丸10、タップで削除）
// ──────────────────────────────────────────────────────────────

class _ThumbnailChip extends StatefulWidget {
  const _ThumbnailChip({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  State<_ThumbnailChip> createState() => _ThumbnailChipState();
}

class _ThumbnailChipState extends State<_ThumbnailChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onRemove,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                widget.bytes,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stk) => Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 22,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
            if (_hovered)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// analyzing フェーズ（パルスアニメーション + 進捗バー）
// 注意: 無限アニメーションをこのウィジェット内に完全に閉じ込め、
//       他フェーズに遷移したら確実に破棄する。
// ──────────────────────────────────────────────────────────────

class _AnalyzingView extends StatefulWidget {
  const _AnalyzingView();

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scale;
  late final AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    // パルス: scale 1→1.08→1, 1500ms 無限
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // 進捗バー: 0→97%, 2300ms 無限
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // パルスアイコン
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 38,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cameraAnalyzingTitle,
            style: brandTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ).copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cameraAnalyzingBody,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.sub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // 進捗バー（0→97% をループ）
          SizedBox(
            width: 240,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: AnimatedBuilder(
                animation: _barCtrl,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: _barCtrl.value * 0.97,
                    backgroundColor: AppColors.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// review フェーズ（二ペイン）
// ──────────────────────────────────────────────────────────────

class _ReviewView extends ConsumerWidget {
  const _ReviewView({required this.state});

  final CameraCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final candidates = state.candidates;
    final selectedId = state.selectedCandidateId;
    final selected = candidates.where((c) => c.id == selectedId).firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- 左ペイン: 候補リスト ----
        Expanded(
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cameraReviewHeader(candidates.length),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.faint,
                    letterSpacing: 0.07 * 10.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    return _CandidateRow(
                      candidate: c,
                      selected: c.id == selectedId,
                      onTap: () => ref
                          .read(cameraCaptureControllerProvider.notifier)
                          .selectCandidate(c.id),
                      onToggle: () => ref
                          .read(cameraCaptureControllerProvider.notifier)
                          .toggleCandidate(c.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // 区切り線
        const VerticalDivider(width: 1, thickness: 1),
        // ---- 右ペイン: 編集 ----
        SizedBox(
          width: 380,
          child: _EditPane(
            selected: selected,
            checkedCount: state.checkedCount,
            onConfirm: () async {
              await ref
                  .read(cameraCaptureControllerProvider.notifier)
                  .confirm();
              // 在庫セクションへ遷移する。
              if (context.mounted) {
                ref
                    .read(shellSectionProvider.notifier)
                    .select(ShellSection.inventory);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 候補リスト行
// ──────────────────────────────────────────────────────────────

class _CandidateRow extends StatefulWidget {
  const _CandidateRow({
    required this.candidate,
    required this.selected,
    required this.onTap,
    required this.onToggle,
  });

  final CameraCandidate candidate;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  State<_CandidateRow> createState() => _CandidateRowState();
}

class _CandidateRowState extends State<_CandidateRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.candidate;
    final bucket = c.confidenceBucket;
    final isLow = bucket == 'low';

    final confLabel = switch (bucket) {
      'high' => l10n.cameraConfHighLabel,
      'mid' => l10n.cameraConfMidLabel,
      _ => l10n.cameraConfLowLabel,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: isLow ? 0.6 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            color: widget.selected
                ? const Color(0xFFEDF5F1)
                : _hovered
                    ? const Color(0x08282723)
                    : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              children: [
                // チェックボックス
                GestureDetector(
                  onTap: widget.onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: c.checked,
                        onChanged: (_) => widget.onToggle(),
                        activeColor: AppColors.green,
                        side: const BorderSide(
                          color: AppColors.line,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // 絵文字
                Text(
                  c.category.style.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                // 名前 + カテゴリ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        c.category.label(AppLocalizations.of(context)),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sub,
                        ),
                      ),
                    ],
                  ),
                ),
                // 確信度バッジ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _confBg[bucket] ?? AppColors.plentySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    confLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _confFg[bucket] ?? AppColors.faint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 右ペイン: 編集フォーム + 確定ボタン
// ──────────────────────────────────────────────────────────────

class _EditPane extends ConsumerStatefulWidget {
  const _EditPane({
    required this.selected,
    required this.checkedCount,
    required this.onConfirm,
  });

  final CameraCandidate? selected;
  final int checkedCount;
  final VoidCallback onConfirm;

  @override
  ConsumerState<_EditPane> createState() => _EditPaneState();
}

class _EditPaneState extends ConsumerState<_EditPane> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _unitCtrl;

  /// 現在表示中の候補 ID（変化を検出して再初期化する）。
  String? _currentId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _qtyCtrl = TextEditingController();
    _unitCtrl = TextEditingController();
    _syncFields(widget.selected);
    _currentId = widget.selected?.id;
  }

  @override
  void didUpdateWidget(_EditPane old) {
    super.didUpdateWidget(old);
    if (widget.selected?.id != _currentId) {
      _syncFields(widget.selected);
      _currentId = widget.selected?.id;
    }
  }

  void _syncFields(CameraCandidate? c) {
    if (c == null) return;
    _nameCtrl.text = c.name;
    _qtyCtrl.text = c.quantity.toStringAsFixed(
      c.quantity == c.quantity.truncate() ? 0 : 1,
    );
    _unitCtrl.text = c.unit;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final sel = widget.selected;
    if (sel == null) return;
    ref.read(cameraCaptureControllerProvider.notifier).updateCandidate(
          id: sel.id,
          name: _nameCtrl.text.trim().isEmpty ? sel.name : _nameCtrl.text.trim(),
          quantity: double.tryParse(_qtyCtrl.text.trim()) ?? sel.quantity,
          unit: _unitCtrl.text.trim().isEmpty ? sel.unit : _unitCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sel = widget.selected;

    if (sel == null) {
      return const SizedBox.shrink();
    }

    final bucket = sel.confidenceBucket;
    final confLabel = switch (bucket) {
      'high' => l10n.cameraConfHighLabel,
      'mid' => l10n.cameraConfMidLabel,
      _ => l10n.cameraConfLowLabel,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ヘッダー: 絵文字 + 名前 + 確信度バッジ
          Column(
            children: [
              Text(
                sel.category.style.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 6),
              Text(
                sel.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _confBg[bucket] ?? AppColors.plentySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  confLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _confFg[bucket] ?? AppColors.faint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 編集フィールド群
          _FormField(
            label: l10n.cameraEditNameLabel,
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _commit(),
              onTapOutside: (_) => _commit(),
            ),
          ),
          _FormField(
            label: l10n.cameraEditQtyLabel,
            child: TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _commit(),
              onTapOutside: (_) => _commit(),
            ),
          ),
          _FormField(
            label: l10n.cameraEditUnitLabel,
            child: TextField(
              controller: _unitCtrl,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _commit(),
              onTapOutside: (_) => _commit(),
            ),
          ),
          // カテゴリ選択
          _FormField(
            label: l10n.cameraEditCategoryLabel,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<IngredientCategory>(
                value: sel.category,
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                onChanged: (cat) {
                  if (cat == null) return;
                  ref
                      .read(cameraCaptureControllerProvider.notifier)
                      .updateCandidate(id: sel.id, category: cat);
                },
                items: IngredientCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          '${c.style.emoji} ${c.label(l10n)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // 確定して追加ボタン
          SizedBox(
            width: double.infinity,
            child: _PrimaryButton(
              icon: Icons.check_rounded,
              label: l10n.cameraConfirmButton(widget.checkedCount),
              onTap: widget.checkedCount > 0 ? widget.onConfirm : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// フォームフィールド共通
// ──────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.sub,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// error フェーズ
// ──────────────────────────────────────────────────────────────

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.state});

  final CameraCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final kind = state.errorKind ?? CameraErrorKind.network;

    final title = switch (kind) {
      CameraErrorKind.noApiKey => l10n.cameraErrorNoApiKeyTitle,
      CameraErrorKind.noVision => l10n.cameraErrorNoVisionTitle,
      CameraErrorKind.network => l10n.cameraErrorNetworkTitle,
    };

    final body = switch (kind) {
      CameraErrorKind.noApiKey => l10n.cameraErrorNoApiKeyBody,
      CameraErrorKind.noVision => l10n.cameraErrorNoVisionBody,
      CameraErrorKind.network => l10n.cameraErrorNetworkBody,
    };

    return Center(
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.overSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 36,
                color: AppColors.over,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: brandTextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ).copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 再試行ボタン（全フェーズで表示）
                _PrimaryButton(
                  icon: Icons.refresh_rounded,
                  label: l10n.cameraErrorRetry,
                  onTap: () => ref
                      .read(cameraCaptureControllerProvider.notifier)
                      .reset(),
                ),
                // 設定を開くボタン（noApiKey / noVision のみ）
                if (kind == CameraErrorKind.noApiKey ||
                    kind == CameraErrorKind.noVision) ...[
                  const SizedBox(width: 10),
                  _SecondaryButton(
                    icon: Icons.settings_outlined,
                    label: l10n.cameraErrorOpenSettings,
                    onTap: () => ref
                        .read(shellSectionProvider.notifier)
                        .select(ShellSection.settings),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ボタン部品
// ──────────────────────────────────────────────────────────────

/// プライマリボタン（緑背景）。
class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: enabled
                ? (_hovered
                    ? AppColors.greenInk
                    : AppColors.green)
                : AppColors.line,
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled && _hovered
                ? const [
                    BoxShadow(
                      color: Color(0x4C1F7A55),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: enabled ? Colors.white : AppColors.sub),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : AppColors.sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// セカンダリボタン（白背景・ボーダー）。
class _SecondaryButton extends StatefulWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0x0D282723) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: AppColors.ink),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
