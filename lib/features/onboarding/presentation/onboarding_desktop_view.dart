// オンボーディング（設定アシスタント）6ステップビュー。
// macosOnboarding.jsx の StepRail / MacWelcome / MacAIStep / MacLinkStep /
// MacListStep / MacApplianceStep / MacFinish を Flutter で再現する。
// M3 の設定ビュー（_ProviderGrid / _ApiKeyCard / _ApplianceCard 等）の
// 部品を最大限再利用し、重複実装を避ける。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/recipe/service/recipe_provider_factory.dart';
import '../../../features/settings/domain/appliance.dart';
import '../../../features/shell/presentation/shell_providers.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────
// 定数
// ─────────────────────────────────────────────────────────────

/// ステップレール幅（macosOnboarding.jsx に合わせて 220px）。
const double _kRailWidth = 220.0;

/// 各 AI プロバイダのキー取得ページ URL（設定画面と同じ経路）。
const _keyUrls = <String, String>{
  'gemini': 'https://aistudio.google.com/apikey',
  'grok': 'https://console.x.ai',
  'openai': 'https://platform.openai.com/api-keys',
  'claude': 'https://console.anthropic.com/settings/keys',
};

// ─────────────────────────────────────────────────────────────
// オンボーディングルートビュー
// ─────────────────────────────────────────────────────────────

/// macOS 用 設定アシスタント（6ステップ）。
///
/// シェルの onboarding セクションに埋め込む。
/// ステップ状態は StatefulWidget の state で管理し、
/// シェル離脱で先頭に戻る（ProviderScope を共有するため保存操作は
/// 既存リポジトリ / SecureStorage を直接使用）。
class OnboardingDesktopView extends ConsumerStatefulWidget {
  const OnboardingDesktopView({super.key});

  @override
  ConsumerState<OnboardingDesktopView> createState() =>
      _OnboardingDesktopViewState();
}

class _OnboardingDesktopViewState
    extends ConsumerState<OnboardingDesktopView> {
  int _step = 0;

  void _next() => setState(() => _step = (_step + 1).clamp(0, 5));
  void _back() => setState(() => _step = (_step - 1).clamp(0, 5));

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 左: ステップレール ──
        _StepRail(current: _step),
        // ── 右: ステップコンテンツ ──
        Expanded(
          child: _buildStep(),
        ),
      ],
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _WelcomeStep(onNext: _next),
      1 => _AiStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      2 => _LinkStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      3 => _ListStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      4 => _ApplianceStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      _ => _FinishStep(
          onStart: () {
            // 完了 → 在庫セクションへ
            ref
                .read(shellSectionProvider.notifier)
                .select(ShellSection.inventory);
          },
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────
// ステップレール（左ペイン）
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の StepRail を再現。
/// 緑グラデーション背景・現在地ハイライト・完了ステップにチェック。
class _StepRail extends StatelessWidget {
  const _StepRail({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.onboardingStep0,
      l10n.onboardingStep1,
      l10n.onboardingStep2,
      l10n.onboardingStep3,
      l10n.onboardingStep4,
      l10n.onboardingStep5,
    ];

    return Container(
      width: _kRailWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A5C36), Color(0xFF145030)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 28, 14, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 22),
            child: Text(
              l10n.onboardingRailTitle,
              style: brandTextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // ステップ一覧
          for (var i = 0; i < steps.length; i++) ...[
            _RailItem(
              index: i,
              label: steps[i],
              state: i < current
                  ? _RailItemState.done
                  : i == current
                      ? _RailItemState.active
                      : _RailItemState.upcoming,
            ),
            const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }
}

enum _RailItemState { done, active, upcoming }

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.index,
    required this.label,
    required this.state,
  });

  final int index;
  final String label;
  final _RailItemState state;

  @override
  Widget build(BuildContext context) {
    final active = state == _RailItemState.active;
    final done = state == _RailItemState.done;

    // バッジ色
    final badgeBorder = done
        ? AppColors.green
        : active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.3);
    final badgeBg = done ? AppColors.green : Colors.transparent;

    // テキスト色
    final textColor = active
        ? Colors.white
        : done
            ? Colors.white.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 番号 / チェックバッジ
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeBg,
              border: Border.all(color: badgeBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // ラベル
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 共通コンテンツコンテナ（MacOBContent）
// ─────────────────────────────────────────────────────────────

/// 各ステップの共通レイアウト。
/// スクロール可能な上部コンテンツ + 固定フッターボタン行。
class _OBContent extends StatelessWidget {
  const _OBContent({
    required this.title,
    required this.child,
    this.sub,
    this.skipLabel,
    this.onSkip,
    required this.onPrimary,
    this.onBack,
    this.maxWidth = 480.0,
  });

  final String title;
  final String? sub;
  final Widget child;
  final String? skipLabel;
  final VoidCallback? onSkip;
  final VoidCallback onPrimary;
  final VoidCallback? onBack;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // スクロール可能上部
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(44, 32, 44, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: brandTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        sub!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.sub,
                          height: 1.75,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
        // フッターボタン行
        Container(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line, width: 1)),
          ),
          child: Row(
            children: [
              // 左: 戻る + スキップ
              if (onBack != null)
                _OBTextButton(
                  label: l10n.onboardingBack,
                  onTap: onBack!,
                ),
              if (skipLabel != null && onSkip != null) ...[
                if (onBack != null) const SizedBox(width: 8),
                _OBSkipButton(label: skipLabel!, onTap: onSkip!),
              ],
              const Spacer(),
              // 右: 次へ
              _OBPrimaryButton(
                label: l10n.onboardingNext,
                onTap: onPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// フッターボタン群
// ─────────────────────────────────────────────────────────────

class _OBPrimaryButton extends StatefulWidget {
  const _OBPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_OBPrimaryButton> createState() => _OBPrimaryButtonState();
}

class _OBPrimaryButtonState extends State<_OBPrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.greenInk : AppColors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OBTextButton extends StatelessWidget {
  const _OBTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _OBSkipButton extends StatelessWidget {
  const _OBSkipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.faint,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 0: ようこそ
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacWelcome を再現。
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // アプリアイコン
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4D1F7A55),
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🌿', style: TextStyle(fontSize: 46)),
                  ),
                  const SizedBox(height: 22),
                  // タイトル
                  Text(
                    l10n.onboardingWelcomeTitle,
                    style: brandTextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // サブタイトル
                  Text(
                    l10n.onboardingWelcomeSub,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sub,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  // 3つの価値カード
                  Row(
                    children: [
                      _FeatureCard(
                        emoji: '📷',
                        title: l10n.onboardingWelcomeFeature1Title,
                        body: l10n.onboardingWelcomeFeature1Body,
                      ),
                      const SizedBox(width: 12),
                      _FeatureCard(
                        emoji: '🍳',
                        title: l10n.onboardingWelcomeFeature2Title,
                        body: l10n.onboardingWelcomeFeature2Body,
                      ),
                      const SizedBox(width: 12),
                      _FeatureCard(
                        emoji: '🛒',
                        title: l10n.onboardingWelcomeFeature3Title,
                        body: l10n.onboardingWelcomeFeature3Body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // はじめるボタン
                  _OBPrimaryButton(
                    label: l10n.onboardingWelcomeStart,
                    onTap: onNext,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D282723),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              body,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.sub,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 1: AIを選ぶ
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacAIStep を再現。
/// M3 の _ProviderGrid / _ApiKeyCard と同じリポジトリ経路（selectedProvider /
/// SecureStorage）を使い保存する。
class _AiStep extends ConsumerWidget {
  const _AiStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        final selected = settings.selectedProvider;
        return _OBContent(
          title: l10n.onboardingAiTitle,
          sub: l10n.onboardingAiSub,
          skipLabel: l10n.onboardingAiSkip,
          onSkip: onSkip,
          onBack: onBack,
          onPrimary: onNext,
          maxWidth: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // プロバイダカード（M3 の _ProviderGrid を再利用）
              OnboardingProviderGrid(
                selected: selected,
                onSelect: (id) => ref
                    .read(settingsRepositoryProvider)
                    .setSelectedProvider(id),
              ),
              const SizedBox(height: 16),
              // APIキーカード（M3 の _ApiKeyCard を再利用）
              OnboardingApiKeyCard(
                key: ValueKey('ob_apikey_$selected'),
                providerId: selected,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 2: リマインダー連携
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacLinkStep を再現。
/// 「許可する」→ ShoppingListService.getLists() でダイアログを発火する。
class _LinkStep extends ConsumerStatefulWidget {
  const _LinkStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  ConsumerState<_LinkStep> createState() => _LinkStepState();
}

class _LinkStepState extends ConsumerState<_LinkStep> {
  bool _linked = false;
  bool _loading = false;
  String? _error;

  Future<void> _requestAccess() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // getLists() を呼ぶことで macOS のリマインダーアクセスダイアログが発火する。
      await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() {
        _linked = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _error = l10n.onboardingLinkError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _OBContent(
      title: l10n.onboardingLinkTitle,
      sub: l10n.onboardingLinkSub,
      skipLabel: l10n.onboardingLinkSkip,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      onPrimary: widget.onNext,
      maxWidth: 440,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 情報カード
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: l10n.onboardingLinkApp,
                  value: l10n.onboardingLinkAppValue,
                  hasBottomBorder: true,
                ),
                _InfoRow(
                  label: l10n.onboardingLinkAction,
                  value: l10n.onboardingLinkActionValue,
                  hasBottomBorder: true,
                ),
                _InfoRow(
                  label: l10n.onboardingLinkPrivacy,
                  value: l10n.onboardingLinkPrivacyValue,
                  hasBottomBorder: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // エラー表示
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.over,
                ),
              ),
            ),
          // 許可ボタン or 連携完了表示
          if (!_linked)
            _OBGreenOutlineButton(
              icon: Icons.checklist_outlined,
              label: l10n.onboardingLinkButton,
              loading: _loading,
              onTap: _loading ? null : _requestAccess,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 18, color: AppColors.green),
                const SizedBox(width: 9),
                Text(
                  l10n.onboardingLinkDone,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenInk,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.hasBottomBorder,
  });

  final String label;
  final String value;
  final bool hasBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.sub,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _OBGreenOutlineButton extends StatefulWidget {
  const _OBGreenOutlineButton({
    required this.icon,
    required this.label,
    this.loading = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  State<_OBGreenOutlineButton> createState() => _OBGreenOutlineButtonState();
}

class _OBGreenOutlineButtonState extends State<_OBGreenOutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 46,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.greenSoft : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.green,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.green,
                  ),
                )
              else
                Icon(widget.icon, size: 17, color: AppColors.green),
              const SizedBox(width: 9),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.greenInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 3: リストを選ぶ
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacListStep を再現。
/// M3 の _ShoppingSection と同じリポジトリ経路（setShoppingList）で保存。
class _ListStep extends ConsumerStatefulWidget {
  const _ListStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  ConsumerState<_ListStep> createState() => _ListStepState();
}

class _ListStepState extends ConsumerState<_ListStep> {
  bool _loading = false;
  String? _error;
  List<({String id, String name})>? _lists;
  final _newNameController = TextEditingController();

  @override
  void dispose() {
    _newNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rawLists =
          await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() {
        _lists = rawLists.map((l) => (id: l.id, name: l.name)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _error = l10n.onboardingLinkError;
      });
    }
  }

  Future<void> _createList() async {
    final name = _newNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      final created =
          await ref.read(shoppingListServiceProvider).createList(name);
      await ref
          .read(settingsRepositoryProvider)
          .setShoppingList(created.id, created.name);
      _newNameController.clear();
      if (!mounted) return;
      setState(() {
        _lists = [...?_lists, (id: created.id, name: created.name)];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _select(String id, String name) async {
    await ref
        .read(settingsRepositoryProvider)
        .setShoppingList(id, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final currentId = settingsAsync.maybeWhen(
        data: (s) => s.shoppingListId, orElse: () => null);

    return _OBContent(
      title: l10n.onboardingListTitle,
      sub: l10n.onboardingListSub,
      skipLabel: l10n.onboardingListSkip,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      onPrimary: widget.onNext,
      maxWidth: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // リスト読み込みボタン（_lists が null のとき表示）
          if (_lists == null) ...[
            _OBGreenOutlineButton(
              icon: Icons.list_alt_outlined,
              label: _loading
                  ? l10n.onboardingListLoading
                  : l10n.settingsShoppingLoad,
              loading: _loading,
              onTap: _loading ? null : _loadLists,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.over,
                  ),
                ),
              ),
          ],
          // リスト一覧
          if (_lists != null) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < _lists!.length; i++) ...[
                    _ListPickRow(
                      name: _lists![i].name,
                      selected: _lists![i].id == currentId,
                      onTap: () => _select(
                          _lists![i].id, _lists![i].name),
                      hasBottomBorder: i < _lists!.length - 1,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // 新規リスト作成
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newNameController,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: l10n.onboardingListNewName,
                    hintStyle: const TextStyle(
                        fontSize: 13, color: AppColors.faint),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _OBSmallButton(
                label: l10n.onboardingListCreate,
                onTap: _loading ? null : _createList,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListPickRow extends StatelessWidget {
  const _ListPickRow({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.hasBottomBorder,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;
  final bool hasBottomBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.greenSoft : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: hasBottomBorder
            ? const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.line)))
            : null,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.green : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: AppColors.line, width: 2),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.greenInk : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 4: 調理家電
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacApplianceStep を再現。
/// M3 の _ApplianceSection と同じリポジトリ経路（setAppliances）で保存。
class _ApplianceStep extends ConsumerWidget {
  const _ApplianceStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  static const _hotcookSeries = ['KN-HW型', 'KN-HT型'];
  static const _hotcookCapacities = ['1.0L', '1.6L', '2.4L'];
  static const _healsioSeries = ['AX-XA型', 'AX-LSX型'];
  static const _healsioCapacities = ['26L', '30L'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        final appliances = settings.appliances;

        Appliance? find(ApplianceType type) =>
            appliances.where((a) => a.type == type).firstOrNull;

        Future<void> update(ApplianceType type, Appliance? next) async {
          final others =
              appliances.where((a) => a.type != type).toList();
          final list = next != null ? [...others, next] : others;
          await ref
              .read(settingsRepositoryProvider)
              .setAppliances(list);
        }

        return _OBContent(
          title: l10n.onboardingApplianceTitle,
          sub: l10n.onboardingApplianceSub,
          skipLabel: l10n.onboardingApplianceSkip,
          onSkip: onSkip,
          onBack: onBack,
          onPrimary: onNext,
          maxWidth: 460,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ホットクック（M3 の _ApplianceCard を再利用）
              OnboardingApplianceCard(
                name: l10n.settingsApplianceHotcook,
                emoji: '🍲',
                appliance: find(ApplianceType.hotcook),
                seriesOpts: _hotcookSeries,
                capacityOpts: _hotcookCapacities,
                onChanged: (a) => update(ApplianceType.hotcook, a),
              ),
              const SizedBox(height: 12),
              // ヘルシオ
              OnboardingApplianceCard(
                name: l10n.settingsApplianceHealsio,
                emoji: '♨️',
                appliance: find(ApplianceType.healsio),
                seriesOpts: _healsioSeries,
                capacityOpts: _healsioCapacities,
                onChanged: (a) => update(ApplianceType.healsio, a),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ステップ 5: 完了
// ─────────────────────────────────────────────────────────────

/// macosOnboarding.jsx の MacFinish を再現。設定サマリーを表示する。
class _FinishStep extends ConsumerWidget {
  const _FinishStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        // サマリー項目の値を解決する
        final aiName = settings.selectedProvider.isNotEmpty
            ? _resolveAiName(settings.selectedProvider)
            : null;
        final listName = settings.shoppingListName;
        final applianceSummary = _resolveApplianceSummary(
            context, settings.appliances);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // チェックバッジ
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D1F7A55),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check,
                            size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.onboardingFinishTitle,
                        style: brandTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.onboardingFinishSub,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.sub,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // サマリーチップ
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _SummaryChip(
                            key: const Key('summary_ai'),
                            label: l10n.onboardingFinishAiLabel,
                            value: aiName ?? l10n.onboardingFinishNotSet,
                          ),
                          _SummaryChip(
                            key: const Key('summary_list'),
                            label: l10n.onboardingFinishListLabel,
                            value:
                                listName ?? l10n.onboardingFinishNotSet,
                          ),
                          _SummaryChip(
                            key: const Key('summary_appliance'),
                            label:
                                l10n.onboardingFinishApplianceLabel,
                            value: applianceSummary ??
                                l10n.onboardingFinishNotSet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 設定画面案内テキスト
                      Text(
                        l10n.onboardingFinishSettingsNote,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faint,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // はじめるボタン
                      _OBPrimaryButton(
                        label: l10n.onboardingFinishStart,
                        onTap: onStart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// プロバイダ ID を表示名に変換。
  String? _resolveAiName(String providerId) {
    return switch (providerId) {
      'claude' => 'Claude',
      'openai' => 'GPT-4o',
      'gemini' => 'Gemini',
      'grok' => 'Grok',
      _ => null,
    };
  }

  /// 調理家電の一行サマリーを生成。
  String? _resolveApplianceSummary(
      BuildContext context, List<Appliance> appliances) {
    if (appliances.isEmpty) return null;
    final l10n = AppLocalizations.of(context);
    final parts = appliances.map((a) {
      final typeName = a.type == ApplianceType.hotcook
          ? l10n.settingsApplianceHotcook
          : l10n.settingsApplianceHealsio;
      final series = a.series != null ? ' ${a.series}' : '';
      return '$typeName$series';
    }).toList();
    return parts.join(' / ');
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D282723),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 13, color: AppColors.green),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 小ボタン共通（設定画面の _SmallButton に相当）
// ─────────────────────────────────────────────────────────────

class _OBSmallButton extends StatefulWidget {
  const _OBSmallButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  State<_OBSmallButton> createState() => _OBSmallButtonState();
}

class _OBSmallButtonState extends State<_OBSmallButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    Color bg;
    Color fg;
    Border? border;

    if (widget.primary) {
      bg = _hovered ? AppColors.greenInk : AppColors.green;
      fg = Colors.white;
    } else {
      bg = _hovered ? AppColors.plentySoft : AppColors.card;
      fg = AppColors.ink;
      border = Border.all(color: AppColors.line, width: 1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// M3 部品の「昇格」公開ラッパー
//
// settings_desktop_view.dart のプライベート部品(_ProviderGrid / _ApiKeyCard /
// _ApplianceCard / _PillToggle / _PillPicker / _Card / _CardLabel)は
// ファイルプライベートのため直接呼べない。
// ここで同等のウィジェットを「OnboardingXxx」という公開名で定義する。
// 将来的には shared_widgets.dart へ移動して両方から参照できるよう昇格させると
// よいが、今回は変更スコープを最小にするためオンボーディング側に定義する。
// ─────────────────────────────────────────────────────────────

/// オンボーディング用プロバイダ選択グリッド（M3 _ProviderGrid 相当）。
class OnboardingProviderGrid extends StatelessWidget {
  const OnboardingProviderGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // プロバイダ情報（M3 と同じ方式でハードコードしない）
    final infos = supportedProviderIds.map((id) {
      final p = createRecipeProviderMeta(id);
      return (id: id, name: p.$1, supportsVision: p.$2);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final info in infos)
              SizedBox(
                width: cardWidth,
                child: _OBProviderCard(
                  id: info.id,
                  name: info.name,
                  supportsVision: info.supportsVision,
                  selected: selected == info.id,
                  selectedLabel: l10n.onboardingAiSelected,
                  onTap: () => onSelect(info.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OBProviderCard extends StatelessWidget {
  const _OBProviderCard({
    required this.id,
    required this.name,
    required this.supportsVision,
    required this.selected,
    required this.selectedLabel,
    required this.onTap,
  });

  final String id;
  final String name;
  final bool supportsVision;
  final bool selected;
  final String selectedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenSoft : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.line,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green : AppColors.sub,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome,
                        size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        selectedLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenInk,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                supportsVision
                    ? l10n.settingsAiVisionYes
                    : l10n.settingsAiVisionNo,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// オンボーディング用 API キーカード（M3 _ApiKeyCard 相当）。
/// プロバイダ固定・保存/マスク表示/削除/キー取得リンク。
class OnboardingApiKeyCard extends ConsumerStatefulWidget {
  const OnboardingApiKeyCard({
    super.key,
    required this.providerId,
  });

  final String providerId;

  @override
  ConsumerState<OnboardingApiKeyCard> createState() =>
      _OnboardingApiKeyCardState();
}

class _OnboardingApiKeyCardState
    extends ConsumerState<OnboardingApiKeyCard> {
  final _controller = TextEditingController();
  String? _storedKey;
  bool _loading = true;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await ref
        .read(secureStorageProvider)
        .getApiKey(widget.providerId);
    if (!mounted) return;
    setState(() {
      _storedKey = (key != null && key.isNotEmpty) ? key : null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await ref
        .read(secureStorageProvider)
        .setApiKey(widget.providerId, value);
    _controller.clear();
    ref.invalidate(recipeProviderProvider);
    if (!mounted) return;
    setState(() {
      _storedKey = value;
      _editing = false;
    });
  }

  Future<void> _delete() async {
    await ref
        .read(secureStorageProvider)
        .deleteApiKey(widget.providerId);
    ref.invalidate(recipeProviderProvider);
    if (!mounted) return;
    setState(() {
      _storedKey = null;
      _editing = false;
      _controller.clear();
    });
  }

  String _mask(String key) {
    if (key.length <= 8) return '••••';
    final head = key.substring(0, 6);
    final tail = key.substring(key.length - 4);
    return '$head…$tail';
  }

  Future<void> _openKeyPage() async {
    final url = _keyUrls[widget.providerId];
    if (url == null) return;
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final providerName =
        createRecipeProviderMeta(widget.providerId).$1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingAiKeyLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.faint,
              letterSpacing: 0.63,
            ),
          ),
          const SizedBox(height: 7),
          if (_loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_storedKey != null && !_editing)
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsApiKeySavedMasked(_mask(_storedKey!)),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                _OBSmallButton(
                  label: l10n.settingsApiKeyChange,
                  onTap: () => setState(() => _editing = true),
                ),
                const SizedBox(width: 6),
                _OBSmallButton(
                  label: l10n.settingsApiKeyDelete,
                  onTap: _delete,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    obscureText: true,
                    onSubmitted: (_) => _save(),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.ink),
                    decoration: InputDecoration(
                      hintText: l10n.settingsApiKeyPlaceholder,
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.faint),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _OBSmallButton(
                  label: l10n.settingsApiKeySave,
                  primary: true,
                  onTap: _save,
                ),
              ],
            ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settingsApiKeyNote,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.faint,
                  ),
                ),
              ),
              if (_keyUrls.containsKey(widget.providerId))
                GestureDetector(
                  onTap: _openKeyPage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new,
                            size: 12, color: AppColors.green),
                        const SizedBox(width: 4),
                        Text(
                          l10n.onboardingAiGetKeyLink(providerName),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// オンボーディング用家電カード（M3 _ApplianceCard 相当）。
class OnboardingApplianceCard extends StatelessWidget {
  const OnboardingApplianceCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.appliance,
    required this.seriesOpts,
    required this.capacityOpts,
    required this.onChanged,
  });

  final String name;
  final String emoji;
  final Appliance? appliance;
  final List<String> seriesOpts;
  final List<String> capacityOpts;
  final ValueChanged<Appliance?> onChanged;

  ApplianceType get _type =>
      name.contains('ホットクック') ||
              name.toLowerCase().contains('hotcook')
          ? ApplianceType.hotcook
          : ApplianceType.healsio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = appliance != null;
    final series = appliance?.series ?? seriesOpts.first;
    final capacity = appliance?.capacity ?? capacityOpts.first;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: on ? AppColors.green : AppColors.line,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              // ピルトグル（M3 _PillToggle 相当）
              GestureDetector(
                onTap: () {
                  if (on) {
                    onChanged(null);
                  } else {
                    onChanged(Appliance(
                      type: _type,
                      series: seriesOpts.first,
                      capacity: capacityOpts.first,
                    ));
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    alignment:
                        on ? Alignment.centerRight : Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: on ? AppColors.green : AppColors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (on) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingApplianceSeries.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.faint,
                      letterSpacing: 0.63,
                    ),
                  ),
                  const SizedBox(height: 7),
                  // シリーズ選択（DropdownButtonFormField）
                  DropdownButtonFormField<String>(
                    initialValue: seriesOpts.contains(series)
                        ? series
                        : seriesOpts.first,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.line),
                      ),
                    ),
                    items: [
                      for (final s in seriesOpts)
                        DropdownMenuItem<String>(
                          value: s,
                          child: Text(s,
                              style:
                                  const TextStyle(fontSize: 13)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        onChanged(Appliance(
                          type: _type,
                          series: v,
                          capacity: capacity,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// M3 設定ビューとのコード共有ヘルパー
//
// settings_desktop_view.dart の同等関数はファイルスコープのため、
// ここではプロバイダファクトリを直接呼ぶ同等のヘルパーを定義する。
// ─────────────────────────────────────────────────────────────

/// (displayName, supportsVision) を返す。
(String, bool) createRecipeProviderMeta(String providerId) {
  final p = createRecipeProvider(providerId: providerId, apiKey: '');
  return (p.displayName, p.supportsVision);
}
