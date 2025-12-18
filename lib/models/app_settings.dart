// Instellingen model voor app configuratie
class AppSettings {
  final int gridColumns;
  final bool autoPlayVideos;
  final bool showFileTypeBadges;
  final bool autoSaveToGallery;
  final bool hapticFeedback;
  final int resultsPerPage;
  final bool safeSearchMode;
  final String defaultSafeBooruTags;
  final String defaultRule34Tags;
  final String defaultYandeTags;
  final bool showSearchHistory;
  final bool incognitoMode;
  final String language;
  final String rule34ApiKey;
  final String rule34UserId;

  const AppSettings({
    this.gridColumns = 2,
    this.autoPlayVideos = false,
    this.showFileTypeBadges = true,
    this.autoSaveToGallery = false,
    this.hapticFeedback = true,
    this.resultsPerPage = 20,
    this.safeSearchMode = true,
    this.defaultSafeBooruTags = '',
    this.defaultRule34Tags = '',
    this.defaultYandeTags = '',
    this.showSearchHistory = true,
    this.incognitoMode = false,
    this.language = 'en',
    this.rule34ApiKey = '',
    this.rule34UserId = '',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      gridColumns: json['gridColumns'] ?? 2,
      autoPlayVideos: json['autoPlayVideos'] ?? false,
      showFileTypeBadges: json['showFileTypeBadges'] ?? true,
      autoSaveToGallery: json['autoSaveToGallery'] ?? false,
      hapticFeedback: json['hapticFeedback'] ?? true,
      resultsPerPage: json['resultsPerPage'] ?? 20,
      safeSearchMode: json['safeSearchMode'] ?? true,
      defaultSafeBooruTags: json['defaultSafeBooruTags'] ?? '',
      defaultRule34Tags: json['defaultRule34Tags'] ?? '',
      defaultYandeTags: json['defaultYandeTags'] ?? '',
      showSearchHistory: json['showSearchHistory'] ?? true,
      incognitoMode: json['incognitoMode'] ?? false,
      language: json['language'] ?? 'en',
      rule34ApiKey: json['rule34ApiKey'] ?? '',
      rule34UserId: json['rule34UserId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gridColumns': gridColumns,
      'autoPlayVideos': autoPlayVideos,
      'showFileTypeBadges': showFileTypeBadges,
      'autoSaveToGallery': autoSaveToGallery,
      'hapticFeedback': hapticFeedback,
      'resultsPerPage': resultsPerPage,
      'safeSearchMode': safeSearchMode,
      'defaultSafeBooruTags': defaultSafeBooruTags,
      'defaultRule34Tags': defaultRule34Tags,
      'defaultYandeTags': defaultYandeTags,
      'showSearchHistory': showSearchHistory,
      'incognitoMode': incognitoMode,
      'language': language,
      'rule34ApiKey': rule34ApiKey,
      'rule34UserId': rule34UserId,
    };
  }

  AppSettings copyWith({
    int? gridColumns,
    bool? autoPlayVideos,
    bool? showFileTypeBadges,
    bool? autoSaveToGallery,
    bool? hapticFeedback,
    int? resultsPerPage,
    bool? safeSearchMode,
    String? defaultSafeBooruTags,
    String? defaultRule34Tags,
    String? defaultYandeTags,
    bool? showSearchHistory,
    bool? incognitoMode,
    String? language,
    String? rule34ApiKey,
    String? rule34UserId,
  }) {
    return AppSettings(
      gridColumns: gridColumns ?? this.gridColumns,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      showFileTypeBadges: showFileTypeBadges ?? this.showFileTypeBadges,
      autoSaveToGallery: autoSaveToGallery ?? this.autoSaveToGallery,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      resultsPerPage: resultsPerPage ?? this.resultsPerPage,
      safeSearchMode: safeSearchMode ?? this.safeSearchMode,
      defaultSafeBooruTags: defaultSafeBooruTags ?? this.defaultSafeBooruTags,
      defaultRule34Tags: defaultRule34Tags ?? this.defaultRule34Tags,
      defaultYandeTags: defaultYandeTags ?? this.defaultYandeTags,
      showSearchHistory: showSearchHistory ?? this.showSearchHistory,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      language: language ?? this.language,
      rule34ApiKey: rule34ApiKey ?? this.rule34ApiKey,
      rule34UserId: rule34UserId ?? this.rule34UserId,
    );
  }
}
