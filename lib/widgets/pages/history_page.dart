import 'package:flutter/material.dart';
import '../../models/history_items.dart';
import '../../models/image_post.dart';
import '../../utils/file_utils.dart';
import '../modals/image_modal.dart';
import '../modals/video_modal.dart';
import '../../models/app_settings.dart';

// Geschiedenis Pagina
class HistoryPage extends StatefulWidget {
  final List<SearchHistoryItem> searchHistory;
  final List<ClickedImageItem> clickedImages;
  final VoidCallback onClearSearchHistory;
  final VoidCallback onClearClickedImages;
  final Function(String searchTag, String platform) onSearchFromHistory;

  const HistoryPage({
    super.key,
    required this.searchHistory,
    required this.clickedImages,
    required this.onClearSearchHistory,
    required this.onClearClickedImages,
    required this.onSearchFromHistory,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geschiedenis (${widget.searchHistory.length + widget.clickedImages.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Zoekgeschiedenis (${widget.searchHistory.length})'),
            Tab(text: 'Aangeklikte Afbeeldingen (${widget.clickedImages.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchHistoryTab(),
          _buildClickedImagesTab(),
        ],
      ),
    );
  }

  Widget _buildSearchHistoryTab() {
    if (widget.searchHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Color(0xFFE91E63),
            ),
            SizedBox(height: 16),
            Text(
              'Nog geen zoekgeschiedenis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Je zoekgeschiedenis verschijnt hier',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Wissen knop
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showClearSearchHistoryDialog(),
            icon: const Icon(Icons.clear_all),
            label: const Text('Zoekgeschiedenis Wissen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // Zoekgeschiedenis lijst
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: widget.searchHistory.length,
            itemBuilder: (context, index) {
              final historyItem = widget.searchHistory[index];
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
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: historyItem.platform == 'Rule34'
                                  ? Colors.orange.withValues(alpha: 0.8)
                                  : historyItem.platform == 'Yande.re'
                                      ? Colors.pink.withValues(alpha: 0.8)
                                      : Colors.blue.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              historyItem.platform,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            historyItem.searchTag,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _formatDateTime(historyItem.searchedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.search),
                          onTap: () => widget.onSearchFromHistory(
                            historyItem.searchTag,
                            historyItem.platform,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClickedImagesTab() {
    if (widget.clickedImages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 80,
              color: Color(0xFFE91E63),
            ),
            SizedBox(height: 16),
            Text(
              'Nog geen aangeklikte afbeeldingen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Afbeeldingen die je aanklikt verschijnen hier',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Wissen knop
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showClearClickedImagesDialog(),
            icon: const Icon(Icons.clear_all),
            label: const Text('Aangeklikte Afbeeldingen Wissen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // Aangeklikte afbeeldingen raster
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.clickedImages.length,
            itemBuilder: (context, index) {
              final clickedImage = widget.clickedImages[index];
              final imagePost = clickedImage.toImagePost();

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
                                      clickedImage.fileUrl,
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
                                    // Platform badge (links boven)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: clickedImage.platform == 'Rule34'
                                              ? Colors.orange.withValues(alpha: 0.8)
                                              : clickedImage.platform == 'Yande.re'
                                                  ? Colors.pink.withValues(alpha: 0.8)
                                                  : Colors.blue.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          clickedImage.platform,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Tijd badge (rechts onder)
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _formatDateTime(clickedImage.clickedAt),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
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
                                  clickedImage.tags,
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
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showClearSearchHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zoekgeschiedenis Wissen'),
        content: const Text('Weet je zeker dat je alle zoekgeschiedenis wilt wissen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClearSearchHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoekgeschiedenis gewist')),
              );
            },
            child: const Text('Wissen'),
          ),
        ],
      ),
    );
  }

  void _showClearClickedImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aangeklikte Afbeeldingen Geschiedenis Wissen'),
        content: const Text('Weet je zeker dat je alle aangeklikte afbeeldingen geschiedenis wilt wissen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClearClickedImages();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aangeklikte afbeeldingen geschiedenis gewist')),
              );
            },
            child: const Text('Wissen'),
          ),
        ],
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
