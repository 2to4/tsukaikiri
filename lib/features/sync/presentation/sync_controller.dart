import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/backup_codec.dart';
import '../service/sync_service.dart';

// ──────────────────────────────────────────────────────────────
// 状態型
// ──────────────────────────────────────────────────────────────

sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncLoading extends SyncState {
  const SyncLoading();
}

/// 成功の種類。表示文言は view が l10n で解決する（i18n 規約）。
enum SyncSuccessKind { backup, restore }

/// エラーの種類。表示文言は view が l10n で解決する（i18n 規約）。
enum SyncErrorKind {
  /// iCloud が利用できない（未サインイン含む）。
  unavailable,

  /// バックアップファイルが存在しない。
  backupNotFound,

  /// バックアップ形式が不正。
  formatInvalid,

  /// 新しいアプリバージョンで作られたバックアップ。
  newerVersion,

  /// 入出力・その他のエラー（[SyncError.detail] に詳細）。
  failure,
}

class SyncSuccess extends SyncState {
  const SyncSuccess(this.kind);
  final SyncSuccessKind kind;
}

class SyncError extends SyncState {
  const SyncError(this.kind, [this.detail]);
  final SyncErrorKind kind;

  /// failure 時の補足情報（例外メッセージ等）。
  final String? detail;
}

// ──────────────────────────────────────────────────────────────
// BackupScheduler（デバウンス付き自動バックアップ用）
// ──────────────────────────────────────────────────────────────

/// 自動バックアップ用デバウンスタイマー。
///
/// [schedule] を複数回呼んでも、最後の呼び出しから [debounce] 後に 1 回だけ実行する。
class BackupScheduler {
  BackupScheduler([this.debounce = const Duration(seconds: 5)]);

  /// デバウンス時間（テストでは短縮値を注入する）。
  final Duration debounce;

  Timer? _debounce;

  /// コールバックを [debounce] 後に実行するようスケジュール。
  /// 既存タイマーがあればキャンセルしてリセットする。
  void schedule(Future<void> Function() callback) {
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      callback();
    });
  }

  /// スケジュール済みタイマーをキャンセルする。
  void cancel() {
    _debounce?.cancel();
    _debounce = null;
  }

  /// [cancel] と同義。
  void dispose() => cancel();
}

// ──────────────────────────────────────────────────────────────
// SyncController（Riverpod v3 Notifier）
// ──────────────────────────────────────────────────────────────

class SyncController extends Notifier<SyncState> {
  // 復元中フラグ（silentBackup をスキップするため）
  bool _isRestoring = false;

  @override
  SyncState build() => const SyncIdle();

  // ── 依存解決ヘルパー ──

  SyncService get _syncService => ref.read(syncServiceProvider);

  // ──────────────────────────────────────────────────────────────
  // バックアップ
  // ──────────────────────────────────────────────────────────────

  /// 在庫と設定を iCloud にバックアップする。
  ///
  /// [isAvailable] が false の場合は [SyncError] に遷移する。
  /// 成功時は [SyncSuccess]、エラー時は [SyncError] に遷移する。
  Future<void> backup() async {
    state = const SyncLoading();

    try {
      final available = await _syncService.isAvailable();
      if (!available) {
        state = const SyncError(SyncErrorKind.unavailable);
        return;
      }

      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);

      final ingredients = await inventoryRepo.getInventory();
      final settingsRow = await settingsRepo.getRow();
      if (settingsRow == null) {
        state = const SyncError(SyncErrorKind.failure, 'settings row missing');
        return;
      }

      final payload = BackupCodec.encodeBackup(
        ingredients: ingredients,
        settings: settingsRow,
      );

      await _syncService.writeBackup(payload);

      final now = DateTime.now();
      await settingsRepo.setLastSyncedAt(now);
      state = const SyncSuccess(SyncSuccessKind.backup);
    } on SyncNotSignedInException {
      state = const SyncError(SyncErrorKind.unavailable);
    } on SyncIOException catch (e) {
      state = SyncError(SyncErrorKind.failure, e.message);
    } catch (e) {
      state = SyncError(SyncErrorKind.failure, '$e');
    }
  }

  /// バックアップファイルを iCloud から読み込んで [BackupData] を返す。
  ///
  /// ファイルが見つからない場合は [SyncError] に遷移し `null` を返す。
  /// 形式不正の場合も [SyncError] に遷移し `null` を返す。
  Future<BackupData?> restore() async {
    state = const SyncLoading();

    try {
      final available = await _syncService.isAvailable();
      if (!available) {
        state = const SyncError(SyncErrorKind.unavailable);
        return null;
      }

      final raw = await _syncService.readBackup();
      if (raw == null) {
        state = const SyncError(SyncErrorKind.backupNotFound);
        return null;
      }

      final data = BackupCodec.decodeBackup(raw);
      state = const SyncIdle();
      return data;
    } on SyncNotSignedInException {
      state = const SyncError(SyncErrorKind.unavailable);
      return null;
    } on SyncIOException catch (e) {
      state = SyncError(SyncErrorKind.failure, e.message);
      return null;
    } on BackupFormatException catch (e) {
      state = SyncError(e.code == 'newer_version'
          ? SyncErrorKind.newerVersion
          : SyncErrorKind.formatInvalid);
      return null;
    } catch (e) {
      state = SyncError(SyncErrorKind.failure, '$e');
      return null;
    }
  }

  /// 読み込んだ [BackupData] を在庫・設定に適用する。
  Future<void> applyRestore(BackupData data) async {
    _isRestoring = true;
    state = const SyncLoading();

    try {
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);

      await inventoryRepo.replaceAll(data.ingredients);
      await settingsRepo.replaceSettings(data.settingsCompanion);

      final now = DateTime.now();
      await settingsRepo.setLastSyncedAt(now);

      state = const SyncSuccess(SyncSuccessKind.restore);
    } catch (e) {
      state = SyncError(SyncErrorKind.failure, '$e');
    } finally {
      _isRestoring = false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // サイレントバックアップ（自動バックアップ用）
  // ──────────────────────────────────────────────────────────────

  /// エラーを [SyncState] に反映しないサイレントバックアップ。
  ///
  /// 復元中（[_isRestoring]）は何もしない。
  /// エラーは飲み込む（ログのみ）。
  Future<void> silentBackup() async {
    if (_isRestoring) return;

    try {
      final available = await _syncService.isAvailable();
      if (!available) return;

      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);

      final ingredients = await inventoryRepo.getInventory();
      final settingsRow = await settingsRepo.getRow();
      if (settingsRow == null) return;

      final payload = BackupCodec.encodeBackup(
        ingredients: ingredients,
        settings: settingsRow,
      );

      await _syncService.writeBackup(payload);
      await settingsRepo.setLastSyncedAt(DateTime.now());
    } catch (_) {
      // サイレント: エラーは無視
    }
  }
}
