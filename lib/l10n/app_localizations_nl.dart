// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Tuff Image Browser';

  @override
  String get searchForImage => 'Zoek naar een afbeelding';

  @override
  String get searchHint =>
      'Voer tags in zoals \"kasane_teto\", \"vocaloid\", of \"anime\" om afbeeldingen te vinden';

  @override
  String get search => 'Zoeken';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Instellingen';

  @override
  String get history => 'Geschiedenis';

  @override
  String get starredImages => 'Favoriete Afbeeldingen';

  @override
  String get switchToLightMode => 'Omschakelen naar Licht Modus';

  @override
  String get switchToDarkMode => 'Omschakelen naar Donker Modus';

  @override
  String get displaySettings => 'Weergave Instellingen';

  @override
  String get gridColumns => 'Raster Kolommen';

  @override
  String get gridColumnsDescription =>
      'Aantal kolommen in het afbeeldingsraster';

  @override
  String get showFileTypeBadges => 'Toon Bestandstype Badges';

  @override
  String get showFileTypeBadgesDescription =>
      'Toon video/afbeelding badges op miniaturen';

  @override
  String get autoPlayVideos => 'Automatisch Video\'s Afspelen';

  @override
  String get autoPlayVideosDescription =>
      'Automatisch video afspelen starten wanneer geopend';

  @override
  String get searchSettings => 'Zoek Instellingen';

  @override
  String get resultsPerPage => 'Resultaten Per Pagina';

  @override
  String get resultsPerPageDescription =>
      'Aantal afbeeldingen om per pagina te laden';

  @override
  String get safeSearchMode => 'Veilig Zoeken Modus';

  @override
  String get safeSearchModeDescription =>
      'Expliciete inhoud filteren (aanbevolen)';

  @override
  String get defaultSafeBooruTags => 'Standaard SafeBooru Tags';

  @override
  String get defaultSafeBooruTagsDescription =>
      'Standaard zoek tags voor SafeBooru';

  @override
  String get defaultRule34Tags => 'Standaard Rule34 Tags';

  @override
  String get defaultRule34TagsDescription => 'Standaard zoek tags voor Rule34';

  @override
  String get defaultYandeTags => 'Standaard Yande.re Tags';

  @override
  String get defaultYandeTagsDescription => 'Standaard zoek tags voor Yande.re';

  @override
  String get downloadSettings => 'Download Instellingen';

  @override
  String get autoSaveToGallery => 'Automatisch Opslaan naar Galerij';

  @override
  String get autoSaveToGalleryDescriptionMobile =>
      'Automatisch afbeeldingen/video\'s opslaan naar app directory en fotogalerij wanneer bekeken';

  @override
  String get autoSaveToGalleryDescriptionDesktop =>
      'Automatisch afbeeldingen/video\'s opslaan naar Afbeeldingen map wanneer bekeken';

  @override
  String get appSettings => 'App Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get languageDescription => 'Selecteer uw voorkeurstaal';

  @override
  String get hapticFeedback => 'Haptische Feedback';

  @override
  String get hapticFeedbackDescription =>
      'Trillen bij interactie met elementen';

  @override
  String get incognitoMode => 'Incognito Modus';

  @override
  String get incognitoModeDescription =>
      'Zoekgeschiedenis of favoriete afbeeldingen niet opslaan';

  @override
  String get english => 'Engels';

  @override
  String get japanese => 'Japans';

  @override
  String get korean => 'Koreaans';

  @override
  String get dutch => 'Nederlands';

  @override
  String noImagesFound(String tag) {
    return 'Geen afbeeldingen gevonden voor tag: $tag';
  }

  @override
  String serverError(String code) {
    return 'Server fout: $code';
  }

  @override
  String page(int pageNumber, String platform) {
    return 'Pagina: $pageNumber ($platform)';
  }

  @override
  String get back => 'Terug';

  @override
  String get forward => 'Vooruit';

  @override
  String get pullNewImages => 'Nieuwe Afbeeldingen Ophalen';

  @override
  String get video => 'Video';

  @override
  String get image => 'Afbeelding';

  @override
  String get enterTags => 'Tags invoeren...';
}
