// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '터프 이미지 브라우저';

  @override
  String get searchForImage => '이미지 검색';

  @override
  String get searchHint =>
      '\"kasane_teto\", \"vocaloid\", \"anime\" 등의 태그를 입력하여 이미지 찾기';

  @override
  String get search => '검색';

  @override
  String get home => '홈';

  @override
  String get settings => '설정';

  @override
  String get history => '기록';

  @override
  String get starredImages => '즐겨찾기 이미지';

  @override
  String get switchToLightMode => '라이트 모드로 전환';

  @override
  String get switchToDarkMode => '다크 모드로 전환';

  @override
  String get displaySettings => '표시 설정';

  @override
  String get gridColumns => '그리드 열 수';

  @override
  String get gridColumnsDescription => '이미지 그리드의 열 수';

  @override
  String get showFileTypeBadges => '파일 타입 배지 표시';

  @override
  String get showFileTypeBadgesDescription => '썸네일에 비디오/이미지 배지 표시';

  @override
  String get autoPlayVideos => '비디오 자동 재생';

  @override
  String get autoPlayVideosDescription => '열었을 때 비디오 재생 자동 시작';

  @override
  String get searchSettings => '검색 설정';

  @override
  String get resultsPerPage => '페이지당 결과 수';

  @override
  String get resultsPerPageDescription => '페이지당 로드할 이미지 수';

  @override
  String get safeSearchMode => '안전 검색 모드';

  @override
  String get safeSearchModeDescription => '노골적인 콘텐츠 필터링 (권장)';

  @override
  String get defaultSafeBooruTags => '기본 SafeBooru 태그';

  @override
  String get defaultSafeBooruTagsDescription => 'SafeBooru의 기본 검색 태그';

  @override
  String get defaultRule34Tags => '기본 Rule34 태그';

  @override
  String get defaultRule34TagsDescription => 'Rule34의 기본 검색 태그';

  @override
  String get defaultYandeTags => '기본 Yande.re 태그';

  @override
  String get defaultYandeTagsDescription => 'Yande.re의 기본 검색 태그';

  @override
  String get downloadSettings => '다운로드 설정';

  @override
  String get autoSaveToGallery => '갤러리에 자동 저장';

  @override
  String get autoSaveToGalleryDescriptionMobile =>
      '보기 시 이미지/비디오를 앱 디렉토리와 사진 갤러리에 자동 저장';

  @override
  String get autoSaveToGalleryDescriptionDesktop =>
      '보기 시 이미지/비디오를 사진 폴더에 자동 저장';

  @override
  String get appSettings => '앱 설정';

  @override
  String get language => '언어';

  @override
  String get languageDescription => '선호하는 언어 선택';

  @override
  String get hapticFeedback => '햅틱 피드백';

  @override
  String get hapticFeedbackDescription => '요소와 상호작용할 때 진동';

  @override
  String get incognitoMode => '시크릿 모드';

  @override
  String get incognitoModeDescription => '검색 기록이나 즐겨찾기 이미지를 저장하지 않음';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String noImagesFound(String tag) {
    return '태그 \"$tag\"에 대한 이미지를 찾을 수 없습니다';
  }

  @override
  String serverError(String code) {
    return '서버 오류: $code';
  }

  @override
  String page(int pageNumber, String platform) {
    return '페이지: $pageNumber ($platform)';
  }

  @override
  String get back => '뒤로';

  @override
  String get forward => '앞으로';

  @override
  String get pullNewImages => '새 이미지 가져오기';

  @override
  String get video => '비디오';

  @override
  String get image => '이미지';

  @override
  String get enterTags => '태그 입력...';
}
