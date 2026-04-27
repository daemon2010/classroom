import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    ClassroomNotificationBridge.shared.register(
      messenger: flutterViewController.engine.binaryMessenger
    )

    super.awakeFromNib()
  }
}
