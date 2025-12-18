import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/image_post.dart';
import '../../utils/file_utils.dart';
import '../modals/image_modal.dart';
import '../modals/video_modal.dart';
import '../../models/app_settings.dart';

// Favoriete Afbeeldingen Pagina
class StarredImagesPage extends StatelessWidget {
  final List<StarredImage> starredImages;
  final Function(StarredImage) onRemoveStarred;

  const StarredImagesPage({
    super.key,
    required this.starredImages,
    required this.onRemoveStarred,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoriete Afbeeldingen (${starredImages.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: starredImages.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Color(0xFFE91E63),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nog geen favoriete afbeeldingen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Markeer afbeeldingen als favoriet door op het ster icoon te klikken wanneer je eroverheen gaat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: starredImages.length,
              itemBuilder: (context, index) {
                final starredImage = starredImages[index];
                final imagePost = starredImage.toImagePost();

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 200 + (index * 30)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Card(
                  child: GestureDetector(
                    onTap: () => _showImageModal(context, imagePost),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Image.network(
                                starredImage.fileUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                              // Video afspeel icoon overlay (midden)
                              if (imagePost.isVideo)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              // Bestandstype badge (links boven)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: imagePost.isVideo
                                        ? Colors.red.withValues(alpha: 0.8)
                                        : Colors.blue.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    imagePost.fileType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Verwijder ster knop
                              Positioned(
                                top: 8,
                                right: 8,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => onRemoveStarred(starredImage),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Platform badge (links onder)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    starredImage.platform,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            starredImage.tags,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Toon media modal met animatie (video of afbeelding)
  void _showImageModal(BuildContext context, ImagePost imagePost) {
    // Sla media automatisch op naar aangepaste map
    autoSaveMedia(imagePost.fileUrl, isVideo: imagePost.isVideo);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        // Toon video modal voor video's, afbeelding modal voor afbeeldingen
        return imagePost.isVideo
            ? VideoModal(imagePost: imagePost, settings: const AppSettings())
            : ImageModal(imagePost: imagePost);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
