class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.flag,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final String flag;

  String get listLabel {
    if (code == 'en') return englishName;
    return '$englishName ($nativeName)';
  }

  static const List<AppLanguage> supported = [
    AppLanguage(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    AppLanguage(
      code: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'mr',
      englishName: 'Marathi',
      nativeName: 'मराठी',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'gu',
      englishName: 'Gujarati',
      nativeName: 'ગુજરાતી',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'ta',
      englishName: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'te',
      englishName: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'kn',
      englishName: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: 'bn',
      englishName: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
    ),
  ];

  static const supportedCodes = ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'kn', 'bn'];
}
