import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../sync/presentation/sync_controller.dart';
import 'settings_screen.dart';

/// データ同期設定（モバイル）。
/// デスクトップ版 _DataSection と同じデータ操作（SyncController を共有）:
/// 自動バックアップトグル（ON 直後に即時バックアップ）・最終バックアップ日時・
/// 今すぐバックアップ・復元（確認ダイアログ）。
class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() =>
      _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
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
          ? _formatDate(settings.lastSyncedAt!)
          : null;
    });
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onToggleSyncEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setSyncEnabled(value);
    if (value) {
      // 有効にした直後に 1 回バックアップ
      await ref.read(syncControllerProvider.notifier).backup();
    }
  }

  Future<void> _onRestoreTap() async {
    final data = await ref.read(syncControllerProvider.notifier).restore();
    if (data == null) return; // エラーは ref.listen で捕捉
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final backupDate = data.settingsCompanion.lastSyncedAt.value;
    final backupDateStr = backupDate != null ? _formatDate(backupDate) : '--';
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
              style: const TextStyle(fontSize: 12, color: AppColors.over),
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
    final syncEnabled =
        ref.watch(userSettingsProvider).value?.syncEnabled ?? false;

    // SyncSuccess / SyncError を SnackBar で通知（文言は種別→l10n で解決）
    ref.listen<SyncState>(syncControllerProvider, (previous, next) {
      if (next is SyncSuccess) {
        final message = switch (next.kind) {
          SyncSuccessKind.backup => l10n.settingsDataBackupSuccess,
          SyncSuccessKind.restore => l10n.settingsDataRestoreSuccess,
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        _loadLastSyncedAt();
      } else if (next is SyncError) {
        final message = switch (next.kind) {
          SyncErrorKind.unavailable => l10n.settingsDataICloudNotAvailable,
          SyncErrorKind.backupNotFound => l10n.settingsDataNoBackupFound,
          SyncErrorKind.formatInvalid => l10n.settingsDataRestoreFormatError,
          SyncErrorKind.newerVersion =>
            l10n.settingsDataRestoreNewerVersionError,
          SyncErrorKind.failure =>
            l10n.settingsDataSyncFailed(next.detail ?? ''),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.over),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SettingsNavBar(title: l10n.settingsDataHeading),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                children: [
                  // 自動バックアップトグル
                  SettingsSection(
                    note: l10n.settingsDataSyncEnabledDesc,
                    children: [
                      SettingsRow(
                        icon: Icons.cloud_outlined,
                        label: l10n.settingsDataSyncEnabledLabel,
                        last: true,
                        trailing: Switch(
                          value: syncEnabled,
                          activeTrackColor: AppColors.green,
                          onChanged:
                              isLoading ? null : _onToggleSyncEnabled,
                        ),
                      ),
                    ],
                  ),
                  // 最終バックアップ + 手動操作
                  SettingsSection(
                    note: _lastSyncedAt != null
                        ? l10n.settingsDataLastBackup(_lastSyncedAt!)
                        : l10n.settingsDataNeverBackedUp,
                    children: [
                      SettingsRow(
                        icon: Icons.backup_outlined,
                        label: l10n.settingsDataBackupButton,
                        onTap: isLoading
                            ? null
                            : () => ref
                                .read(syncControllerProvider.notifier)
                                .backup(),
                      ),
                      SettingsRow(
                        icon: Icons.settings_backup_restore,
                        label: l10n.settingsDataRestoreButton,
                        last: true,
                        onTap: isLoading ? null : _onRestoreTap,
                      ),
                    ],
                  ),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
