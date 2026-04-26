import "package:local_notifier/local_notifier.dart";

class NotificationService {
  bool _isReady = false;

  Future<void> init() async {
    try {
      await localNotifier.setup(appName: "Classroom Ungraded Checker");
      _isReady = true;
    } catch (_) {
      _isReady = false;
    }
  }

  Future<bool> showNewUngradedWorks(int count) async {
    if (!_isReady || count <= 0) {
      return false;
    }

    try {
      await LocalNotification(
        title: "New ungraded Classroom work",
        body: "You have $count ungraded works.",
      ).show();
      return true;
    } catch (_) {
      return false;
    }
  }
}
