// onboarding_mobile_view.dart
// モバイル（狭い幅）用 設定アシスタント（6ステップ）。
// desktop の OnboardingDesktopView を基に mobile レイアウトに適応。
// ロジック（保存・サービス呼び出し）は desktop と同一。
// 起動は Navigator.push で（モバイル設定からなど）。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mobile_nav_buttons.dart';
import '../../../features/recipe/service/recipe_provider_factory.dart';
import '../../../features/settings/domain/appliance.dart';
import '../../../l10n/app_localizations.dart';
import 'onboarding_desktop_view.dart'; // OnboardingProviderGrid, OnboardingApiKeyCard, OnboardingApplianceCard を再利用

class OnboardingMobileView extends ConsumerStatefulWidget {
  const OnboardingMobileView({super.key});

  @override
  ConsumerState<OnboardingMobileView> createState() =>
      _OnboardingMobileViewState();
}

class _OnboardingMobileViewState
    extends ConsumerState<OnboardingMobileView> {
  int _step = 0;

  void _next() => setState(() => _step = (_step + 1).clamp(0, 5));
  void _back() => setState(() => _step = (_step - 1).clamp(0, 5));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: MobileNavBackButton(),
        ),
        title: Text(
          l10n.onboardingRailTitle,
          style: brandTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // トップ進捗
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / 6,
                  backgroundColor: AppColors.line,
                  color: AppColors.green,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.onboardingRailTitle} ${_step + 1}/6',
                  style: const TextStyle(fontSize: 12, color: AppColors.sub),
                ),
              ],
            ),
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _MobileWelcomeStep(onNext: _next),
      1 => _MobileAiStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      2 => _MobileLinkStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      3 => _MobileListStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      4 => _MobileApplianceStep(
          onNext: _next,
          onBack: _back,
          onSkip: _next,
        ),
      _ => _MobileFinishStep(
          onStart: () {
            // モバイルでは pop（設定や在庫に戻る）
            if (mounted) Navigator.of(context).pop();
          },
        ),
    };
  }
}

// モバイル向け Welcome（desktop 簡略化、full width）
class _MobileWelcomeStep extends StatelessWidget {
  const _MobileWelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Text('🌿', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingWelcomeTitle,
            style: brandTextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeSub,
            style: const TextStyle(fontSize: 14, color: AppColors.sub, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 3 feature 横並び（narrow では少し詰めて）
          Row(
            children: [
              _MobileFeatureCard(
                emoji: '📷',
                title: l10n.onboardingWelcomeFeature1Title,
                body: l10n.onboardingWelcomeFeature1Body,
              ),
              const SizedBox(width: 8),
              _MobileFeatureCard(
                emoji: '🍳',
                title: l10n.onboardingWelcomeFeature2Title,
                body: l10n.onboardingWelcomeFeature2Body,
              ),
              const SizedBox(width: 8),
              _MobileFeatureCard(
                emoji: '🛒',
                title: l10n.onboardingWelcomeFeature3Title,
                body: l10n.onboardingWelcomeFeature3Body,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n.onboardingWelcomeStart,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileFeatureCard extends StatelessWidget {
  const _MobileFeatureCard({required this.emoji, required this.title, required this.body});

  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(body, style: const TextStyle(fontSize: 9, color: AppColors.sub), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ステップ 1: AI（オンデバイス既定のため API キー入力はせず、可否表示のみ）
class _MobileAiStep extends ConsumerWidget {
  const _MobileAiStep({required this.onNext, required this.onBack, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final available = ref.watch(onDeviceAiAvailabilityProvider).maybeWhen(
          data: (a) => a.available,
          orElse: () => false,
        );

    return _MobileOBContent(
      title: l10n.onboardingAiTitle,
      sub: l10n.onboardingAiSub,
      skipLabel: l10n.onboardingAiSkip,
      onSkip: onSkip,
      onBack: onBack,
      onPrimary: onNext,
      child: OnDeviceStatusCard(available: available),
    );
  }
}

// ステップ 2: Link (簡略 mobile 版)
class _MobileLinkStep extends ConsumerStatefulWidget {
  const _MobileLinkStep({required this.onNext, required this.onBack, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  ConsumerState<_MobileLinkStep> createState() => _MobileLinkStepState();
}

class _MobileLinkStepState extends ConsumerState<_MobileLinkStep> {
  bool _linked = false;
  bool _loading = false;
  String? _error;

  Future<void> _requestAccess() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() { _linked = true; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() { _loading = false; _error = l10n.onboardingLinkError; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _MobileOBContent(
      title: l10n.onboardingLinkTitle,
      sub: l10n.onboardingLinkSub,
      skipLabel: l10n.onboardingLinkSkip,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      onPrimary: widget.onNext,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                _MobileInfoRow(label: l10n.onboardingLinkApp, value: l10n.onboardingLinkAppValue, hasBottomBorder: true),
                _MobileInfoRow(label: l10n.onboardingLinkAction, value: l10n.onboardingLinkActionValue, hasBottomBorder: true),
                _MobileInfoRow(label: l10n.onboardingLinkPrivacy, value: l10n.onboardingLinkPrivacyValue, hasBottomBorder: false),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.over, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          if (!_linked)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _requestAccess,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.checklist_outlined),
                label: Text(l10n.onboardingLinkButton),
              ),
            )
          else
            const Center(child: Icon(Icons.check_circle, color: AppColors.green, size: 48)),
        ],
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  const _MobileInfoRow({required this.label, required this.value, required this.hasBottomBorder});
  final String label;
  final String value;
  final bool hasBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: hasBottomBorder ? const Border(bottom: BorderSide(color: AppColors.line)) : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.sub)),
        ],
      ),
    );
  }
}

// ステップ 3: List (desktop _ListStep ロジックをほぼそのまま、UI mobile 化)
class _MobileListStep extends ConsumerStatefulWidget {
  const _MobileListStep({required this.onNext, required this.onBack, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  ConsumerState<_MobileListStep> createState() => _MobileListStepState();
}

class _MobileListStepState extends ConsumerState<_MobileListStep> {
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
    setState(() { _loading = true; _error = null; });
    try {
      final rawLists = await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() {
        _lists = rawLists.map((l) => (id: l.id, name: l.name)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() { _loading = false; _error = l10n.onboardingLinkError; });
    }
  }

  Future<void> _createList() async {
    final name = _newNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      final created = await ref.read(shoppingListServiceProvider).createList(name);
      await ref.read(settingsRepositoryProvider).setShoppingList(created.id, created.name);
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
    await ref.read(settingsRepositoryProvider).setShoppingList(id, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final currentId = settingsAsync.maybeWhen(data: (s) => s.shoppingListId, orElse: () => null);

    // 初回ロード
    if (_lists == null && !_loading) {
      _loadLists();
    }

    return _MobileOBContent(
      title: l10n.onboardingListTitle,
      sub: l10n.onboardingListSub,
      skipLabel: l10n.onboardingListSkip,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      onPrimary: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading && _lists == null)
            const Center(child: CircularProgressIndicator())
          else if (_lists != null) ...[
            for (final list in _lists!)
              ListTile(
                title: Text(list.name),
                trailing: currentId == list.id ? const Icon(Icons.check, color: AppColors.green) : null,
                onTap: () => _select(list.id, list.name),
              ),
            const Divider(),
            TextField(
              controller: _newNameController,
              decoration: const InputDecoration(
                labelText: '新しいリスト名',
                hintText: '例: 週末の買い物',
              ),
              onSubmitted: (_) => _createList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _createList,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('作成'),
              ),
            ),
          ] else if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.over)),
        ],
      ),
    );
  }
}

// ステップ 4: Appliance (desktop をそのまま再利用)
class _MobileApplianceStep extends ConsumerWidget {
  const _MobileApplianceStep({required this.onNext, required this.onBack, required this.onSkip});

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
        final appliances = settings.appliances;

        Appliance? find(ApplianceType type) =>
            appliances.where((a) => a.type == type).firstOrNull;

        Future<void> update(ApplianceType type, Appliance? next) async {
          final others = appliances.where((a) => a.type != type).toList();
          final list = next != null ? [...others, next] : others;
          await ref.read(settingsRepositoryProvider).setAppliances(list);
        }

        return _MobileOBContent(
          title: l10n.onboardingApplianceTitle,
          sub: l10n.onboardingApplianceSub,
          skipLabel: l10n.onboardingApplianceSkip,
          onSkip: onSkip,
          onBack: onBack,
          onPrimary: onNext,
          child: Column(
            children: [
              OnboardingApplianceCard(
                name: l10n.settingsApplianceHotcook,
                emoji: '🍲',
                appliance: find(ApplianceType.hotcook),
                seriesOpts: const ['KN-HW型', 'KN-HT型'],
                capacityOpts: const ['1.0L', '1.6L', '2.4L'],
                onChanged: (a) => update(ApplianceType.hotcook, a),
              ),
              const SizedBox(height: 12),
              OnboardingApplianceCard(
                name: l10n.settingsApplianceHealsio,
                emoji: '♨️',
                appliance: find(ApplianceType.healsio),
                seriesOpts: const ['AX-XA型', 'AX-LSX型'],
                capacityOpts: const ['26L', '30L'],
                onChanged: (a) => update(ApplianceType.healsio, a),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ステップ 5: 完了 (簡略 mobile 版)
class _MobileFinishStep extends ConsumerWidget {
  const _MobileFinishStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        final aiName = settings.selectedProvider.isNotEmpty
            ? _resolveAiName(settings.selectedProvider)
            : null;
        final listName = settings.shoppingListName;
        final applianceSummary = _resolveApplianceSummary(context, settings.appliances);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingFinishTitle,
                style: brandTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingFinishSub,
                style: const TextStyle(fontSize: 14, color: AppColors.sub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MobileSummaryChip(label: l10n.onboardingFinishAiLabel, value: aiName ?? l10n.onboardingFinishNotSet),
                  _MobileSummaryChip(label: l10n.onboardingFinishListLabel, value: listName ?? l10n.onboardingFinishNotSet),
                  _MobileSummaryChip(label: l10n.onboardingFinishApplianceLabel, value: applianceSummary ?? l10n.onboardingFinishNotSet),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.onboardingFinishStart, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MobileSummaryChip extends StatelessWidget {
  const _MobileSummaryChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.sub)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// モバイル共通コンテンツコンテナ（desktop _OBContent の簡易版）
class _MobileOBContent extends StatelessWidget {
  const _MobileOBContent({
    required this.title,
    required this.child,
    this.sub,
    this.skipLabel,
    this.onSkip,
    required this.onPrimary,
    this.onBack,
  });

  final String title;
  final String? sub;
  final Widget child;
  final String? skipLabel;
  final VoidCallback? onSkip;
  final VoidCallback onPrimary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, textAlign: TextAlign.center, style: brandTextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                if (sub != null) ...[
                  const SizedBox(height: 6),
                  Text(sub!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.sub)),
                ],
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              if (onBack != null)
                TextButton(onPressed: onBack, child: Text(l10n.onboardingBack)),
              if (skipLabel != null && onSkip != null) ...[
                if (onBack != null) const SizedBox(width: 8),
                TextButton(onPressed: onSkip, child: Text(skipLabel!, style: const TextStyle(color: AppColors.faint))),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                child: Text(l10n.onboardingNext, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ヘルパー（desktop から簡易コピー）
String? _resolveAiName(String id) {
  if (id == onDeviceProviderId) return onDeviceDisplayName();
  switch (id) {
    case 'gemini': return 'Gemini';
    case 'grok': return 'Grok';
    case 'openai': return 'OpenAI';
    case 'claude': return 'Claude';
    default: return id;
  }
}

String? _resolveApplianceSummary(BuildContext context, List<Appliance> list) {
  if (list.isEmpty) return null;
  final l10n = AppLocalizations.of(context);
  final names = list.map((a) {
    final t = a.type == ApplianceType.hotcook ? l10n.settingsApplianceHotcook : l10n.settingsApplianceHealsio;
    return a.capacity != null ? '$t ${a.capacity}' : t;
  }).join(' / ');
  return names;
}