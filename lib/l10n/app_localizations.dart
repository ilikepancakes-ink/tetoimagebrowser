import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Tuff Image Browser'**
  String get appTitle;

  /// Placeholder text for search input
  ///
  /// In en, this message translates to:
  /// **'Search for a image'**
  String get searchForImage;

  /// Hint text for search functionality
  ///
  /// In en, this message translates to:
  /// **'Enter tags like \"kasane_teto\", \"vocaloid\", or \"anime\" to find images'**
  String get searchHint;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Home button text
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings tab and page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// History button text
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Starred images button text
  ///
  /// In en, this message translates to:
  /// **'Starred Images'**
  String get starredImages;

  /// Tooltip for light mode button
  ///
  /// In en, this message translates to:
  /// **'Switch to Light Mode'**
  String get switchToLightMode;

  /// Tooltip for dark mode button
  ///
  /// In en, this message translates to:
  /// **'Switch to Dark Mode'**
  String get switchToDarkMode;

  /// Display settings section title
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// Grid columns setting title
  ///
  /// In en, this message translates to:
  /// **'Grid Columns'**
  String get gridColumns;

  /// Grid columns setting description
  ///
  /// In en, this message translates to:
  /// **'Number of columns in the image grid'**
  String get gridColumnsDescription;

  /// File type badges setting title
  ///
  /// In en, this message translates to:
  /// **'Show File Type Badges'**
  String get showFileTypeBadges;

  /// File type badges setting description
  ///
  /// In en, this message translates to:
  /// **'Display video/image badges on thumbnails'**
  String get showFileTypeBadgesDescription;

  /// Auto-play videos setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-play Videos'**
  String get autoPlayVideos;

  /// Auto-play videos setting description
  ///
  /// In en, this message translates to:
  /// **'Automatically start video playback when opened'**
  String get autoPlayVideosDescription;

  /// Search settings section title
  ///
  /// In en, this message translates to:
  /// **'Search Settings'**
  String get searchSettings;

  /// Results per page setting title
  ///
  /// In en, this message translates to:
  /// **'Results Per Page'**
  String get resultsPerPage;

  /// Results per page setting description
  ///
  /// In en, this message translates to:
  /// **'Number of images to load per page'**
  String get resultsPerPageDescription;

  /// Safe search mode setting title
  ///
  /// In en, this message translates to:
  /// **'Safe Search Mode'**
  String get safeSearchMode;

  /// Safe search mode setting description
  ///
  /// In en, this message translates to:
  /// **'Filter explicit content (recommended)'**
  String get safeSearchModeDescription;

  /// Default SafeBooru tags setting title
  ///
  /// In en, this message translates to:
  /// **'Default SafeBooru Tags'**
  String get defaultSafeBooruTags;

  /// Default SafeBooru tags setting description
  ///
  /// In en, this message translates to:
  /// **'Default search tags for SafeBooru'**
  String get defaultSafeBooruTagsDescription;

  /// Default Rule34 tags setting title
  ///
  /// In en, this message translates to:
  /// **'Default Rule34 Tags'**
  String get defaultRule34Tags;

  /// Default Rule34 tags setting description
  ///
  /// In en, this message translates to:
  /// **'Default search tags for Rule34'**
  String get defaultRule34TagsDescription;

  /// Default Yande.re tags setting title
  ///
  /// In en, this message translates to:
  /// **'Default Yande.re Tags'**
  String get defaultYandeTags;

  /// Default Yande.re tags setting description
  ///
  /// In en, this message translates to:
  /// **'Default search tags for Yande.re'**
  String get defaultYandeTagsDescription;

  /// Download settings section title
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get downloadSettings;

  /// Auto-save to gallery setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-save to Gallery'**
  String get autoSaveToGallery;

  /// Auto-save to gallery setting description for mobile
  ///
  /// In en, this message translates to:
  /// **'Automatically save images/videos to app directory and photo gallery when viewed'**
  String get autoSaveToGalleryDescriptionMobile;

  /// Auto-save to gallery setting description for desktop
  ///
  /// In en, this message translates to:
  /// **'Automatically save images/videos to Pictures folder when viewed'**
  String get autoSaveToGalleryDescriptionDesktop;

  /// App settings section title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting description
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languageDescription;

  /// Haptic feedback setting title
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic feedback setting description
  ///
  /// In en, this message translates to:
  /// **'Vibrate when interacting with elements'**
  String get hapticFeedbackDescription;

  /// Incognito mode setting title
  ///
  /// In en, this message translates to:
  /// **'Incognito Mode'**
  String get incognitoMode;

  /// Incognito mode setting description
  ///
  /// In en, this message translates to:
  /// **'Don\'t save search history or starred images'**
  String get incognitoModeDescription;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Korean language option
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// Message when no images are found
  ///
  /// In en, this message translates to:
  /// **'No images found for tag: {tag}'**
  String noImagesFound(String tag);

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error: {code}'**
  String serverError(String code);

  /// Page indicator text
  ///
  /// In en, this message translates to:
  /// **'Page: {pageNumber} ({platform})'**
  String page(int pageNumber, String platform);

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Forward button text
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// Pull new images button text
  ///
  /// In en, this message translates to:
  /// **'Pull New Images'**
  String get pullNewImages;

  /// Video file type label
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// Image file type label
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Placeholder text for tag input fields
  ///
  /// In en, this message translates to:
  /// **'Enter tags...'**
  String get enterTags;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
