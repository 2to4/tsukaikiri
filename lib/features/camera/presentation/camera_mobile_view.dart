// camera_mobile_view.dart
// カメラ登録画面（M6）モバイル（狭い幅）ビュー。
//
// camera.jsx（スマホ版）を Flutter で再現した全画面（Navigator.push で開く）。
// 状態はすべて [cameraCaptureControllerProvider] を再利用し、この view は
// 表示とイベント転送のみを行う（ロジックの複製は禁止）。
//
// フェーズ（CameraCapturePhase）:
//   capture   : 写真追加 + サムネイル + 解析ボタン
//   analyzing : パルスアイコン + 進捗バー（無限アニメーション）
//   review    : 候補リスト（カード展開で編集）
//   error     : エラーメッセージ + 再試行 / あとで解析
//
// 画像入力は当面 file_selector（デスクトップ版と同じ openFiles パターン）。
// 実機カメラ（image_picker）は iOS フェーズで [_pickImages] を差し替える。

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mobile_nav_buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/domain/category_style.dart';
import '../../inventory/domain/ingredient_category.dart';
import '../../recipe/presentation/ai_unavailable_notice.dart';
import '../../settings/presentation/settings_screen.dart';
import 'camera_capture_controller.dart';

// ──────────────────────────────────────────────────────────────
// 確信度カラー定義（デスクトップ版と同じマッピング）
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
// 画像取得（差し替えポイント）
//
// 当面は file_selector の openFiles を使う。iOS フェーズで image_picker による
// カメラ撮影に差し替える際は、この関数だけを書き換えれば良い。
// ──────────────────────────────────────────────────────────────

Future<List<Uint8List>> _pickImages() async {
  const typeGroup = XTypeGroup(
    label: 'image',
    extensions: ['jpg', 'jpeg', 'png', 'heic', 'webp'],
  );
  final files = await openFiles(acceptedTypeGroups: [typeGroup]);
  final bytes = <Uint8List>[];
  for (final f in files) {
    final b = await f.readAsBytes();
    bytes.add(Uint8List.fromList(b));
  }
  return bytes;
}

// ──────────────────────────────────────────────────────────────
// メイン画面
// ──────────────────────────────────────────────────────────────

/// モバイル（狭い幅）のカメラ登録画面（Navigator.push で開く全画面）。
///
/// コントローラはアプリ生存期間で状態を保持するため、capture/review の
/// 途中状態は再入時に再開できる（撮影済み写真・編集中の候補を失わない）。
/// error だけは過去のエラー画面を再表示しても意味がないため入場時にリセットする。
class CameraMobileScreen extends ConsumerStatefulWidget {
  const CameraMobileScreen({super.key});

  @override
  ConsumerState<CameraMobileScreen> createState() =>
      _CameraMobileScreenState();
}

class _CameraMobileScreenState extends ConsumerState<CameraMobileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // 設定で「途中状態を保持しない」なら入場時に常にリセットする。
      // 保持する設定でも error フェーズだけはリセット（過去のエラー残留を防ぐ）。
      final settings = await ref.read(settingsRepositoryProvider).get();
      if (!mounted) return;
      final phase = ref.read(cameraCaptureControllerProvider).phase;
      if (!settings.cameraPreserveState ||
          phase == CameraCapturePhase.error) {
        ref.read(cameraCaptureControllerProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(cameraCaptureControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: switch (st.phase) {
          CameraCapturePhase.capture => _CaptureView(state: st),
          CameraCapturePhase.analyzing => const _AnalyzingView(),
          CameraCapturePhase.review => _ReviewView(state: st),
          CameraCapturePhase.error => _ErrorView(state: st),
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ヘルパー
// ──────────────────────────────────────────────────────────────


// ──────────────────────────────────────────────────────────────
// 1. capture（写真追加 + サムネイル + 解析ボタン）
// ──────────────────────────────────────────────────────────────
class _CaptureView extends ConsumerWidget {
  const _CaptureView({required this.state});
  final CameraCaptureState state;

  Future<void> _addPhotos(WidgetRef ref) async {
    final bytes = await _pickImages();
    if (bytes.isEmpty) return;
    await ref.read(cameraCaptureControllerProvider.notifier).addImages(bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final photos = state.images;
    final full = photos.length >= 10;
    final aiAvailable = ref.watch(aiAvailableProvider).maybeWhen(data: (v) => v, orElse: () => true);

    // AI 非対応端末（オンデバイス不可かつキー未登録）ではカメラ登録を無効化し案内。
    // 戻るボタン（ヘッダー）は残す。
    if (!aiAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const MobileNavBackButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.cameraMobileCaptureTitle,
                      style: brandTextStyle(fontSize: 22, height: 1.1)),
                ),
              ],
            ),
          ),
          const Expanded(child: AiUnavailableNotice()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ヘッダー（戻る + タイトル） ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const MobileNavBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.cameraMobileCaptureTitle,
                    style: brandTextStyle(fontSize: 22, height: 1.1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── ビューファインダー風プレースホルダ（タップで写真追加） ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: GestureDetector(
              onTap: full ? null : () => _addPhotos(ref),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1916),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.photo_camera_outlined,
                                size: 28,
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.cameraDropZoneBody,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                    // 枚数チップ
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.cameraMobilePhotoCount(photos.length),
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── サムネイル列（横スクロール、タップで削除） ──
        if (photos.isNotEmpty)
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, i) => _ThumbnailChip(
                bytes: photos[i],
                onRemove: () => ref
                    .read(cameraCaptureControllerProvider.notifier)
                    .removeImage(i),
              ),
            ),
          ),
        // ── 上限ヒント ──
        if (state.showMaxPhotosHint)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              l10n.cameraMaxPhotosHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.near),
            ),
          ),
        // ── 操作（写真を追加 + 解析する） ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  icon: Icons.add_a_photo_outlined,
                  label: l10n.cameraMobileAddPhotos,
                  onTap: full ? null : () => _addPhotos(ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryButton(
                  icon: Icons.auto_awesome,
                  label: l10n.cameraMobileAnalyzeButton(photos.length),
                  onTap: photos.isEmpty
                      ? null
                      : () => ref
                          .read(cameraCaptureControllerProvider.notifier)
                          .analyze(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// サムネイルチップ（54px 角丸12、タップで削除）。
class _ThumbnailChip extends StatelessWidget {
  const _ThumbnailChip({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stk) => Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.photo_camera_outlined,
                    size: 22, color: AppColors.green),
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 2. analyzing（パルスアイコン + 進捗バー）
// 注意: 無限アニメーションをこのウィジェット内に閉じ込め、遷移時に破棄する。
// ──────────────────────────────────────────────────────────────
class _AnalyzingView extends StatefulWidget {
  const _AnalyzingView();

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseCtrl),
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child:
                    const Icon(Icons.auto_awesome, size: 42, color: AppColors.green),
              ),
            ),
            const SizedBox(height: 18),
            Text(l10n.cameraAnalyzingTitle, style: brandTextStyle(fontSize: 21)),
            const SizedBox(height: 8),
            Text(
              l10n.cameraAnalyzingBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 200,
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: AnimatedBuilder(
                  animation: _barCtrl,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _barCtrl.value * 0.97,
                    backgroundColor: AppColors.line,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.green),
                  ),
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
// 3. review（候補リスト + カード展開で編集 + 確定）
// ──────────────────────────────────────────────────────────────
class _ReviewView extends ConsumerWidget {
  const _ReviewView({required this.state});
  final CameraCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final candidates = state.candidates;
    final chosen = state.checkedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ヘッダー ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const MobileNavBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.cameraMobileReviewTitle,
                        style: brandTextStyle(fontSize: 22, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.cameraMobileReviewSummary(candidates.length, chosen),
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── 案内バナー ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tune, size: 18, color: AppColors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.cameraMobileReviewHint,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sub,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── 候補カード一覧 ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: candidates.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == candidates.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.cameraMobileReviewFootnote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.faint),
                  ),
                );
              }
              return _CandidateCard(candidate: candidates[i]);
            },
          ),
        ),
        // ── 確定ボタン ──
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _PrimaryWideButton(
              icon: Icons.check,
              label: l10n.cameraConfirmButton(chosen),
              onTap: chosen == 0
                  ? null
                  : () async {
                      await ref
                          .read(cameraCaptureControllerProvider.notifier)
                          .confirm();
                      if (context.mounted) {
                        Navigator.of(context).maybePop();
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 候補カード（タップで展開して名前・数量・単位・カテゴリを編集）
// ──────────────────────────────────────────────────────────────
class _CandidateCard extends ConsumerStatefulWidget {
  const _CandidateCard({required this.candidate});
  final CameraCandidate candidate;

  @override
  ConsumerState<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends ConsumerState<_CandidateCard> {
  bool _expanded = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _unitCtrl;
  String? _syncedId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.candidate.name);
    _unitCtrl = TextEditingController(text: widget.candidate.unit);
    _syncedId = widget.candidate.id;
  }

  @override
  void didUpdateWidget(_CandidateCard old) {
    super.didUpdateWidget(old);
    // 別候補に差し替わった場合のみテキストを同期する（編集中の上書きを避ける）。
    if (widget.candidate.id != _syncedId) {
      _nameCtrl.text = widget.candidate.name;
      _unitCtrl.text = widget.candidate.unit;
      _syncedId = widget.candidate.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _commitText() {
    final c = widget.candidate;
    ref.read(cameraCaptureControllerProvider.notifier).updateCandidate(
          id: c.id,
          name: _nameCtrl.text.trim().isEmpty ? c.name : _nameCtrl.text.trim(),
          unit: _unitCtrl.text.trim().isEmpty ? c.unit : _unitCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.candidate;
    final notifier = ref.read(cameraCaptureControllerProvider.notifier);
    final bucket = c.confidenceBucket;
    final isLow = bucket == 'low';
    final dim = isLow && !c.checked;

    return Container(
      decoration: BoxDecoration(
        color: dim ? const Color(0xFFFBFAF7) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A282723), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: dim ? 0.82 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ヘッダー行（チェック・絵文字・名前・確信度・展開） ──
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: Row(
                children: [
                  _Check(
                    on: c.checked,
                    onTap: () => notifier.toggleCandidate(c.id),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.plentySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(c.category.style.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_expanded) _commitText();
                        setState(() => _expanded = !_expanded);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _ConfBadge(bucket: bucket),
                              const SizedBox(width: 8),
                              Text(
                                c.category.label(l10n),
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.sub),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.expand_more,
                          size: 22, color: AppColors.faint),
                    ),
                    onPressed: () {
                      if (_expanded) _commitText();
                      setState(() => _expanded = !_expanded);
                    },
                  ),
                ],
              ),
            ),
            // ── 展開部（名前・数量・単位・カテゴリ編集） ──
            if (_expanded) ...[
              const Divider(height: 1, color: AppColors.line),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EditField(
                      label: l10n.cameraEditNameLabel,
                      child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink),
                        decoration: _fieldDecoration(),
                        onSubmitted: (_) => _commitText(),
                        onTapOutside: (_) => _commitText(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // 数量ステッパー
                        Text(l10n.cameraEditQtyLabel,
                            style: _labelStyle()),
                        const SizedBox(width: 10),
                        _QtyStepper(
                          qty: c.quantity,
                          onDecrement: () => notifier.updateCandidate(
                            id: c.id,
                            quantity: (c.quantity - 1).clamp(1, 999).toDouble(),
                          ),
                          onIncrement: () => notifier.updateCandidate(
                            id: c.id,
                            quantity: c.quantity + 1,
                          ),
                        ),
                        const Spacer(),
                        // 単位
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _unitCtrl,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.green),
                              ),
                            ),
                            onSubmitted: (_) => _commitText(),
                            onTapOutside: (_) => _commitText(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // カテゴリ選択
                    Row(
                      children: [
                        Text(l10n.cameraEditCategoryLabel,
                            style: _labelStyle()),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<IngredientCategory>(
                                value: c.category,
                                isDense: true,
                                borderRadius: BorderRadius.circular(12),
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink),
                                onChanged: (cat) {
                                  if (cat == null) return;
                                  notifier.updateCandidate(
                                      id: c.id, category: cat);
                                },
                                items: IngredientCategory.values
                                    .map(
                                      (cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(
                                          '${cat.style.emoji} ${cat.label(l10n)}',
                                          style: const TextStyle(fontSize: 13.5),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.sub,
      );

  InputDecoration _fieldDecoration() => InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green),
        ),
      );
}

/// 確信度バッジ。
class _ConfBadge extends StatelessWidget {
  const _ConfBadge({required this.bucket});
  final String bucket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (bucket) {
      'high' => l10n.cameraConfHighLabel,
      'mid' => l10n.cameraConfMidLabel,
      _ => l10n.cameraConfLowLabel,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _confBg[bucket] ?? AppColors.plentySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _confFg[bucket] ?? AppColors.faint),
      ),
    );
  }
}

/// 緑チェックボタン（shopping_mobile_view と同じ作法）。
class _Check extends StatelessWidget {
  const _Check({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: on ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: on ? null : Border.all(color: AppColors.line, width: 2),
        ),
        alignment: Alignment.center,
        child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
    );
  }
}

/// 数量 ± ステッパー。
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });
  final double qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final text = qty == qty.truncate()
        ? qty.toStringAsFixed(0)
        : qty.toStringAsFixed(1);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.plentySoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 36,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 36,
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}

/// 編集フィールド（ラベル + 入力）。
class _EditField extends StatelessWidget {
  const _EditField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.sub),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 4. error（メッセージ + 再試行 / あとで解析 / 設定導線）
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
    final icon = switch (kind) {
      CameraErrorKind.noApiKey => Icons.key_off_outlined,
      CameraErrorKind.noVision => Icons.visibility_off_outlined,
      CameraErrorKind.network => Icons.wifi_off_outlined,
    };
    final isConfig =
        kind == CameraErrorKind.noApiKey || kind == CameraErrorKind.noVision;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.nearSoft,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 44, color: AppColors.near),
                  ),
                  const SizedBox(height: 18),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: brandTextStyle(fontSize: 21)),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sub,
                        height: 1.7),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _PrimaryWideButton(
                  icon: Icons.refresh,
                  label: l10n.cameraErrorRetry,
                  onTap: () => ref
                      .read(cameraCaptureControllerProvider.notifier)
                      .reset(),
                ),
                const SizedBox(height: 12),
                // noApiKey / noVision は設定導線、network は「あとで解析」（戻る）。
                _SecondaryWideButton(
                  label: isConfig
                      ? l10n.cameraErrorOpenSettings
                      : l10n.cameraMobileErrorLater,
                  onTap: () {
                    if (isConfig) {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ));
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通ボタン部品
// ──────────────────────────────────────────────────────────────

/// プライマリボタン（緑背景・コンパクト）。
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.green : const Color(0xFFD8D4CB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// セカンダリボタン（白背景・ボーダー・コンパクト）。
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled ? AppColors.ink : AppColors.faint;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 19),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// プライマリワイドボタン（確定・再試行用）。
class _PrimaryWideButton extends StatelessWidget {
  const _PrimaryWideButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.green : const Color(0xFFD8D4CB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// セカンダリワイドボタン。
class _SecondaryWideButton extends StatelessWidget {
  const _SecondaryWideButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
        ),
      ),
    );
  }
}
