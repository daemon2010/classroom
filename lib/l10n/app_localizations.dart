import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "app_language.dart";

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale(AppLanguage.ukrainian),
    Locale(AppLanguage.english),
    Locale(AppLanguage.russian),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static AppLocalizations forLanguageCode(String languageCode) {
    final resolved = AppLanguage.resolve(languageCode, languageCode);
    return AppLocalizations(Locale(resolved));
  }

  String get languageCode {
    return AppLanguage.resolve(locale.languageCode, locale.languageCode);
  }

  String get localeName => languageCode;

  String get appTitle => _t("appTitle");
  String get settings => _t("settings");
  String get diagnostics => _t("diagnostics");
  String get language => _t("language");
  String get languageSubtitle => _t("languageSubtitle");
  String get systemLanguage => _t("systemLanguage");
  String get english => _t("english");
  String get ukrainian => _t("ukrainian");
  String get russian => _t("russian");
  String get autoCheckTitle => _t("autoCheckTitle");
  String get autoCheckSubtitle => _t("autoCheckSubtitle");
  String get refreshInterval => _t("refreshInterval");
  String get refreshIntervalSubtitle => _t("refreshIntervalSubtitle");
  String get notifyTitle => _t("notifyTitle");
  String get notifySubtitle => _t("notifySubtitle");
  String get sendTestNotification => _t("sendTestNotification");
  String get sendTestNotificationSubtitle => _t("sendTestNotificationSubtitle");
  String get testNotificationSent => _t("testNotificationSent");
  String get testNotificationFailed => _t("testNotificationFailed");
  String get testNotificationTitle => _t("testNotificationTitle");
  String get testNotificationBody => _t("testNotificationBody");
  String get notificationsNotReady => _t("notificationsNotReady");
  String get notificationsDenied => _t("notificationsDenied");
  String get notificationCouldNotBeShown => _t("notificationCouldNotBeShown");
  String get rememberClassTitle => _t("rememberClassTitle");
  String get rememberClassSubtitle => _t("rememberClassSubtitle");
  String get showEmailColumn => _t("showEmailColumn");
  String get showLateColumn => _t("showLateColumn");
  String get adminDevelopment => _t("adminDevelopment");
  String get runConnectionCheck => _t("runConnectionCheck");
  String get connectionCheckSubtitle => _t("connectionCheckSubtitle");
  String get resetGoogleLogin => _t("resetGoogleLogin");
  String get resetGoogleLoginSubtitle => _t("resetGoogleLoginSubtitle");
  String get archivedCourses => _t("archivedCourses");
  String get archivedCoursesSubtitle => _t("archivedCoursesSubtitle");
  String get googleConnection => _t("googleConnection");
  String get configuredForThisApp => _t("configuredForThisApp");
  String get classroomWriteAccess => _t("classroomWriteAccess");
  String get noWriteOperationsWired => _t("noWriteOperationsWired");
  String get connectionCheckCompleted => _t("connectionCheckCompleted");
  String get connectionCheckFailed => _t("connectionCheckFailed");
  String get googleLoginReset => _t("googleLoginReset");
  String get googleSignInFailed => _t("googleSignInFailed");
  String get classroomCheckFailed => _t("classroomCheckFailed");
  String get csvExported => _t("csvExported");
  String get signed => _t("signed");
  String get signedIn => _t("signedIn");
  String get signIn => _t("signIn");
  String get signInWithGoogle => _t("signInWithGoogle");
  String get check => _t("check");
  String get checkNow => _t("checkNow");
  String get checking => _t("checking");
  String get export => _t("export");
  String get exportCsv => _t("exportCsv");
  String get quit => _t("quit");
  String get openReport => _t("openReport");
  String get account => _t("account");
  String get lastChecked => _t("lastChecked");
  String get now => _t("now");
  String get ungradedWorks => _t("ungradedWorks");
  String get connectAccountPrompt => _t("connectAccountPrompt");
  String get never => _t("never");
  String get checkedNow => _t("checkedNow");
  String get classLabel => _t("classLabel");
  String get allClasses => _t("allClasses");
  String get search => _t("search");
  String get searchHint => _t("searchHint");
  String get submittedYears => _t("submittedYears");
  String get displayInfoFor => _t("displayInfoFor");
  String get currentYear => _t("currentYear");
  String get allYears => _t("allYears");
  String get apply => _t("apply");
  String get yearsAll => _t("yearsAll");
  String get totalUngraded => _t("totalUngraded");
  String get classesWithUngraded => _t("classesWithUngraded");
  String get lateSubmissions => _t("lateSubmissions");
  String get noUngradedWork => _t("noUngradedWork");
  String get student => _t("student");
  String get email => _t("email");
  String get className => _t("className");
  String get subject => _t("subject");
  String get assignment => _t("assignment");
  String get state => _t("state");
  String get late => _t("late");
  String get submitted => _t("submitted");
  String get submission => _t("submission");
  String get yes => _t("yes");
  String get no => _t("no");
  String get open => _t("open");
  String get unknown => _t("unknown");
  String get newState => _t("newState");
  String get assignedState => _t("assignedState");
  String get turnedInState => _t("turnedInState");
  String get returnedState => _t("returnedState");
  String get takenBackState => _t("takenBackState");
  String get desktopShell => _t("desktopShell");
  String get menuBarTrayEnabled => _t("menuBarTrayEnabled");
  String get googleSignIn => _t("googleSignIn");
  String get browserSignInEnabled => _t("browserSignInEnabled");
  String get classroomAccess => _t("classroomAccess");
  String get classroomAccessEnabled => _t("classroomAccessEnabled");
  String get assignmentFilter => _t("assignmentFilter");
  String get assignmentFilterValue => _t("assignmentFilterValue");
  String get csvExport => _t("csvExport");
  String get csvExportEnabled => _t("csvExportEnabled");
  String get signInRequiredTooltip => _t("signInRequiredTooltip");
  String get lastCheckFailedTooltip => _t("lastCheckFailedTooltip");
  String get newUngradedNotificationTitle => _t("newUngradedNotificationTitle");

  String languageName(String code) {
    return switch (AppLanguage.normalizeSetting(code)) {
      AppLanguage.system => systemLanguage,
      AppLanguage.ukrainian => ukrainian,
      AppLanguage.russian => russian,
      _ => english,
    };
  }

  String signedInAsNameEmail(String name, String email) {
    return _f("signedInAsNameEmail", {"name": name, "email": email});
  }

  String signedInAsName(String name) {
    return _f("signedInAsName", {"name": name});
  }

  String signedInAsEmail(String email) {
    return _f("signedInAsEmail", {"email": email});
  }

  String minutesAgo(int minutes) {
    return _f("minutesAgo", {"count": minutes.toString()});
  }

  String everyMinutes(int minutes) {
    return _f("everyMinutes", {"count": minutes.toString()});
  }

  String hoursAgo(int hours) {
    return _f("hoursAgo", {"count": hours.toString()});
  }

  String ungradedWorksCount(int count) {
    return _f("ungradedWorksCount", {"count": count.toString()});
  }

  String lastCheckedValue(String value) {
    return _f("lastCheckedValue", {"value": value});
  }

  String signedInAsTray(String name) {
    return _f("signedInAsTray", {"name": name});
  }

  String trayTooltip(int count, String checkedAt) {
    return _f("trayTooltip", {
      "count": count.toString(),
      "checkedAt": checkedAt,
    });
  }

  String notificationBody(int count) {
    return _f("notificationBody", {"count": count.toString()});
  }

  String yearLabel(int year) {
    return _f("yearLabel", {"year": year.toString()});
  }

  String yearsList(String years) {
    return _f("yearsList", {"years": years});
  }

  String _t(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues[AppLanguage.english]![key] ??
        key;
  }

  String _f(String key, Map<String, String> values) {
    var text = _t(key);
    for (final entry in values.entries) {
      text = text.replaceAll("{${entry.key}}", entry.value);
    }
    return text;
  }

  static const _localizedValues = {
    AppLanguage.english: {
      "appTitle": "Classroom Ungraded Checker",
      "settings": "Settings",
      "diagnostics": "Diagnostics",
      "language": "Language",
      "languageSubtitle": "Use your computer language or choose one here",
      "systemLanguage": "System language",
      "english": "English",
      "ukrainian": "Ukrainian",
      "russian": "Russian",
      "autoCheckTitle": "Check automatically",
      "autoCheckSubtitle": "Updates the menu bar count",
      "refreshInterval": "Check interval",
      "refreshIntervalSubtitle": "How often automatic checks run",
      "notifyTitle": "Notify when new ungraded works appear",
      "notifySubtitle": "Only when the count increases",
      "sendTestNotification": "Send test notification",
      "sendTestNotificationSubtitle":
          "Checks whether this computer can show app notifications",
      "testNotificationSent": "Test notification sent.",
      "testNotificationFailed": "Test notification could not be shown.",
      "testNotificationTitle": "Classroom notification test",
      "testNotificationBody":
          "Notifications are working for Classroom Ungraded Checker.",
      "notificationsNotReady": "Notifications are not ready yet.",
      "notificationsDenied":
          "Notifications are disabled for this app. Allow them in System Settings.",
      "notificationCouldNotBeShown":
          "Notification could not be shown. Check System Settings notifications for this app.",
      "rememberClassTitle": "Remember last selected class",
      "rememberClassSubtitle": "Restore the class filter next time",
      "showEmailColumn": "Show student email column",
      "showLateColumn": "Show late column",
      "adminDevelopment": "Admin and development",
      "runConnectionCheck": "Run connection check",
      "connectionCheckSubtitle": "Checks Google Classroom access",
      "resetGoogleLogin": "Reset Google login",
      "resetGoogleLoginSubtitle": "Sign in again with Google",
      "archivedCourses": "Archived courses",
      "archivedCoursesSubtitle": "Disabled while Classroom checks are pending",
      "googleConnection": "Google connection",
      "configuredForThisApp": "Configured for this app",
      "classroomWriteAccess": "Classroom write access",
      "noWriteOperationsWired": "No write operations are wired",
      "connectionCheckCompleted": "Connection check completed.",
      "connectionCheckFailed": "Connection check could not finish.",
      "googleLoginReset": "Google login has been reset.",
      "googleSignInFailed": "Google sign-in could not finish.",
      "classroomCheckFailed": "Classroom check could not finish.",
      "csvExported": "CSV exported successfully.",
      "signed": "Signed",
      "signedIn": "Signed in",
      "signIn": "Sign in",
      "signInWithGoogle": "Sign in with Google",
      "check": "Check",
      "checkNow": "Check Now",
      "checking": "Checking...",
      "export": "Export",
      "exportCsv": "Export CSV",
      "quit": "Quit",
      "openReport": "Open Report",
      "account": "Account",
      "lastChecked": "Last checked",
      "now": "Now",
      "ungradedWorks": "Ungraded works",
      "connectAccountPrompt":
          "Connect your Google account to check ungraded Classroom work.",
      "never": "never",
      "checkedNow": "now",
      "classLabel": "Class",
      "allClasses": "All classes",
      "search": "Search",
      "searchHint": "Student, class, subject, or assignment",
      "submittedYears": "Submitted years",
      "displayInfoFor": "Display information for",
      "currentYear": "Current year",
      "allYears": "All years",
      "apply": "Apply",
      "yearsAll": "Years: all",
      "totalUngraded": "Total ungraded",
      "classesWithUngraded": "Classes with ungraded works",
      "lateSubmissions": "Late submissions",
      "noUngradedWork": "No ungraded Classroom work to show.",
      "student": "Student",
      "email": "Email",
      "className": "Class",
      "subject": "Subject",
      "assignment": "Assignment",
      "state": "State",
      "late": "Late",
      "submitted": "Submitted",
      "submission": "Submission",
      "yes": "Yes",
      "no": "No",
      "open": "Open",
      "unknown": "Unknown",
      "newState": "New",
      "assignedState": "Assigned",
      "turnedInState": "Turned in",
      "returnedState": "Returned",
      "takenBackState": "Taken back",
      "desktopShell": "Desktop shell",
      "menuBarTrayEnabled": "Menu bar/tray enabled",
      "googleSignIn": "Google sign-in",
      "browserSignInEnabled": "Browser sign-in enabled",
      "classroomAccess": "Classroom access",
      "classroomAccessEnabled":
          "Profile, classes, topics, assignments, and submissions enabled",
      "assignmentFilter": "Assignment filter",
      "assignmentFilterValue": "Only assignments created by this teacher",
      "csvExport": "CSV export",
      "csvExportEnabled": "Desktop save dialog enabled",
      "signInRequiredTooltip": "Classroom Ungraded Checker - Sign in required",
      "lastCheckFailedTooltip": "Last check failed. Open app for details.",
      "newUngradedNotificationTitle": "New ungraded Classroom work",
      "signedInAsNameEmail": "Signed in as: {name} <{email}>",
      "signedInAsName": "Signed in as: {name}",
      "signedInAsEmail": "Signed in as: {email}",
      "minutesAgo": "{count} min ago",
      "everyMinutes": "Every {count} minutes",
      "hoursAgo": "{count} hr ago",
      "ungradedWorksCount": "Ungraded works: {count}",
      "lastCheckedValue": "Last checked: {value}",
      "signedInAsTray": "Signed in as {name}",
      "trayTooltip": "Ungraded works: {count}. Last checked: {checkedAt}",
      "notificationBody": "You have {count} ungraded works.",
      "yearLabel": "Year: {year}",
      "yearsList": "Years: {years}",
    },
    AppLanguage.ukrainian: {
      "appTitle": "Перевірка неоцінених робіт Classroom",
      "settings": "Налаштування",
      "diagnostics": "Діагностика",
      "language": "Мова",
      "languageSubtitle": "Використовувати мову комп'ютера або вибрати тут",
      "systemLanguage": "Системна мова",
      "english": "Англійська",
      "ukrainian": "Українська",
      "russian": "Російська",
      "autoCheckTitle": "Перевіряти автоматично",
      "autoCheckSubtitle": "Оновлює лічильник у меню",
      "refreshInterval": "Інтервал перевірки",
      "refreshIntervalSubtitle": "Як часто виконуються автоматичні перевірки",
      "notifyTitle": "Сповіщати про нові неоцінені роботи",
      "notifySubtitle": "Лише коли кількість зростає",
      "sendTestNotification": "Надіслати тестове сповіщення",
      "sendTestNotificationSubtitle":
          "Перевіряє, чи комп'ютер може показувати сповіщення застосунку",
      "testNotificationSent": "Тестове сповіщення надіслано.",
      "testNotificationFailed": "Не вдалося показати тестове сповіщення.",
      "testNotificationTitle": "Тест сповіщень Classroom",
      "testNotificationBody":
          "Сповіщення для Перевірки неоцінених робіт Classroom працюють.",
      "notificationsNotReady": "Сповіщення ще не готові.",
      "notificationsDenied":
          "Сповіщення вимкнені для цього застосунку. Дозвольте їх у Системних налаштуваннях.",
      "notificationCouldNotBeShown":
          "Не вдалося показати сповіщення. Перевірте сповіщення для цього застосунку в Системних налаштуваннях.",
      "rememberClassTitle": "Запам'ятовувати останній вибраний клас",
      "rememberClassSubtitle": "Відновити фільтр класу наступного разу",
      "showEmailColumn": "Показувати стовпець email студента",
      "showLateColumn": "Показувати стовпець запізнення",
      "adminDevelopment": "Адміністрування та розробка",
      "runConnectionCheck": "Перевірити підключення",
      "connectionCheckSubtitle": "Перевіряє доступ до Google Classroom",
      "resetGoogleLogin": "Скинути вхід Google",
      "resetGoogleLoginSubtitle": "Увійти в Google ще раз",
      "archivedCourses": "Архівні курси",
      "archivedCoursesSubtitle": "Вимкнено, поки перевірки Classroom у черзі",
      "googleConnection": "Підключення Google",
      "configuredForThisApp": "Налаштовано для цього застосунку",
      "classroomWriteAccess": "Доступ на запис у Classroom",
      "noWriteOperationsWired": "Дії запису не підключені",
      "connectionCheckCompleted": "Перевірку підключення завершено.",
      "connectionCheckFailed": "Не вдалося завершити перевірку підключення.",
      "googleLoginReset": "Вхід Google скинуто.",
      "googleSignInFailed": "Не вдалося завершити вхід Google.",
      "classroomCheckFailed": "Не вдалося завершити перевірку Classroom.",
      "csvExported": "CSV успішно експортовано.",
      "signed": "Увійшли",
      "signedIn": "Вхід виконано",
      "signIn": "Увійти",
      "signInWithGoogle": "Увійти через Google",
      "check": "Перевірити",
      "checkNow": "Перевірити зараз",
      "checking": "Перевірка...",
      "export": "Експорт",
      "exportCsv": "Експорт CSV",
      "quit": "Вийти",
      "openReport": "Відкрити звіт",
      "account": "Акаунт",
      "lastChecked": "Остання перевірка",
      "now": "Зараз",
      "ungradedWorks": "Неоцінені роботи",
      "connectAccountPrompt":
          "Підключіть Google-акаунт, щоб перевірити неоцінені роботи Classroom.",
      "never": "ніколи",
      "checkedNow": "щойно",
      "classLabel": "Клас",
      "allClasses": "Усі класи",
      "search": "Пошук",
      "searchHint": "Студент, клас, тема або завдання",
      "submittedYears": "Роки здачі",
      "displayInfoFor": "Показувати інформацію за",
      "currentYear": "Поточний рік",
      "allYears": "Усі роки",
      "apply": "Застосувати",
      "yearsAll": "Роки: усі",
      "totalUngraded": "Усього неоцінених",
      "classesWithUngraded": "Класи з неоціненими роботами",
      "lateSubmissions": "Здано із запізненням",
      "noUngradedWork": "Немає неоцінених робіт Classroom для показу.",
      "student": "Студент",
      "email": "Email",
      "className": "Клас",
      "subject": "Тема",
      "assignment": "Завдання",
      "state": "Стан",
      "late": "Запізнення",
      "submitted": "Здано",
      "submission": "Робота",
      "yes": "Так",
      "no": "Ні",
      "open": "Відкрити",
      "unknown": "Невідомо",
      "newState": "Нове",
      "assignedState": "Призначено",
      "turnedInState": "Здано",
      "returnedState": "Повернено",
      "takenBackState": "Забрано назад",
      "desktopShell": "Робочий стіл",
      "menuBarTrayEnabled": "Меню/трей увімкнено",
      "googleSignIn": "Вхід Google",
      "browserSignInEnabled": "Вхід через браузер увімкнено",
      "classroomAccess": "Доступ Classroom",
      "classroomAccessEnabled":
          "Профіль, класи, теми, завдання та роботи увімкнені",
      "assignmentFilter": "Фільтр завдань",
      "assignmentFilterValue": "Лише завдання, створені цим викладачем",
      "csvExport": "Експорт CSV",
      "csvExportEnabled": "Увімкнено вікно збереження",
      "signInRequiredTooltip":
          "Перевірка неоцінених робіт Classroom - потрібен вхід",
      "lastCheckFailedTooltip":
          "Остання перевірка не вдалася. Відкрийте застосунок.",
      "newUngradedNotificationTitle": "Нові неоцінені роботи Classroom",
      "signedInAsNameEmail": "Вхід виконано: {name} <{email}>",
      "signedInAsName": "Вхід виконано: {name}",
      "signedInAsEmail": "Вхід виконано: {email}",
      "minutesAgo": "{count} хв тому",
      "everyMinutes": "Кожні {count} хв",
      "hoursAgo": "{count} год тому",
      "ungradedWorksCount": "Неоцінені роботи: {count}",
      "lastCheckedValue": "Остання перевірка: {value}",
      "signedInAsTray": "Вхід: {name}",
      "trayTooltip":
          "Неоцінені роботи: {count}. Остання перевірка: {checkedAt}",
      "notificationBody": "У вас {count} неоцінених робіт.",
      "yearLabel": "Рік: {year}",
      "yearsList": "Роки: {years}",
    },
    AppLanguage.russian: {
      "appTitle": "Проверка неоцененных работ Classroom",
      "settings": "Настройки",
      "diagnostics": "Диагностика",
      "language": "Язык",
      "languageSubtitle": "Использовать язык компьютера или выбрать здесь",
      "systemLanguage": "Системный язык",
      "english": "Английский",
      "ukrainian": "Украинский",
      "russian": "Русский",
      "autoCheckTitle": "Проверять автоматически",
      "autoCheckSubtitle": "Обновляет счетчик в меню",
      "refreshInterval": "Интервал проверки",
      "refreshIntervalSubtitle":
          "Как часто выполняются автоматические проверки",
      "notifyTitle": "Уведомлять о новых неоцененных работах",
      "notifySubtitle": "Только когда количество увеличивается",
      "sendTestNotification": "Отправить тестовое уведомление",
      "sendTestNotificationSubtitle":
          "Проверяет, может ли компьютер показывать уведомления приложения",
      "testNotificationSent": "Тестовое уведомление отправлено.",
      "testNotificationFailed": "Не удалось показать тестовое уведомление.",
      "testNotificationTitle": "Тест уведомлений Classroom",
      "testNotificationBody":
          "Уведомления для Проверки неоцененных работ Classroom работают.",
      "notificationsNotReady": "Уведомления еще не готовы.",
      "notificationsDenied":
          "Уведомления отключены для этого приложения. Разрешите их в Системных настройках.",
      "notificationCouldNotBeShown":
          "Не удалось показать уведомление. Проверьте уведомления для этого приложения в Системных настройках.",
      "rememberClassTitle": "Запоминать последний выбранный класс",
      "rememberClassSubtitle": "Восстановить фильтр класса в следующий раз",
      "showEmailColumn": "Показывать столбец email студента",
      "showLateColumn": "Показывать столбец опоздания",
      "adminDevelopment": "Администрирование и разработка",
      "runConnectionCheck": "Проверить подключение",
      "connectionCheckSubtitle": "Проверяет доступ к Google Classroom",
      "resetGoogleLogin": "Сбросить вход Google",
      "resetGoogleLoginSubtitle": "Войти в Google заново",
      "archivedCourses": "Архивные курсы",
      "archivedCoursesSubtitle": "Отключено, пока проверки Classroom в очереди",
      "googleConnection": "Подключение Google",
      "configuredForThisApp": "Настроено для этого приложения",
      "classroomWriteAccess": "Доступ на запись в Classroom",
      "noWriteOperationsWired": "Действия записи не подключены",
      "connectionCheckCompleted": "Проверка подключения завершена.",
      "connectionCheckFailed": "Не удалось завершить проверку подключения.",
      "googleLoginReset": "Вход Google сброшен.",
      "googleSignInFailed": "Не удалось завершить вход Google.",
      "classroomCheckFailed": "Не удалось завершить проверку Classroom.",
      "csvExported": "CSV успешно экспортирован.",
      "signed": "Вошли",
      "signedIn": "Вход выполнен",
      "signIn": "Войти",
      "signInWithGoogle": "Войти через Google",
      "check": "Проверить",
      "checkNow": "Проверить сейчас",
      "checking": "Проверка...",
      "export": "Экспорт",
      "exportCsv": "Экспорт CSV",
      "quit": "Выйти",
      "openReport": "Открыть отчет",
      "account": "Аккаунт",
      "lastChecked": "Последняя проверка",
      "now": "Сейчас",
      "ungradedWorks": "Неоцененные работы",
      "connectAccountPrompt":
          "Подключите Google-аккаунт, чтобы проверить неоцененные работы Classroom.",
      "never": "никогда",
      "checkedNow": "только что",
      "classLabel": "Класс",
      "allClasses": "Все классы",
      "search": "Поиск",
      "searchHint": "Студент, класс, тема или задание",
      "submittedYears": "Годы сдачи",
      "displayInfoFor": "Показывать информацию за",
      "currentYear": "Текущий год",
      "allYears": "Все годы",
      "apply": "Применить",
      "yearsAll": "Годы: все",
      "totalUngraded": "Всего неоцененных",
      "classesWithUngraded": "Классы с неоцененными работами",
      "lateSubmissions": "Сдано с опозданием",
      "noUngradedWork": "Нет неоцененных работ Classroom для показа.",
      "student": "Студент",
      "email": "Email",
      "className": "Класс",
      "subject": "Тема",
      "assignment": "Задание",
      "state": "Состояние",
      "late": "Опоздание",
      "submitted": "Сдано",
      "submission": "Работа",
      "yes": "Да",
      "no": "Нет",
      "open": "Открыть",
      "unknown": "Неизвестно",
      "newState": "Новое",
      "assignedState": "Назначено",
      "turnedInState": "Сдано",
      "returnedState": "Возвращено",
      "takenBackState": "Забрано назад",
      "desktopShell": "Рабочий стол",
      "menuBarTrayEnabled": "Меню/трей включены",
      "googleSignIn": "Вход Google",
      "browserSignInEnabled": "Вход через браузер включен",
      "classroomAccess": "Доступ Classroom",
      "classroomAccessEnabled":
          "Профиль, классы, темы, задания и работы включены",
      "assignmentFilter": "Фильтр заданий",
      "assignmentFilterValue": "Только задания, созданные этим преподавателем",
      "csvExport": "Экспорт CSV",
      "csvExportEnabled": "Окно сохранения включено",
      "signInRequiredTooltip":
          "Проверка неоцененных работ Classroom - требуется вход",
      "lastCheckFailedTooltip":
          "Последняя проверка не удалась. Откройте приложение.",
      "newUngradedNotificationTitle": "Новые неоцененные работы Classroom",
      "signedInAsNameEmail": "Вход выполнен: {name} <{email}>",
      "signedInAsName": "Вход выполнен: {name}",
      "signedInAsEmail": "Вход выполнен: {email}",
      "minutesAgo": "{count} мин назад",
      "everyMinutes": "Каждые {count} мин",
      "hoursAgo": "{count} ч назад",
      "ungradedWorksCount": "Неоцененные работы: {count}",
      "lastCheckedValue": "Последняя проверка: {value}",
      "signedInAsTray": "Вход: {name}",
      "trayTooltip":
          "Неоцененные работы: {count}. Последняя проверка: {checkedAt}",
      "notificationBody": "У вас {count} неоцененных работ.",
      "yearLabel": "Год: {year}",
      "yearsList": "Годы: {years}",
    },
  };
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.supportedLocales.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final languageCode =
        AppLanguage.supportedLocales.contains(locale.languageCode)
        ? locale.languageCode
        : AppLanguage.english;
    return SynchronousFuture(AppLocalizations(Locale(languageCode)));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
