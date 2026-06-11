// help_desktop_view.dart — ヘルプ / このアプリについて
// helpAbout.jsx の HelpBody を Flutter で忠実に再現。
// スクロール読み物・本文最大幅 680px 中央寄せ。

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'help_version_widget.dart';

// ─────────────────────────────────────────────────────────────
// 定数
// ─────────────────────────────────────────────────────────────

/// 本文の最大幅（デザイン: 680px）。
const double _kContentMaxWidth = 680.0;

/// 出典リンク URL。
const _kFoodkeeperUrl =
    'https://www.foodsafety.gov/keep-food-safe/foodkeeper-app';
const _kDataGovUrl =
    'https://catalog.data.gov/dataset/fsis-foodkeeper-data';

// ─────────────────────────────────────────────────────────────
// メインビュー
// ─────────────────────────────────────────────────────────────

/// macOS デスクトップ用ヘルプビュー。
/// ツールバーは app_shell の ShellToolbar（タイトルのみ）を使用する。
/// 検索フィールドは機能未実装のため置かない。
class HelpDesktopView extends StatelessWidget {
  const HelpDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
            child: const _HelpBody(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ヒーロー部（アイコン・バージョン・一言紹介）
// ─────────────────────────────────────────────────────────────

class _HelpBody extends StatelessWidget {
  const _HelpBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ヒーロー
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            children: [
              // アプリアイコン: 緑タイル + 🥗
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x421F7A55),
                      blurRadius: 26,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🥗', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 14),
              // アプリ名
              Text(
                'つかいきり',
                style: brandTextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              // バージョン（package_info_plus 取得。失敗時は非表示）
              const HelpVersionWidget(),
              const SizedBox(height: 12),
              // 一言紹介
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  l10n.helpAppTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5C564C),
                    height: 1.85,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── かんたんな使い方 ──────────────────────────────────
        _Block(
          eyebrow: l10n.helpGuideEyebrow,
          title: l10n.helpGuideTitle,
          child: Column(
            children: [
              _StepCard(
                n: 1,
                icon: Icons.photo_camera_outlined,
                title: l10n.helpStep1Title,
                body: l10n.helpStep1Body,
              ),
              const SizedBox(height: 20),
              _StepCard(
                n: 2,
                icon: Icons.eco_outlined,
                title: l10n.helpStep2Title,
                body: l10n.helpStep2Body,
              ),
              const SizedBox(height: 20),
              _StepCard(
                n: 3,
                icon: Icons.auto_awesome_outlined,
                title: l10n.helpStep3Title,
                body: l10n.helpStep3Body,
              ),
              const SizedBox(height: 20),
              _StepCard(
                n: 4,
                icon: Icons.shopping_bag_outlined,
                title: l10n.helpStep4Title,
                body: l10n.helpStep4Body,
              ),
            ],
          ),
        ),

        // ── セクション区切り線 ────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Divider(color: AppColors.line, height: 1, thickness: 1),
        ),

        // ── 賞味期限データについて ────────────────────────────
        _Block(
          eyebrow: l10n.helpDataEyebrow,
          title: l10n.helpDataTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _P(l10n.helpDataP1),
              _P(l10n.helpDataP2),
              // オレンジのコールアウト（nearSoft 背景）:「あくまで目安」
              _Callout(
                backgroundColor: AppColors.nearSoft,
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.near,
                title: l10n.helpDataCalloutTitle,
                titleColor: const Color(0xFF8A5524),
                body: l10n.helpDataCalloutBody,
                bodyColor: const Color(0xFF8A5524),
              ),
            ],
          ),
        ),

        // ── 出典・参考データ ──────────────────────────────────
        _Block(
          title: l10n.helpSourceTitle,
          child: Column(
            children: [
              _SourceLinkCard(
                title: l10n.helpSourceFoodkeeperTitle,
                host: 'foodsafety.gov/foodkeeper-app',
                desc: l10n.helpSourceFoodkeeperDesc,
                url: _kFoodkeeperUrl,
              ),
              const SizedBox(height: 10),
              _SourceLinkCard(
                title: l10n.helpSourceDatagovTitle,
                host: 'catalog.data.gov',
                desc: l10n.helpSourceDatagovDesc,
                url: _kDataGovUrl,
              ),
            ],
          ),
        ),

        // ── 賞味期限手動修正コールアウト（緑）──────────────────
        _Block(
          child: _Callout(
            backgroundColor: AppColors.greenSoft,
            icon: Icons.edit_outlined,
            iconColor: AppColors.green,
            title: l10n.helpEditCalloutTitle,
            titleColor: AppColors.greenInk,
            body: l10n.helpEditCalloutBody,
            bodyColor: const Color(0xFF3F6A53),
          ),
        ),

        // ── 規約・プライバシー ────────────────────────────────
        _Block(
          title: l10n.helpLegalTitle,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A282723),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // 各リンク行（URL 未定のため無効表示）
                // TODO(M8): 規約 URL が確定したら _LegalRow の url を設定する
                _LegalRow(
                  icon: Icons.description_outlined,
                  label: l10n.helpLegalTerms,
                  hasBottomBorder: true,
                ),
                // TODO(M8): プライバシーポリシー URL が確定したら設定する
                _LegalRow(
                  icon: Icons.shield_outlined,
                  label: l10n.helpLegalPrivacy,
                  hasBottomBorder: true,
                ),
                // TODO(M8): FAQ・問い合わせ URL が確定したら設定する
                _LegalRow(
                  icon: Icons.help_outline,
                  label: l10n.helpLegalFaq,
                  hasBottomBorder: false,
                ),
              ],
            ),
          ),
        ),

        // ── フッター帰属表示 ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Text(
            l10n.helpFooter,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.faint,
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// セクションブロック（Block in JSX）
// ─────────────────────────────────────────────────────────────

class _Block extends StatelessWidget {
  const _Block({
    this.eyebrow,
    this.title,
    required this.child,
  });

  final String? eyebrow;
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                eyebrow!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                title!,
                style: brandTextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 本文段落（P in JSX）
// ─────────────────────────────────────────────────────────────

class _P extends StatelessWidget {
  const _P(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5C564C),
          height: 1.95,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STEP カード
// ─────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.n,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int n;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // アイコンタイル
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: AppColors.green),
        ),
        const SizedBox(width: 14),
        // テキスト
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP $n',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C564C),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 出典リンクカード
// ─────────────────────────────────────────────────────────────

class _SourceLinkCard extends StatefulWidget {
  const _SourceLinkCard({
    required this.title,
    required this.host,
    required this.desc,
    required this.url,
  });

  final String title;
  final String host;
  final String desc;
  final String url;

  @override
  State<_SourceLinkCard> createState() => _SourceLinkCardState();
}

class _SourceLinkCardState extends State<_SourceLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(
          Uri.parse(widget.url),
          mode: LaunchMode.externalApplication,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.plentySoft : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              // データベースアイコンタイル
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.storage_outlined,
                  size: 20,
                  color: Color(0xFF4A6585),
                ),
              ),
              const SizedBox(width: 13),
              // テキスト部
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sub,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.host,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.faint,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 17, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// コールアウト（オレンジ / グリーン 両対応）
// ─────────────────────────────────────────────────────────────

class _Callout extends StatelessWidget {
  const _Callout({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.body,
    required this.bodyColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String body;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコンタイル
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: bodyColor,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 規約リンク行（URL 未定のため無効表示）
// ─────────────────────────────────────────────────────────────

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.icon,
    required this.label,
    required this.hasBottomBorder,
    // URL 確定時にここへ追加: this.url,
  });

  final IconData icon;
  final String label;
  final bool hasBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.faint),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.faint, // URL 未定なので faint（無効色）
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 17, color: AppColors.faint),
        ],
      ),
    );
  }
}
