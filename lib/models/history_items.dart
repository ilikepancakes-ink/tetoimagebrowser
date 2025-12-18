// Model voor zoekgeschiedenis
import 'image_post.dart';

class SearchHistoryItem {
  final String searchTag;
  final String platform; // 'SafeBooru', 'Rule34', of 'Yande.re'
  final DateTime searchedAt;

  SearchHistoryItem({
    required this.searchTag,
    required this.platform,
    required this.searchedAt,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      searchTag: json['searchTag'] ?? '',
      platform: json['platform'] ?? '',
      searchedAt: DateTime.parse(json['searchedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchTag': searchTag,
      'platform': platform,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }
}

// Model voor geschiedenis van aangeklikte afbeeldingen
class ClickedImageItem {
  final String id;
  final String fileUrl;
  final String tags;
  final String platform; // 'SafeBooru', 'Rule34', of 'Yande.re'
  final DateTime clickedAt;

  ClickedImageItem({
    required this.id,
    required this.fileUrl,
    required this.tags,
    required this.platform,
    required this.clickedAt,
  });

  factory ClickedImageItem.fromJson(Map<String, dynamic> json) {
    return ClickedImageItem(
      id: json['id'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      tags: json['tags'] ?? '',
      platform: json['platform'] ?? '',
      clickedAt: DateTime.parse(json['clickedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'tags': tags,
      'platform': platform,
      'clickedAt': clickedAt.toIso8601String(),
    };
  }

  // Converteer naar ImagePost voor weergave
  ImagePost toImagePost() {
    return ImagePost(
      id: id,
      fileUrl: fileUrl,
      tags: tags,
    );
  }
}
