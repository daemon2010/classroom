class AppLanguage {
  const AppLanguage._();

  static const system = "system";
  static const english = "en";
  static const ukrainian = "uk";
  static const russian = "ru";

  static const settingsValues = [system, english, ukrainian, russian];
  static const supportedLocales = [english, ukrainian, russian];

  static String normalizeSetting(String? value) {
    final clean = value?.trim().toLowerCase();
    if (clean == null || clean.isEmpty) {
      return ukrainian;
    }
    if (settingsValues.contains(clean)) {
      return clean;
    }
    return ukrainian;
  }

  static String resolve(String setting, String systemLanguageCode) {
    final normalizedSetting = normalizeSetting(setting);
    if (normalizedSetting != system) {
      return normalizedSetting;
    }

    final cleanSystemLanguage = systemLanguageCode.trim().toLowerCase();
    return supportedLocales.contains(cleanSystemLanguage)
        ? cleanSystemLanguage
        : ukrainian;
  }
}
