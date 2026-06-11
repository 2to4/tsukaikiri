import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // デスクトップシェル（幅 >= kDesktopBreakpoint = 1000）で起動するよう、
    // 保存済みフレームがない初回起動はデスクトップ幅で開く。
    // 以後はユーザーが変えたサイズ・位置を自動保存して復元する。
    // フレームは下の frame autosave で管理するため、OS の状態復元による
    // フレーム上書き（restoreStateWithCoder:）を無効化する。
    self.isRestorable = false
    if !self.setFrameUsingName("MainWindow") {
      self.setContentSize(NSSize(width: 1280, height: 850))
      self.center()
    }
    self.setFrameAutosaveName("MainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)
    RemindersPlugin.register(with: flutterViewController.registrar(forPlugin: "RemindersPlugin"))
    ICloudSyncPlugin.register(with: flutterViewController.registrar(forPlugin: "ICloudSyncPlugin"))

    super.awakeFromNib()
  }
}
