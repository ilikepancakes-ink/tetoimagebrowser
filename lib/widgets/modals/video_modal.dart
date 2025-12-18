import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import '../../models/app_settings.dart';
import '../../models/image_post.dart';
import '../../utils/file_utils.dart';

// Video Player Modal widget voor het weergeven van video's met bedieningselementen
class VideoModal extends StatefulWidget {
  final ImagePost imagePost;
  final AppSettings settings;

  const VideoModal({super.key, required this.imagePost, required this.settings});

  @override
  State<VideoModal> createState() => _VideoModalState();
}

class _VideoModalState extends State<VideoModal> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.imagePost.fileUrl),
      );

      await _videoController.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: widget.settings.autoPlayVideos,
          looping: true,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFFE91E63),
            handleColor: const Color(0xFFE91E63),
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey[300]!,
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE91E63),
              ),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fout bij laden video: $errorMessage',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          // Video speler of laden/fout status
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFE91E63),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Video laden...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fout bij laden video: $_errorMessage',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sluiten'),
                  ),
                ],
              ),
            )
          else if (_chewieController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          // Sluitknop
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Actieknoppen
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _saveVideo(context, widget.imagePost.fileUrl),
                      icon: const Icon(Icons.download),
                      label: const Text('Opslaan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _copyVideo(context, widget.imagePost.fileUrl),
                      icon: const Icon(Icons.copy),
                      label: const Text('URL Kopiëren'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Tags
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    widget.imagePost.tags,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Sla video op naar aangepaste map
  Future<void> _saveVideo(BuildContext context, String videoUrl) async {
    try {
      // Toon laadindicator
      if (context.mounted) {
        _showSnackBar(context, 'Video downloaden...');
      }

      // Download video
      final dio = Dio();
      final response = await dio.get(
        videoUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        if (context.mounted) {
          _showSnackBar(context, 'Video downloaden mislukt');
        }
        return;
      }

      // Verkrijg aangepaste map
      final customDir = await getCustomImagesDirectory();

      // Extraheer bestandsextensie uit URL
      final uri = Uri.parse(videoUrl);
      final pathSegments = uri.pathSegments;
      String extension = '.mp4'; // standaard extensie voor video's
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        final dotIndex = fileName.lastIndexOf('.');
        if (dotIndex != -1) {
          extension = fileName.substring(dotIndex);
        }
      }

      // Maak unieke bestandsnaam aan
      final fileName = 'teto_video_${DateTime.now().millisecondsSinceEpoch}$extension';
      final file = File('${customDir.path}/$fileName');

      // Sla bestand op naar aangepaste map
      await file.writeAsBytes(response.data);

      // Op mobiele platformen, sla ook op naar de fotogalerij van het apparaat met behulp van gal pakket
      if (Platform.isIOS || Platform.isAndroid) {
        try {
          await Gal.putVideo(file.path);
          if (context.mounted) {
            _showSnackBar(context, 'Video succesvol opgeslagen in app map en fotogalerij!');
          }
        } catch (e) {
          // Als galerij opslaan faalt, toon nog steeds succes voor app map opslaan
          if (context.mounted) {
            _showSnackBar(context, 'Video succesvol opgeslagen in app map! (Galerij opslaan mislukt: permissies mogelijk vereist)');
          }
        }
      } else {
        // Desktop platformen
        if (context.mounted) {
          _showSnackBar(context, 'Video succesvol opgeslagen in Pictures/tuff image browser!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Fout bij opslaan video: ${e.toString()}');
      }
    }
  }

  // Kopieer video URL naar klembord
  Future<void> _copyVideo(BuildContext context, String videoUrl) async {
    try {
      await Clipboard.setData(ClipboardData(text: videoUrl));
      if (context.mounted) {
        _showSnackBar(context, 'Video URL gekopieerd naar klembord!');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Fout bij kopiëren video: $e');
      }
    }
  }

  // Toon snackbar bericht
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
