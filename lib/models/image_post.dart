// Model voor afbeeldingsposten van APIs
class ImagePost {
  final String id;
  final String fileUrl;
  final String tags;

  ImagePost({
    required this.id,
    required this.fileUrl,
    required this.tags,
  });

  factory ImagePost.fromJson(Map<String, dynamic> json) {
    return ImagePost(
      id: json['id']?.toString() ?? '',
      fileUrl: json['file_url'] ?? '',
      tags: json['tags'] ?? '',
    );
  }

  // Factory methode voor yande.re JSON formaat
  factory ImagePost.fromYandeJson(Map<String, dynamic> json) {
    return ImagePost(
      id: json['id']?.toString() ?? '',
      fileUrl: json['file_url'] ?? '',
      tags: json['tags'] ?? '',
    );
  }

  // Controleer of het bestand een video is gebaseerd op bestandsextensie
  bool get isVideo {
    final url = fileUrl.toLowerCase();
    return url.endsWith('.mp4') ||
           url.endsWith('.webm') ||
           url.endsWith('.mov') ||
           url.endsWith('.avi') ||
           url.endsWith('.mkv') ||
           url.endsWith('.gif'); // GIFs kunnen als video's worden behandeld voor betere afspeelbaarheid
  }

  // Controleer of het bestand een afbeelding is
  bool get isImage {
    return !isVideo;
  }

  // Verkrijg bestandstype voor weergave
  String get fileType {
    return isVideo ? 'Video' : 'Afbeelding';
  }

  // Converteer naar StarredImage
  StarredImage toStarredImage(String platform) {
    return StarredImage(
      id: id,
      fileUrl: fileUrl,
      tags: tags,
      platform: platform,
      starredAt: DateTime.now(),
    );
  }
}

// Model voor favoriete afbeeldingen
class StarredImage {
  final String id;
  final String fileUrl;
  final String tags;
  final String platform; // 'SafeBooru', 'Rule34', of 'Yande.re'
  final DateTime starredAt;

  StarredImage({
    required this.id,
    required this.fileUrl,
    required this.tags,
    required this.platform,
    required this.starredAt,
  });

  factory StarredImage.fromJson(Map<String, dynamic> json) {
    return StarredImage(
      id: json['id'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      tags: json['tags'] ?? '',
      platform: json['platform'] ?? '',
      starredAt: DateTime.parse(json['starredAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'tags': tags,
      'platform': platform,
      'starredAt': starredAt.toIso8601String(),
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
