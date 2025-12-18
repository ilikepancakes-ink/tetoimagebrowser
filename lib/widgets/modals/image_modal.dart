import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import '../../models/image_post.dart';
import '../../utils/file_utils.dart';

// Modal widget voor het weergeven van afbeelding met opslaan/kopiëren opties
class ImageModal extends StatelessWidget {
  final ImagePost imagePost;

  const ImageModal({super.key, required this.imagePost});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      child: Stack(
        children: [
          // Vervaging achtergrond
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
          // Hoofdinhoud
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sluitknop
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                // Afbeelding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InteractiveViewer(
                      child: Image.network(
                        imagePost.fileUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                ),
                // Actieknoppen
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _saveImage(context, imagePost.fileUrl),
                        icon: const Icon(Icons.download),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _copyImage(context, imagePost.fileUrl),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy URL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tags
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      imagePost.tags,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sla afbeelding op naar aangepaste map
  Future<void> _saveImage(BuildContext context, String imageUrl) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        _showSnackBar(context, 'Downloading image...');
      }

      // Download image
      final dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        if (context.mounted) {
          _showSnackBar(context, 'Failed to download image');
        }
        return;
      }

      // Get custom directory
      final customDir = await getCustomImagesDirectory();

      // Extract file extension from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      String extension = '.jpg'; // default extension
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        final dotIndex = fileName.lastIndexOf('.');
        if (dotIndex != -1) {
          extension = fileName.substring(dotIndex);
        }
      }

      // Create unique filename
      final fileName = 'teto_image_${DateTime.now().millisecondsSinceEpoch}$extension';
      final file = File('${customDir.path}/$fileName');

      // Save file to custom directory
      await file.writeAsBytes(response.data);

      // On mobile platforms, also save to the device's photo gallery using gal package
      if (Platform.isIOS || Platform.isAndroid) {
        try {
          await Gal.putImage(file.path);
          if (context.mounted) {
            _showSnackBar(context, 'Image saved to app directory and photo gallery successfully!');
          }
        } catch (e) {
          // If gallery save fails, still show success for app directory save
          if (context.mounted) {
            _showSnackBar(context, 'Image saved to app directory successfully! (Gallery save failed: permissions may be required)');
          }
        }
      } else {
        // Desktop platforms
        if (context.mounted) {
          _showSnackBar(context, 'Image saved to Pictures/tuff image browser successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error saving image: ${e.toString()}');
      }
    }
  }

  // Copy image URL to clipboard
  Future<void> _copyImage(BuildContext context, String imageUrl) async {
    try {
      await Clipboard.setData(ClipboardData(text: imageUrl));
      if (context.mounted) {
        _showSnackBar(context, 'Image URL copied to clipboard!');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error copying image: $e');
      }
    }
  }

  // Show snackbar message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
