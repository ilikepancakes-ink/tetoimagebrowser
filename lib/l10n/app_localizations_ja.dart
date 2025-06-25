// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'タフ画像ブラウザ';

  @override
  String get searchForImage => '画像を検索';

  @override
  String get searchHint => '「kasane_teto」、「vocaloid」、「anime」などのタグを入力して画像を検索';

  @override
  String get search => '検索';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get history => '履歴';

  @override
  String get starredImages => 'お気に入り画像';

  @override
  String get switchToLightMode => 'ライトモードに切り替え';

  @override
  String get switchToDarkMode => 'ダークモードに切り替え';

  @override
  String get displaySettings => '表示設定';

  @override
  String get gridColumns => 'グリッド列数';

  @override
  String get gridColumnsDescription => '画像グリッドの列数';

  @override
  String get showFileTypeBadges => 'ファイルタイプバッジを表示';

  @override
  String get showFileTypeBadgesDescription => 'サムネイルに動画/画像バッジを表示';

  @override
  String get autoPlayVideos => '動画自動再生';

  @override
  String get autoPlayVideosDescription => '開いたときに動画を自動的に再生開始';

  @override
  String get searchSettings => '検索設定';

  @override
  String get resultsPerPage => 'ページあたりの結果数';

  @override
  String get resultsPerPageDescription => 'ページごとに読み込む画像数';

  @override
  String get safeSearchMode => 'セーフサーチモード';

  @override
  String get safeSearchModeDescription => '露骨なコンテンツをフィルタリング（推奨）';

  @override
  String get defaultSafeBooruTags => 'デフォルトSafeBooruタグ';

  @override
  String get defaultSafeBooruTagsDescription => 'SafeBooruのデフォルト検索タグ';

  @override
  String get defaultRule34Tags => 'デフォルトRule34タグ';

  @override
  String get defaultRule34TagsDescription => 'Rule34のデフォルト検索タグ';

  @override
  String get defaultYandeTags => 'デフォルトYande.reタグ';

  @override
  String get defaultYandeTagsDescription => 'Yande.reのデフォルト検索タグ';

  @override
  String get downloadSettings => 'ダウンロード設定';

  @override
  String get autoSaveToGallery => 'ギャラリーに自動保存';

  @override
  String get autoSaveToGalleryDescriptionMobile =>
      '表示時に画像/動画をアプリディレクトリとフォトギャラリーに自動保存';

  @override
  String get autoSaveToGalleryDescriptionDesktop => '表示時に画像/動画をピクチャフォルダに自動保存';

  @override
  String get appSettings => 'アプリ設定';

  @override
  String get language => '言語';

  @override
  String get languageDescription => 'お好みの言語を選択';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get hapticFeedbackDescription => '要素との相互作用時に振動';

  @override
  String get incognitoMode => 'シークレットモード';

  @override
  String get incognitoModeDescription => '検索履歴やお気に入り画像を保存しない';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String noImagesFound(String tag) {
    return 'タグ「$tag」の画像が見つかりません';
  }

  @override
  String serverError(String code) {
    return 'サーバーエラー: $code';
  }

  @override
  String page(int pageNumber, String platform) {
    return 'ページ: $pageNumber ($platform)';
  }

  @override
  String get back => '戻る';

  @override
  String get forward => '進む';

  @override
  String get pullNewImages => '新しい画像を取得';

  @override
  String get video => '動画';

  @override
  String get image => '画像';

  @override
  String get enterTags => 'タグを入力...';
}
