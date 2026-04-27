import Cocoa
import FlutterMacOS
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

class ClassroomNotificationBridge: NSObject, UNUserNotificationCenterDelegate {
  static let shared = ClassroomNotificationBridge()

  private var channel: FlutterMethodChannel?

  func register(messenger: FlutterBinaryMessenger) {
    if channel != nil {
      return
    }

    UNUserNotificationCenter.current().delegate = self
    channel = FlutterMethodChannel(name: "classroom_notifications", binaryMessenger: messenger)
    channel?.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "notifications_unavailable", message: "Notifications are not ready.", details: nil))
        return
      }

      switch call.method {
      case "showNotification":
        self.showNotification(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func showNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let title = args["title"] as? String,
      !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(FlutterError(code: "invalid_notification", message: "Notification title is missing.", details: nil))
      return
    }

    let body = args["body"] as? String ?? ""
    let identifier = args["identifier"] as? String ?? UUID().uuidString
    let center = UNUserNotificationCenter.current()

    center.getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional:
        self.deliverNotification(center: center, identifier: identifier, title: title, body: body, result: result)
      case .notDetermined:
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
          if let error {
            self.finish(result, error: FlutterError(code: "notifications_unavailable", message: error.localizedDescription, details: nil))
            return
          }

          guard granted else {
            self.finish(result, error: FlutterError(code: "notifications_denied", message: "Notifications are disabled for this app.", details: nil))
            return
          }

          self.deliverNotification(center: center, identifier: identifier, title: title, body: body, result: result)
        }
      case .denied:
        self.finish(result, error: FlutterError(code: "notifications_denied", message: "Notifications are disabled for this app.", details: nil))
      default:
        self.finish(result, error: FlutterError(code: "notifications_unavailable", message: "Notifications are not available.", details: nil))
      }
    }
  }

  private func deliverNotification(
    center: UNUserNotificationCenter,
    identifier: String,
    title: String,
    body: String,
    result: @escaping FlutterResult
  ) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
    center.add(request) { error in
      if let error {
        self.finish(result, error: FlutterError(code: "notifications_unavailable", message: error.localizedDescription, details: nil))
        return
      }
      self.finish(result, value: true)
    }
  }

  private func finish(_ result: @escaping FlutterResult, value: Any? = nil, error: FlutterError? = nil) {
    DispatchQueue.main.async {
      if let error {
        result(error)
      } else {
        result(value)
      }
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(macOS 11.0, *) {
      completionHandler([.banner, .list, .sound])
    } else {
      completionHandler([.alert, .sound])
    }
  }
}
