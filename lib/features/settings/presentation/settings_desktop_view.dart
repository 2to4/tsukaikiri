import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_time_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../recipe/domain/ai_model.dart';
import '../../recipe/service/recipe_provider.dart';
import '../../recipe/service/recipe_provider_factory.dart';
import '../../shell/presentation/shell_providers.dart';
import '../../shopping/domain/shopping_list.dart';
import '../../sync/presentation/sync_controller.dart';
import '../domain/appliance.dart';
import 'locale_controller.dart';

// ──────────────────────────────────────────────────────────────
// 定数
// ──────────────────────────────────────────────────────────────
const double _kNavWidth = 200.0;

/// 設定セクション。
enum _SettingsSection { ai, general, shopping, appliance, data, support }

/// 各 AI プロバイダのキー取得ページ URL。
// ──────────────────────────────────────────────────────────────
// SettingsDesktopView（メインウィジェット）
// macosApp.jsx の SettingsScreen を Flutter で再現した 2ペイン設定。
// ──────────────────────────────────────────────────────────────
class SettingsDesktopView extends ConsumerStatefulWidget {
  const SettingsDesktopView({super.key});

  @override
  ConsumerState<SettingsDesktopView> createState() =>
      _SettingsDesktopViewState();
}

class _SettingsDesktopViewState extends ConsumerState<SettingsDesktopView> {
  _SettingsSection _section = _SettingsSection.ai;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 左: セクションナビ ──
        _SectionNav(
          selected: _section,
          onSelect: (s) => setState(() => _section = s),
        ),
        // ── 右: コンテンツ ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: switch (_section) {
              _SettingsSection.ai => const _AiSection(),
              _SettingsSection.general => const _GeneralSection(),
              _SettingsSection.shopping => const _ShoppingSection(),
              _SettingsSection.appliance => const _ApplianceSection(),
              _SettingsSection.data => const _DataSection(),
              _SettingsSection.support => const _SupportSection(),
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _SectionNav: 左ペイン（セクション切替）
// ──────────────────────────────────────────────────────────────
class _SectionNav extends StatelessWidget {
  const _SectionNav({required this.selected, required this.onSelect});

  final _SettingsSection selected;
  final ValueChanged<_SettingsSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(_SettingsSection, IconData, String)>[
      (_SettingsSection.ai, Icons.auto_awesome_outlined, l10n.settingsNavAi),
      (_SettingsSection.general, Icons.language, l10n.settingsNavGeneral),
      (_SettingsSection.shopping, Icons.checklist_outlined,
          l10n.settingsNavShopping),
      (_SettingsSection.appliance, Icons.soup_kitchen_outlined,
          l10n.settingsNavAppliance),
      (_SettingsSection.data, Icons.cloud_outlined, l10n.settingsNavData),
      (_SettingsSection.support, Icons.local_cafe_outlined,
          l10n.settingsNavSupport),
    ];

    return Container(
      width: _kNavWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        border: Border(right: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (section, icon, label) in items)
              _NavButton(
                icon: icon,
                label: label,
                selected: selected == section,
                onTap: () => onSelect(section),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (widget.selected) {
      bgColor = AppColors.greenSoft;
    } else if (_hovered) {
      bgColor = const Color(0x0D282723); // rgba(40,39,35,0.05)
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: widget.selected ? AppColors.green : AppColors.sub,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        widget.selected ? FontWeight.w700 : FontWeight.w600,
                    color:
                        widget.selected ? AppColors.greenInk : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 共通: セクション見出し（ブランドフォント 18px）
// ──────────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: brandTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// 白カード（境界線つき）。各セクションのコンテンツコンテナ。
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: child,
    );
  }
}

/// カード内の小見出し（letterSpacing つきの faint ラベル）。
class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.faint,
        letterSpacing: 0.72,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AI セクション
// ══════════════════════════════════════════════════════════════
class _AiSection extends ConsumerWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('$e'),
      data: (settings) {
        final selected = settings.selectedProvider;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeading(l10n.settingsAiHeading),
            // プロバイダカード 2×2 グリッド
            _ProviderGrid(
              selected: selected,
              onSelect: (id) => ref
                  .read(settingsRepositoryProvider)
                  .setSelectedProvider(id),
            ),
            const SizedBox(height: 16),
            // APIキーカード（プロバイダごとに状態を持つため key で再構築）
            _ApiKeyCard(key: ValueKey('apikey_$selected'), providerId: selected),
            const SizedBox(height: 16),
            // モデル選択カード
            _ModelCard(
              key: ValueKey('model_$selected'),
              providerId: selected,
              currentModel: settings.modelOverrides[selected],
            ),
          ],
        );
      },
    );
  }
}

/// プロバイダ名・Vision 対応を実装から取得する（ハードコードしない）。
class _ProviderInfo {
  const _ProviderInfo(this.id, this.displayName, this.supportsVision);
  final String id;
  final String displayName;
  final bool supportsVision;
}

/// API キーがなくても displayName / supportsVision を引けるよう
/// ダミーキーでインスタンスを生成して属性のみ参照する。
List<_ProviderInfo> _providerInfos() {
  return supportedProviderIds.map((id) {
    final info = providerDisplayInfo(id);
    return _ProviderInfo(id, info.displayName, info.supportsVision);
  }).toList();
}

class _ProviderGrid extends StatelessWidget {
  const _ProviderGrid({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final infos = _providerInfos();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final info in infos)
              SizedBox(
                width: cardWidth,
                child: _ProviderCard(
                  info: info,
                  selected: selected == info.id,
                  onTap: () => onSelect(info.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final _ProviderInfo info;
  final bool selected;
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
          padding: const EdgeInsets.all(14),
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green : AppColors.sub,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome,
                        size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      info.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                info.supportsVision
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

// ──────────────────────────────────────────────────────────────
// APIキーカード
// ──────────────────────────────────────────────────────────────
class _ApiKeyCard extends ConsumerStatefulWidget {
  const _ApiKeyCard({super.key, required this.providerId});
  final String providerId;

  @override
  ConsumerState<_ApiKeyCard> createState() => _ApiKeyCardState();
}

class _ApiKeyCardState extends ConsumerState<_ApiKeyCard> {
  final _controller = TextEditingController();
  String? _storedKey; // null = 未登録 / 非 null = 登録済みの生キー
  bool _loading = true;
  bool _editing = false; // 登録済みでも入力欄を出すモード

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
    final key =
        await ref.read(secureStorageProvider).getApiKey(widget.providerId);
    if (!mounted) return;
    setState(() {
      _storedKey = (key != null && key.isNotEmpty) ? key : null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await ref.read(secureStorageProvider).setApiKey(widget.providerId, value);
    _controller.clear();
    // 解決中の RecipeProvider を作り直す。
    ref.invalidate(recipeProviderProvider);
    if (!mounted) return;
    setState(() {
      _storedKey = value;
      _editing = false;
    });
  }

  Future<void> _delete() async {
    await ref.read(secureStorageProvider).deleteApiKey(widget.providerId);
    ref.invalidate(recipeProviderProvider);
    if (!mounted) return;
    setState(() {
      _storedKey = null;
      _editing = false;
      _controller.clear();
    });
  }

  /// 例: sk-ant-xxxxxxxxabcd → sk-ant…abcd
  String _mask(String key) {
    if (key.length <= 8) return '••••';
    final head = key.substring(0, 6);
    final tail = key.substring(key.length - 4);
    return '$head…$tail';
  }

  Future<void> _openKeyPage() async {
    final url = providerKeyUrls[widget.providerId];
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final providerName = providerDisplayInfo(widget.providerId).displayName;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(l10n.settingsApiKeyHeading),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_storedKey != null && !_editing)
            _savedView(l10n)
          else
            _inputView(l10n),
          const SizedBox(height: 8),
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
              if (providerKeyUrls.containsKey(widget.providerId))
                _LinkButton(
                  label: l10n.settingsApiKeyGetLink(providerName),
                  onTap: _openKeyPage,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savedView(AppLocalizations l10n) {
    return Row(
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
        _SmallButton(
          label: l10n.settingsApiKeyChange,
          onTap: () => setState(() => _editing = true),
        ),
        const SizedBox(width: 6),
        _SmallButton(
          label: l10n.settingsApiKeyDelete,
          danger: true,
          onTap: _delete,
        ),
      ],
    );
  }

  Widget _inputView(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            obscureText: true,
            onSubmitted: (_) => _save(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: l10n.settingsApiKeyPlaceholder,
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppColors.faint),
              isDense: true,
              filled: true,
              fillColor: AppColors.bg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.green),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SmallButton(
          label: l10n.settingsApiKeySave,
          primary: true,
          onTap: _save,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// モデル選択カード
// ──────────────────────────────────────────────────────────────
class _ModelCard extends ConsumerStatefulWidget {
  const _ModelCard({
    super.key,
    required this.providerId,
    required this.currentModel,
  });

  final String providerId;
  final String? currentModel;

  @override
  ConsumerState<_ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends ConsumerState<_ModelCard> {
  bool _loading = false;
  List<AiModel>? _models;
  String? _error;
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _checkKey();
  }

  Future<void> _checkKey() async {
    final has =
        await ref.read(secureStorageProvider).hasApiKey(widget.providerId);
    if (!mounted) return;
    setState(() => _hasKey = has);
  }

  Future<void> _fetchModels() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apiKey =
          await ref.read(secureStorageProvider).getApiKey(widget.providerId);
      if (apiKey == null || apiKey.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _hasKey = false;
        });
        return;
      }
      final provider = createRecipeProvider(
        providerId: widget.providerId,
        apiKey: apiKey,
      );
      final models = await provider.listModels();
      if (!mounted) return;
      setState(() {
        _models = models;
        _loading = false;
      });
    } on RecipeProviderException catch (e) {
      if (!mounted) return;
      // オフライン方針: 失敗したら案内を出す（事前判定で無効化はしない）。
      setState(() {
        _loading = false;
        _error = e.body.isNotEmpty
            ? e.body
            : AppLocalizations.of(context).settingsNetworkError;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).settingsNetworkError;
      });
    }
  }

  Future<void> _selectModel(String? modelId) async {
    await ref
        .read(settingsRepositoryProvider)
        .setModelOverride(widget.providerId, modelId);
    ref.invalidate(recipeProviderProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(l10n.settingsModelHeading),
          const SizedBox(height: 10),
          // 現在の上書き値
          if (widget.currentModel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.settingsModelCurrent(widget.currentModel!),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenInk,
                ),
              ),
            ),
          if (!_hasKey)
            Text(
              l10n.settingsModelNeedKey,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.faint,
              ),
            )
          else ...[
            _SmallButton(
              label: _loading
                  ? l10n.settingsModelFetching
                  : l10n.settingsModelFetch,
              primary: true,
              onTap: _loading ? null : _fetchModels,
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
            if (_models != null) ...[
              const SizedBox(height: 10),
              _ModelDropdown(
                models: _models!,
                current: widget.currentModel,
                onSelect: _selectModel,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.models,
    required this.current,
    required this.onSelect,
  });

  final List<AiModel> models;
  final String? current;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // current が一覧にない場合は null（既定）にフォールバックさせる。
    final value = models.any((m) => m.id == current) ? current : null;

    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.settingsModelDefault),
        ),
        for (final m in models)
          DropdownMenuItem<String?>(
            value: m.id,
            child: Text(m.displayName, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onSelect,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 一般セクション（言語）
// ══════════════════════════════════════════════════════════════
class _GeneralSection extends ConsumerWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(localeControllerProvider.notifier);
    ref.watch(localeControllerProvider); // 再描画
    final current = controller.currentPref;

    final opts = <(String, String)>[
      ('ja', l10n.languageJa),
      ('en', l10n.languageEn),
      ('system', l10n.languageSystem),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(l10n.settingsGeneralHeading),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < opts.length; i++) ...[
                _LanguageRow(
                  label: opts[i].$2,
                  selected: current == opts[i].$1,
                  onTap: () => controller.setPref(opts[i].$1),
                ),
                if (i < opts.length - 1)
                  const Divider(height: 1, color: AppColors.line),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.greenSoft : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.greenInk : AppColors.ink,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 15, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 買い物リストセクション
// ══════════════════════════════════════════════════════════════
class _ShoppingSection extends ConsumerStatefulWidget {
  const _ShoppingSection();

  @override
  ConsumerState<_ShoppingSection> createState() => _ShoppingSectionState();
}

class _ShoppingSectionState extends ConsumerState<_ShoppingSection> {
  bool _loading = false;
  List<ShoppingList>? _lists;
  String? _error;
  final _newListController = TextEditingController();

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lists = await ref.read(shoppingListServiceProvider).getLists();
      if (!mounted) return;
      setState(() {
        _lists = lists;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).settingsShoppingLoadError;
      });
    }
  }

  Future<void> _createList() async {
    final name = _newListController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final created =
          await ref.read(shoppingListServiceProvider).createList(name);
      await ref
          .read(settingsRepositoryProvider)
          .setShoppingList(created.id, created.name);
      _newListController.clear();
      if (!mounted) return;
      setState(() {
        _lists = [...?_lists, created];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).settingsShoppingLoadError;
      });
    }
  }

  Future<void> _select(ShoppingList list) async {
    await ref
        .read(settingsRepositoryProvider)
        .setShoppingList(list.id, list.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final currentId =
        settingsAsync.maybeWhen(data: (s) => s.shoppingListId, orElse: () => null);
    final currentName =
        settingsAsync.maybeWhen(data: (s) => s.shoppingListName, orElse: () => null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(l10n.settingsShoppingHeading),
        // 連携先アプリ
        _Card(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settingsShoppingLinkedApp,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.faint,
                  ),
                ),
              ),
              Text(
                l10n.settingsShoppingReminders,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 現在の選択
        Text(
          currentName != null
              ? l10n.settingsShoppingCurrent(currentName)
              : l10n.settingsShoppingCurrent(l10n.settingsShoppingNone),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SmallButton(
              label: _loading
                  ? l10n.settingsShoppingLoading
                  : l10n.settingsShoppingLoad,
              primary: true,
              onTap: _loading ? null : _loadLists,
            ),
          ],
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
        if (_lists != null) ...[
          const SizedBox(height: 12),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _lists!.length; i++) ...[
                  _ShoppingListRow(
                    list: _lists![i],
                    selected: _lists![i].id == currentId,
                    onTap: () => _select(_lists![i]),
                  ),
                  if (i < _lists!.length - 1)
                    const Divider(height: 1, color: AppColors.line),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        // 新規リスト作成
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newListController,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: l10n.settingsShoppingNewName,
                  hintStyle:
                      const TextStyle(fontSize: 13, color: AppColors.faint),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SmallButton(
              label: l10n.settingsShoppingCreate,
              onTap: _loading ? null : _createList,
            ),
          ],
        ),
      ],
    );
  }
}

class _ShoppingListRow extends StatelessWidget {
  const _ShoppingListRow({
    required this.list,
    required this.selected,
    required this.onTap,
  });

  final ShoppingList list;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.greenSoft : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.greenInk : AppColors.ink,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 15, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 調理家電セクション
// ══════════════════════════════════════════════════════════════
class _ApplianceSection extends ConsumerWidget {
  const _ApplianceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('$e'),
      data: (settings) {
        final appliances = settings.appliances;
        Appliance? find(ApplianceType type) =>
            appliances.where((a) => a.type == type).firstOrNull;

        Future<void> update(ApplianceType type, Appliance? next) async {
          final others =
              appliances.where((a) => a.type != type).toList();
          final list = next != null ? [...others, next] : others;
          await ref.read(settingsRepositoryProvider).setAppliances(list);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeading(l10n.settingsApplianceHeading),
            _ApplianceCard(
              name: l10n.settingsApplianceHotcook,
              icon: Icons.soup_kitchen_outlined,
              appliance: find(ApplianceType.hotcook),
              seriesOpts: applianceSeriesOptions[ApplianceType.hotcook]!,
              capacityOpts: applianceCapacityOptions[ApplianceType.hotcook]!,
              onChanged: (a) => update(ApplianceType.hotcook, a),
            ),
            const SizedBox(height: 12),
            _ApplianceCard(
              name: l10n.settingsApplianceHealsio,
              icon: Icons.microwave_outlined,
              appliance: find(ApplianceType.healsio),
              seriesOpts: applianceSeriesOptions[ApplianceType.healsio]!,
              capacityOpts: applianceCapacityOptions[ApplianceType.healsio]!,
              onChanged: (a) => update(ApplianceType.healsio, a),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsApplianceNote,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: AppColors.faint,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ApplianceCard extends StatelessWidget {
  const _ApplianceCard({
    required this.name,
    required this.icon,
    required this.appliance,
    required this.seriesOpts,
    required this.capacityOpts,
    required this.onChanged,
  });

  final String name;
  final IconData icon;
  final Appliance? appliance;
  final List<String> seriesOpts;
  final List<String> capacityOpts;
  final ValueChanged<Appliance?> onChanged;

  ApplianceType get _type =>
      name.contains('ホットクック') || name.toLowerCase().contains('hotcook')
          ? ApplianceType.hotcook
          : ApplianceType.healsio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = appliance != null;
    final series = appliance?.series ?? seriesOpts.first;
    final capacity = appliance?.capacity ?? capacityOpts.first;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      on
                          ? '$series ・ $capacity'
                          : l10n.settingsApplianceNotOwned,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sub,
                      ),
                    ),
                  ],
                ),
              ),
              _PillToggle(
                on: on,
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
              ),
            ],
          ),
          if (on) ...[
            const SizedBox(height: 14),
            _PillPicker(
              label: l10n.settingsApplianceSeries,
              options: seriesOpts,
              selected: series,
              onSelect: (v) => onChanged(Appliance(
                type: _type,
                series: v,
                capacity: capacity,
              )),
            ),
            const SizedBox(height: 12),
            _PillPicker(
              label: l10n.settingsApplianceCapacity,
              options: capacityOpts,
              selected: capacity,
              onSelect: (v) => onChanged(Appliance(
                type: _type,
                series: series,
                capacity: v,
              )),
            ),
          ],
        ],
      ),
    );
  }
}

/// 44×26 のピル型トグル（ノブ 200ms アニメーション）。
class _PillToggle extends StatelessWidget {
  const _PillToggle({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 26,
          padding: const EdgeInsets.all(2),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: on ? AppColors.green : AppColors.line,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Container(
            width: 22,
            height: 22,
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
    );
  }
}

/// 型・容量を選ぶピル型ボタン群。
class _PillPicker extends StatelessWidget {
  const _PillPicker({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

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
            color: AppColors.faint,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final o in options)
              GestureDetector(
                onTap: () => onSelect(o),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: o == selected
                          ? AppColors.ink
                          : const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      o,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: o == selected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// データセクション（iCloud バックアップ / 復元）
// ══════════════════════════════════════════════════════════════
class _DataSection extends ConsumerStatefulWidget {
  const _DataSection();

  @override
  ConsumerState<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<_DataSection> {
  String? _lastSyncedAt; // null = 未実施

  @override
  void initState() {
    super.initState();
    _loadLastSyncedAt();
  }

  Future<void> _loadLastSyncedAt() async {
    final settings = await ref.read(settingsRepositoryProvider).get();
    if (!mounted) return;
    setState(() {
      _lastSyncedAt = settings.lastSyncedAt != null
          ? formatDateTimeMinutes(settings.lastSyncedAt!)
          : null;
    });
  }

  Future<void> _onToggleSyncEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setSyncEnabled(value);
    if (value) {
      // 有効にした直後に 1 回バックアップ
      await ref.read(syncControllerProvider.notifier).backup();
      // setSyncEnabled の指紋変化で autoBackupWatcher が予約した
      // デバウンスバックアップは、直前の backup() と重複するため取り消す。
      ref.read(backupSchedulerProvider).cancel();
    }
  }

  Future<void> _onBackupTap() async {
    await ref.read(syncControllerProvider.notifier).backup();
  }

  Future<void> _onRestoreTap() async {
    final data = await ref.read(syncControllerProvider.notifier).restore();
    if (data == null) return; // エラーは ref.listen で捕捉
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    // バックアップ内の日時と在庫件数を確認ダイアログで表示
    final backupDate = data.settingsCompanion.lastSyncedAt.value;
    final backupDateStr = backupDate != null ? formatDateTimeMinutes(backupDate) : '--';
    final itemCount = data.ingredients.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDataRestoreConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsDataRestoreConfirmDate(backupDateStr)),
            const SizedBox(height: 4),
            Text(l10n.settingsDataRestoreConfirmCount(itemCount)),
            const SizedBox(height: 8),
            Text(
              l10n.settingsDataRestoreConfirmWarning,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.over,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsDataRestoreConfirmOk),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    await ref.read(syncControllerProvider.notifier).applyRestore(data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final syncState = ref.watch(syncControllerProvider);
    final isLoading = syncState is SyncLoading;
    final settingsAsync = ref.watch(userSettingsProvider);
    final syncEnabled = settingsAsync.maybeWhen(
      data: (s) => s.syncEnabled,
      orElse: () => false,
    );

    // SyncSuccess / SyncError を SnackBar で通知（文言は種別→l10n で解決）
    ref.listen<SyncState>(syncControllerProvider, (previous, next) {
      if (next is SyncSuccess) {
        final message = switch (next.kind) {
          SyncSuccessKind.backup => l10n.settingsDataBackupSuccess,
          SyncSuccessKind.restore => l10n.settingsDataRestoreSuccess,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _loadLastSyncedAt();
      } else if (next is SyncError) {
        final message = switch (next.kind) {
          SyncErrorKind.unavailable => l10n.settingsDataICloudNotAvailable,
          SyncErrorKind.backupNotFound => l10n.settingsDataNoBackupFound,
          SyncErrorKind.formatInvalid => l10n.settingsDataRestoreFormatError,
          SyncErrorKind.newerVersion =>
            l10n.settingsDataRestoreNewerVersionError,
          SyncErrorKind.failure => l10n.settingsDataSyncFailed(
              next.detail ?? '',
            ),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.over,
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(l10n.settingsDataHeading),

        // iCloud 自動バックアップ トグル
        _Card(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDataSyncEnabledLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsDataSyncEnabledDesc,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.faint,
                      ),
                    ),
                  ],
                ),
              ),
              _PillToggle(
                on: syncEnabled,
                onTap: () => _onToggleSyncEnabled(!syncEnabled),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 最終バックアップ日時
        _Card(
          child: Row(
            children: [
              const Icon(Icons.cloud_done_outlined,
                  size: 16, color: AppColors.sub),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _lastSyncedAt != null
                      ? l10n.settingsDataLastBackup(_lastSyncedAt!)
                      : l10n.settingsDataNeverBackedUp,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sub,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // バックアップ・復元ボタン
        Row(
          children: [
            _SmallButton(
              label: l10n.settingsDataBackupButton,
              primary: true,
              onTap: isLoading ? null : _onBackupTap,
            ),
            const SizedBox(width: 10),
            _SmallButton(
              label: l10n.settingsDataRestoreButton,
              onTap: isLoading ? null : _onRestoreTap,
            ),
          ],
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// サポートセクション
// ══════════════════════════════════════════════════════════════
class _SupportSection extends ConsumerWidget {
  const _SupportSection();

  Future<void> _showAbout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (_) {
      // テスト環境などで取得できない場合はアプリ名のみ表示する。
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('つかいきり', style: brandTextStyle(fontSize: 18)),
        content: version.isEmpty
            ? null
            : Text(l10n.settingsAboutVersion(version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.settingsAboutClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(l10n.settingsSupportHeading),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 作者をサポート（Buy Me a Coffee。URL 未定のため当面無効）
              // TODO(M8/ロードマップ#9): Buy Me a Coffee URL 確定後に url_launcher で開く。
              _SupportRow(
                icon: Icons.local_cafe_outlined,
                iconBg: AppColors.coffeeSoft,
                label: l10n.settingsSupportAuthor,
                trailing: Text(
                  l10n.settingsSupportComingSoon,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.faint,
                  ),
                ),
                enabled: false,
                onTap: null,
              ),
              const Divider(height: 1, color: AppColors.line),
              _SupportRow(
                icon: Icons.help_outline,
                label: l10n.settingsSupportHelp,
                onTap: () => ref
                    .read(shellSectionProvider.notifier)
                    .select(ShellSection.help),
              ),
              const Divider(height: 1, color: AppColors.line),
              _SupportRow(
                icon: Icons.info_outline,
                label: l10n.settingsSupportAbout,
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.icon,
    required this.label,
    this.iconBg,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color? iconBg;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.greenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.ink : AppColors.faint,
              ),
            ),
          ),
          ?trailing,
          if (onTap != null && trailing == null)
            const Icon(Icons.chevron_right, size: 18, color: AppColors.faint),
        ],
      ),
    );

    if (onTap == null) return Opacity(opacity: enabled ? 1 : 0.7, child: content);
    return InkWell(onTap: onTap, child: content);
  }
}

// ══════════════════════════════════════════════════════════════
// 共通の小さなボタン・リンク
// ══════════════════════════════════════════════════════════════
class _SmallButton extends StatefulWidget {
  const _SmallButton({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool danger;

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
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
    } else if (widget.danger) {
      bg = _hovered ? AppColors.overSoft : AppColors.card;
      fg = AppColors.over;
      border = Border.all(color: AppColors.overSoft, width: 1);
    } else {
      bg = _hovered ? AppColors.plentySoft : AppColors.card;
      fg = AppColors.ink;
      border = Border.all(color: AppColors.line, width: 1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new, size: 12, color: AppColors.green),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
