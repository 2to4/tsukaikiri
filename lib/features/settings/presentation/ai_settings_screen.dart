import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../recipe/domain/ai_model.dart';
import '../../recipe/service/recipe_provider.dart';
import '../../recipe/service/recipe_provider_factory.dart';
import 'settings_screen.dart';

/// API キーの取得ページ（デスクトップ版 settings_desktop_view と同じ一覧）。
const _keyUrls = <String, String>{
  'gemini': 'https://aistudio.google.com/apikey',
  'grok': 'https://console.x.ai',
  'openai': 'https://platform.openai.com/api-keys',
  'claude': 'https://console.anthropic.com/settings/keys',
};

/// プロバイダ名・Vision 対応を実装から取得する（ハードコードしない）。
/// API キーがなくても displayName / supportsVision を引けるよう
/// ダミーキーでインスタンスを生成して属性のみ参照する。
({String displayName, bool supportsVision}) providerInfo(String id) {
  final p = createRecipeProvider(providerId: id, apiKey: '');
  return (displayName: p.displayName, supportsVision: p.supportsVision);
}

/// AI 設定（モバイル）: プロバイダ選択・API キー・モデル選択。
/// デスクトップ版 _AiSection と同じデータ操作を1画面に縦並びで置く。
class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingsNavBar(title: l10n.settingsSectionAi),
            Expanded(
              child: settingsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (settings) {
                  final selected = settings.selectedProvider;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                    children: [
                      // ── プロバイダ選択 ──
                      SettingsSection(
                        title: l10n.settingsAiProvider,
                        children: [
                          for (var i = 0;
                              i < supportedProviderIds.length;
                              i++)
                            _providerRow(
                              ref,
                              l10n,
                              supportedProviderIds[i],
                              selected,
                              last: i == supportedProviderIds.length - 1,
                            ),
                        ],
                      ),
                      // ── API キー（選択中プロバイダ。切替時は key で再構築） ──
                      _ApiKeySection(
                        key: ValueKey('apikey_$selected'),
                        providerId: selected,
                      ),
                      // ── モデル選択 ──
                      _ModelSection(
                        key: ValueKey('model_$selected'),
                        providerId: selected,
                        currentModel: settings.modelOverrides[selected],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerRow(
    WidgetRef ref,
    AppLocalizations l10n,
    String id,
    String selected, {
    required bool last,
  }) {
    final info = providerInfo(id);
    return SettingsRow(
      icon: Icons.auto_awesome,
      label: info.displayName,
      value: info.supportsVision
          ? l10n.settingsAiVisionYes
          : l10n.settingsAiVisionNo,
      last: last,
      trailing: SettingsRadioMark(on: selected == id),
      onTap: () =>
          ref.read(settingsRepositoryProvider).setSelectedProvider(id),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// API キーセクション（デスクトップ版 _ApiKeyCard と同じデータ操作）
// ──────────────────────────────────────────────────────────────
class _ApiKeySection extends ConsumerStatefulWidget {
  const _ApiKeySection({super.key, required this.providerId});
  final String providerId;

  @override
  ConsumerState<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<_ApiKeySection> {
  final _controller = TextEditingController();
  String? _storedKey; // null = 未登録 / 非 null = 登録済みの生キー
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
    final url = _keyUrls[widget.providerId];
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final providerName = providerInfo(widget.providerId).displayName;

    return SettingsSection(
      title: l10n.settingsApiKeyHeading,
      note: l10n.settingsApiKeyNote,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading)
                const Center(
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
              if (_keyUrls.containsKey(widget.providerId))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: _openKeyPage,
                      child: Text(
                        l10n.settingsApiKeyGetLink(providerName),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenInk,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _savedView(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.settingsApiKeySavedMasked(_mask(_storedKey!)),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _editing = true),
          child: Text(l10n.settingsApiKeyChange,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: _delete,
          child: Text(
            l10n.settingsApiKeyDelete,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.over),
          ),
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
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: l10n.settingsApiKeyPlaceholder,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.faint),
              isDense: true,
              filled: true,
              fillColor: AppColors.bg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.green),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(l10n.settingsApiKeySave,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// モデル選択セクション（デスクトップ版 _ModelCard と同じデータ操作）
// ──────────────────────────────────────────────────────────────
class _ModelSection extends ConsumerStatefulWidget {
  const _ModelSection({
    super.key,
    required this.providerId,
    required this.currentModel,
  });

  final String providerId;
  final String? currentModel;

  @override
  ConsumerState<_ModelSection> createState() => _ModelSectionState();
}

class _ModelSectionState extends ConsumerState<_ModelSection> {
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

    return SettingsSection(
      title: l10n.settingsModelHeading,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.faint,
                  ),
                )
              else ...[
                OutlinedButton(
                  onPressed: _loading ? null : _fetchModels,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.line, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _loading
                        ? l10n.settingsModelFetching
                        : l10n.settingsModelFetch,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
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
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: widget.currentModel,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink),
                      hint: Text(l10n.settingsModelDefault,
                          style: const TextStyle(fontSize: 13.5)),
                      onChanged: _selectModel,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.settingsModelDefault,
                              style: const TextStyle(fontSize: 13.5)),
                        ),
                        for (final m in _models!)
                          DropdownMenuItem<String?>(
                            value: m.id,
                            child: Text(m.displayName,
                                style: const TextStyle(fontSize: 13.5)),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
