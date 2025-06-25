// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tuff Image Browser';

  @override
  String get searchForImage => 'Search for a image';

  @override
  String get searchHint =>
      'Enter tags like \"kasane_teto\", \"vocaloid\", or \"anime\" to find images';

  @override
  String get search => 'Search';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get starredImages => 'Starred Images';

  @override
  String get switchToLightMode => 'Switch to Light Mode';

  @override
  String get switchToDarkMode => 'Switch to Dark Mode';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get gridColumns => 'Grid Columns';

  @override
  String get gridColumnsDescription => 'Number of columns in the image grid';

  @override
  String get showFileTypeBadges => 'Show File Type Badges';

  @override
  String get showFileTypeBadgesDescription =>
      'Display video/image badges on thumbnails';

  @override
  String get autoPlayVideos => 'Auto-play Videos';

  @override
  String get autoPlayVideosDescription =>
      'Automatically start video playback when opened';

  @override
  String get searchSettings => 'Search Settings';

  @override
  String get resultsPerPage => 'Results Per Page';

  @override
  String get resultsPerPageDescription => 'Number of images to load per page';

  @override
  String get safeSearchMode => 'Safe Search Mode';

  @override
  String get safeSearchModeDescription =>
      'Filter explicit content (recommended)';

  @override
  String get defaultSafeBooruTags => 'Default SafeBooru Tags';

  @override
  String get defaultSafeBooruTagsDescription =>
      'Default search tags for SafeBooru';

  @override
  String get defaultRule34Tags => 'Default Rule34 Tags';

  @override
  String get defaultRule34TagsDescription => 'Default search tags for Rule34';

  @override
  String get defaultYandeTags => 'Default Yande.re Tags';

  @override
  String get defaultYandeTagsDescription => 'Default search tags for Yande.re';

  @override
  String get downloadSettings => 'Download Settings';

  @override
  String get autoSaveToGallery => 'Auto-save to Gallery';

  @override
  String get autoSaveToGalleryDescriptionMobile =>
      'Automatically save images/videos to app directory and photo gallery when viewed';

  @override
  String get autoSaveToGalleryDescriptionDesktop =>
      'Automatically save images/videos to Pictures folder when viewed';

  @override
  String get appSettings => 'App Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Select your preferred language';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDescription =>
      'Vibrate when interacting with elements';

  @override
  String get incognitoMode => 'Incognito Mode';

  @override
  String get incognitoModeDescription =>
      'Don\'t save search history or starred images';

  @override
  String get english => 'English';

  @override
  String get japanese => 'Japanese';

  @override
  String get korean => 'Korean';

  @override
  String noImagesFound(String tag) {
    return 'No images found for tag: $tag';
  }

  @override
  String serverError(String code) {
    return 'Server error: $code';
  }

  @override
  String page(int pageNumber, String platform) {
    return 'Page: $pageNumber ($platform)';
  }

  @override
  String get back => 'Back';

  @override
  String get forward => 'Forward';

  @override
  String get pullNewImages => 'Pull New Images';

  @override
  String get video => 'Video';

  @override
  String get image => 'Image';

  @override
  String get enterTags => 'Enter tags...';
}
