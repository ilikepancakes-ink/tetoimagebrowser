import 'package:flutter/material.dart';

// Eenvoudige lokalisatie hulpklasse
class CustomLocalizations {
  final String languageCode;

  CustomLocalizations(this.languageCode);

  static CustomLocalizations of(BuildContext context) {
    return Localizations.of(context, CustomLocalizations) ?? CustomLocalizations('en');
  }

  static const LocalizationsDelegate<CustomLocalizations> delegate = _CustomLocalizationsDelegate();

  Map<String, String> get _localizedStrings {
    switch (languageCode) {
      case 'ja':
        return _japaneseStrings;
      case 'ko':
        return _koreanStrings;
      case 'nl':
        return _dutchStrings;
      default:
        return _englishStrings;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Engelse strings (origineel behouden)
  static const Map<String, String> _englishStrings = {
    'appTitle': 'Tuff Image Browser',
    'searchForImage': 'Search for a image',
    'searchHint': 'Enter tags like "kasane_teto", "vocaloid", or "anime" to find images',
    'search': 'Search',
    'home': 'Home',
    'settings': 'Settings',
    'history': 'History',
    'starredImages': 'Starred Images',
    'switchToLightMode': 'Switch to Light Mode',
    'switchToDarkMode': 'Switch to Dark Mode',
    'displaySettings': 'Display Settings',
    'gridColumns': 'Grid Columns',
    'gridColumnsDescription': 'Number of columns in the image grid',
    'showFileTypeBadges': 'Show File Type Badges',
    'showFileTypeBadgesDescription': 'Display video/image badges on thumbnails',
    'autoPlayVideos': 'Auto-play Videos',
    'autoPlayVideosDescription': 'Automatically start video playback when opened',
    'searchSettings': 'Search Settings',
    'resultsPerPage': 'Results Per Page',
    'resultsPerPageDescription': 'Number of images to load per page',
    'safeSearchMode': 'Safe Search Mode',
    'safeSearchModeDescription': 'Filter explicit content (recommended)',
    'defaultSafeBooruTags': 'Default SafeBooru Tags',
    'defaultSafeBooruTagsDescription': 'Default search tags for SafeBooru',
    'defaultRule34Tags': 'Default Rule34 Tags',
    'defaultRule34TagsDescription': 'Default search tags for Rule34',
    'defaultYandeTags': 'Default Yande.re Tags',
    'defaultYandeTagsDescription': 'Default search tags for Yande.re',
    'downloadSettings': 'Download Settings',
    'autoSaveToGallery': 'Auto-save to Gallery',
    'autoSaveToGalleryDescriptionMobile': 'Automatically save images/videos to app directory and photo gallery when viewed',
    'autoSaveToGalleryDescriptionDesktop': 'Automatically save images/videos to Pictures folder when viewed',
    'appSettings': 'App Settings',
    'language': 'Language',
    'languageDescription': 'Select your preferred language',
    'hapticFeedback': 'Haptic Feedback',
    'hapticFeedbackDescription': 'Vibrate when interacting with elements',
    'incognitoMode': 'Incognito Mode',
    'incognitoModeDescription': 'Don\'t save search history or starred images',
    'english': 'English',
    'japanese': 'Japanese',
    'korean': 'Korean',
    'back': 'Back',
    'forward': 'Forward',
    'pullNewImages': 'Pull New Images',
    'video': 'Video',
    'image': 'Image',
    'enterTags': 'Enter tags...',
  };

  // Japanse strings
  static const Map<String, String> _japaneseStrings = {
    'appTitle': 'タフ画像ブラウザ',
    'searchForImage': '画像を検索',
    'searchHint': '「kasane_teto」、「vocaloid」、「anime」などのタグを入力して画像を検索',
    'search': '検索',
    'home': 'ホーム',
    'settings': '設定',
    'history': '履歴',
    'starredImages': 'お気に入り画像',
    'switchToLightMode': 'ライトモードに切り替え',
    'switchToDarkMode': 'ダークモードに切り替え',
    'displaySettings': '表示設定',
    'gridColumns': 'グリッド列数',
    'gridColumnsDescription': '画像グリッドの列数',
    'showFileTypeBadges': 'ファイルタイプバッジを表示',
    'showFileTypeBadgesDescription': 'サムネイルに動画/画像バッジを表示',
    'autoPlayVideos': '動画自動再生',
    'autoPlayVideosDescription': '開いたときに動画を自動的に再生開始',
    'searchSettings': '検索設定',
    'resultsPerPage': 'ページあたりの結果数',
    'resultsPerPageDescription': 'ページごとに読み込む画像数',
    'safeSearchMode': 'セーフサーチモード',
    'safeSearchModeDescription': '露骨なコンテンツをフィルタリング（推奨）',
    'defaultSafeBooruTags': 'デフォルトSafeBooruタグ',
    'defaultSafeBooruTagsDescription': 'SafeBooruのデフォルト検索タグ',
    'defaultRule34Tags': 'デフォルトRule34タグ',
    'defaultRule34TagsDescription': 'Rule34のデフォルト検索タグ',
    'defaultYandeTags': 'デフォルトYande.reタグ',
    'defaultYandeTagsDescription': 'Yande.reのデフォルト検索タグ',
    'downloadSettings': 'ダウンロード設定',
    'autoSaveToGallery': 'ギャラリーに自動保存',
    'autoSaveToGalleryDescriptionMobile': '表示時に画像/動画をアプリディレクトリとフォトギャラリーに自動保存',
    'autoSaveToGalleryDescriptionDesktop': '表示時に画像/動画をピクチャフォルダに自動保存',
    'appSettings': 'アプリ設定',
    'language': '言語',
    'languageDescription': 'お好みの言語を選択',
    'hapticFeedback': '触覚フィードバック',
    'hapticFeedbackDescription': '要素との相互作用時に振動',
    'incognitoMode': 'シークレットモード',
    'incognitoModeDescription': '検索履歴やお気に入り画像を保存しない',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'back': '戻る',
    'forward': '進む',
    'pullNewImages': '新しい画像を取得',
    'video': '動画',
    'image': '画像',
    'enterTags': 'タグを入力...',
  };

  // Koreaanse strings
  static const Map<String, String> _koreanStrings = {
    'appTitle': '터프 이미지 브라우저',
    'searchForImage': '이미지 검색',
    'searchHint': '"kasane_teto", "vocaloid", "anime" 등의 태그를 입력하여 이미지 찾기',
    'search': '검색',
    'home': '홈',
    'settings': '설정',
    'history': '기록',
    'starredImages': '즐겨찾기 이미지',
    'switchToLightMode': '라이트 모드로 전환',
    'switchToDarkMode': '다크 모드로 전환',
    'displaySettings': '표시 설정',
    'gridColumns': '그리드 열 수',
    'gridColumnsDescription': '이미지 그리드의 열 수',
    'showFileTypeBadges': '파일 타입 배지 표시',
    'showFileTypeBadgesDescription': '썸네일에 비디오/이미지 배지 표시',
    'autoPlayVideos': '비디오 자동 재생',
    'autoPlayVideosDescription': '열었을 때 비디오 재생 자동 시작',
    'searchSettings': '검색 설정',
    'resultsPerPage': '페이지당 결과 수',
    'resultsPerPageDescription': '페이지당 로드할 이미지 수',
    'safeSearchMode': '안전 검색 모드',
    'safeSearchModeDescription': '노골적인 콘텐츠 필터링 (권장)',
    'defaultSafeBooruTags': '기본 SafeBooru 태그',
    'defaultSafeBooruTagsDescription': 'SafeBooru의 기본 검색 태그',
    'defaultRule34Tags': '기본 Rule34 태그',
    'defaultRule34TagsDescription': 'Rule34의 기본 검색 태그',
    'defaultYandeTags': '기본 Yande.re 태그',
    'defaultYandeTagsDescription': 'Yande.re의 기본 검색 태그',
    'downloadSettings': '다운로드 설정',
    'autoSaveToGallery': '갤러리에 자동 저장',
    'autoSaveToGalleryDescriptionMobile': '보기 시 이미지/비디오를 앱 디렉토리와 사진 갤러리에 자동 저장',
    'autoSaveToGalleryDescriptionDesktop': '보기 시 이미지/비디오를 사진 폴더에 자동 저장',
    'appSettings': '앱 설정',
    'language': '언어',
    'languageDescription': '선호하는 언어 선택',
    'hapticFeedback': '햅틱 피드백',
    'hapticFeedbackDescription': '요소와 상호작용할 때 진동',
    'incognitoMode': '시크릿 모드',
    'incognitoModeDescription': '검색 기록이나 즐겨찾기 이미지를 저장하지 않음',
    'english': 'English',
    'japanese': '日本語',
    'korean': '한국어',
    'back': '뒤로',
    'forward': '앞으로',
    'pullNewImages': '새 이미지 가져오기',
    'video': '비디오',
    'image': '이미지',
    'enterTags': '태그 입력...',
  };

  // Nederlandse strings
  static const Map<String, String> _dutchStrings = {
    'appTitle': 'Tuff Image Browser',
    'searchForImage': 'Zoek naar een afbeelding',
    'searchHint': 'Voer tags in zoals "kasane_teto", "vocaloid", of "anime" om afbeeldingen te vinden',
    'search': 'Zoeken',
    'home': 'Home',
    'settings': 'Instellingen',
    'history': 'Geschiedenis',
    'starredImages': 'Favoriete Afbeeldingen',
    'switchToLightMode': 'Omschakelen naar Licht Modus',
    'switchToDarkMode': 'Omschakelen naar Donker Modus',
    'displaySettings': 'Weergave Instellingen',
    'gridColumns': 'Raster Kolommen',
    'gridColumnsDescription': 'Aantal kolommen in het afbeeldingsraster',
    'showFileTypeBadges': 'Toon Bestandstype Badges',
    'showFileTypeBadgesDescription': 'Toon video/afbeelding badges op miniaturen',
    'autoPlayVideos': 'Automatisch Video\'s Afspelen',
    'autoPlayVideosDescription': 'Automatisch video afspelen starten wanneer geopend',
    'searchSettings': 'Zoek Instellingen',
    'resultsPerPage': 'Resultaten Per Pagina',
    'resultsPerPageDescription': 'Aantal afbeeldingen om per pagina te laden',
    'safeSearchMode': 'Veilig Zoeken Modus',
    'safeSearchModeDescription': 'Expliciete inhoud filteren (aanbevolen)',
    'defaultSafeBooruTags': 'Standaard SafeBooru Tags',
    'defaultSafeBooruTagsDescription': 'Standaard zoek tags voor SafeBooru',
    'defaultRule34Tags': 'Standaard Rule34 Tags',
    'defaultRule34TagsDescription': 'Standaard zoek tags voor Rule34',
    'defaultYandeTags': 'Standaard Yande.re Tags',
    'defaultYandeTagsDescription': 'Standaard zoek tags voor Yande.re',
    'downloadSettings': 'Download Instellingen',
    'autoSaveToGallery': 'Automatisch Opslaan naar Galerij',
    'autoSaveToGalleryDescriptionMobile': 'Automatisch afbeeldingen/video\'s opslaan naar app directory en fotogalerij wanneer bekeken',
    'autoSaveToGalleryDescriptionDesktop': 'Automatisch afbeeldingen/video\'s opslaan naar Afbeeldingen map wanneer bekeken',
    'appSettings': 'App Instellingen',
    'language': 'Taal',
    'languageDescription': 'Selecteer uw voorkeurstaal',
    'hapticFeedback': 'Haptische Feedback',
    'hapticFeedbackDescription': 'Trillen bij interactie met elementen',
    'incognitoMode': 'Incognito Modus',
    'incognitoModeDescription': 'Zoekgeschiedenis of favoriete afbeeldingen niet opslaan',
    'english': 'Engels',
    'japanese': 'Japans',
    'korean': 'Koreaans',
    'dutch': 'Nederlands',
    'back': 'Terug',
    'forward': 'Vooruit',
    'pullNewImages': 'Nieuwe Afbeeldingen Ophalen',
    'video': 'Video',
    'image': 'Afbeelding',
    'enterTags': 'Tags invoeren...',
  };
}

class _CustomLocalizationsDelegate extends LocalizationsDelegate<CustomLocalizations> {
  const _CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ja', 'ko', 'nl'].contains(locale.languageCode);
  }

  @override
  Future<CustomLocalizations> load(Locale locale) async {
    return CustomLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_CustomLocalizationsDelegate old) => false;
}
