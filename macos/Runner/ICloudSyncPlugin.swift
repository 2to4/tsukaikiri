import Foundation
import FlutterMacOS

class ICloudSyncPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.futo4.tsukaikiri/icloud_sync",
      binaryMessenger: registrar.messenger
    )
    let instance = ICloudSyncPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(FileManager.default.ubiquityIdentityToken != nil)
    case "writeBackup":
      guard let args = call.arguments as? [String: Any],
            let payload = args["payload"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "payload required", details: nil))
        return
      }
      writeBackup(payload: payload, result: result)
    case "readBackup":
      readBackup(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // バックグラウンドスレッドで ubiquity コンテナを解決して書き込む
  private func writeBackup(payload: String, result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .utility).async {
      guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "not_signed_in", message: "iCloud container not available", details: nil))
        }
        return
      }
      let backupDir = containerURL.appendingPathComponent("backup")
      let backupURL = backupDir.appendingPathComponent("tsukaikiri_backup.json")
      do {
        try FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
        let coordinator = NSFileCoordinator()
        var coordError: NSError?
        var writeError: Error?
        coordinator.coordinate(writingItemAt: backupURL, options: .forReplacing, error: &coordError) { url in
          do {
            try payload.write(to: url, atomically: true, encoding: .utf8)
          } catch {
            writeError = error
          }
        }
        if let err = coordError {
          DispatchQueue.main.async {
            result(FlutterError(code: "io_error", message: err.localizedDescription, details: nil))
          }
        } else if let err = writeError {
          DispatchQueue.main.async {
            result(FlutterError(code: "io_error", message: err.localizedDescription, details: nil))
          }
        } else {
          DispatchQueue.main.async { result(nil) }
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "io_error", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private func readBackup(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .utility).async {
      guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "not_signed_in", message: "iCloud container not available", details: nil))
        }
        return
      }
      let backupDir = containerURL.appendingPathComponent("backup")
      let backupURL = backupDir.appendingPathComponent("tsukaikiri_backup.json")
      // 未ダウンロードのアイテムは実ファイル名ではなく
      // 「.<名前>.icloud」というプレースホルダ名で存在する。
      let placeholderURL = backupDir.appendingPathComponent(".tsukaikiri_backup.json.icloud")

      let fm = FileManager.default
      let realExists = fm.fileExists(atPath: backupURL.path)
      let placeholderExists = fm.fileExists(atPath: placeholderURL.path)

      if !realExists && !placeholderExists {
        // バックアップなし → null
        DispatchQueue.main.async { result(nil) }
        return
      }

      // iCloud プレースホルダ・未ダウンロード状態ならダウンロードして待つ
      var isDownloaded = realExists
      if realExists,
         let values = try? backupURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]),
         let status = values.ubiquitousItemDownloadingStatus {
        isDownloaded = (status == .current)
      }

      if !isDownloaded {
        try? fm.startDownloadingUbiquitousItem(at: backupURL)
        var waited = 0
        while waited < 10 {
          Thread.sleep(forTimeInterval: 1.0)
          waited += 1
          if fm.fileExists(atPath: backupURL.path),
             let values = try? backupURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]),
             let status = values.ubiquitousItemDownloadingStatus,
             status == .current {
            break
          }
        }
        if !fm.fileExists(atPath: backupURL.path) {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "io_error",
              message: "Backup exists in iCloud but could not be downloaded in time",
              details: nil
            ))
          }
          return
        }
      }

      let coordinator = NSFileCoordinator()
      var coordError: NSError?
      var content: String?
      coordinator.coordinate(readingItemAt: backupURL, options: .withoutChanges, error: &coordError) { url in
        content = try? String(contentsOf: url, encoding: .utf8)
      }
      if let err = coordError {
        DispatchQueue.main.async {
          result(FlutterError(code: "io_error", message: err.localizedDescription, details: nil))
        }
      } else {
        DispatchQueue.main.async { result(content) }
      }
    }
  }
}
