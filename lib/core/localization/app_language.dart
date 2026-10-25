/// Supported languages for HerCare.
enum AppLanguage {
  en('en', 'English', 'Default application language'),
  vi('vi', 'Tiếng Việt', 'Giao diện và gợi ý chăm sóc bằng tiếng Việt');

  final String code;
  final String nativeName;
  final String subtitle;

  const AppLanguage(this.code, this.nativeName, this.subtitle);

  static AppLanguage fromCode(String? code) {
    if (code == 'vi') return AppLanguage.vi;
    return AppLanguage.en;
  }
}

