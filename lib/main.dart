import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

  // Check if the file is a video based on file extension
  bool get isVideo {
    final url = fileUrl.toLowerCase();
    return url.endsWith('.mp4') ||
           url.endsWith('.webm') ||
           url.endsWith('.mov') ||
           url.endsWith('.avi') ||
           url.endsWith('.mkv') ||
           url.endsWith('.gif'); // GIFs can be treated as videos for better playback
  }

  // Check if the file is an image
  bool get isImage {
    return !isVideo;
  }

  // Get file type for display
  String get fileType {
    return isVideo ? 'Video' : 'Image';
  }

  // Convert to StarredImage
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

// Model for starred images
class StarredImage {
  final String id;
  final String fileUrl;
  final String tags;
  final String platform; // 'SafeBooru' or 'Rule34'
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

  // Convert to ImagePost for display
  ImagePost toImagePost() {
    return ImagePost(
      id: id,
      fileUrl: fileUrl,
      tags: tags,
    );
  }
}

void main() {
  // Set app title and icon for desktop platforms
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Root widget for the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasane Teto Image Browser',
      theme: ThemeData(
        primarySwatch: Colors.red, // Changed to red to match Teto's color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Pink color for Teto
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Pink color for Teto
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ImageBrowserPage(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class ImageBrowserPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ImageBrowserPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ImageBrowserPageState createState() => ImageBrowserPageState();
}

class ImageBrowserPageState extends State<ImageBrowserPage>
    with SingleTickerProviderStateMixin {
  List<ImagePost> _images = [];
  int _page = 1;
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;
  bool _isRule34Mode = false;

  // How many posts to fetch per page.
  final int _limit = 20;
  // Base URLs for different APIs
  final String safeBooruUrl = 'https://safebooru.org/index.php';
  final String rule34Url = 'https://rule34.xxx/index.php';

  // Search functionality
  late TextEditingController _searchController;
  String _safeBooruSearchTag = '';
  String _rule34SearchTag = '';

  // Starred images functionality
  List<StarredImage> _starredImages = [];
  Set<String> _starredImageIds = {};

  // Get current search tag based on active tab
  String get _currentSearchTag => _isRule34Mode ? _rule34SearchTag : _safeBooruSearchTag;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController = TextEditingController(text: _safeBooruSearchTag); // Start with SafeBooru search
    _loadStarredImages(); // Load starred images from storage
    // Don't fetch images on startup - wait for user to search
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isRule34Mode = _tabController.index == 1;
        _page = 1; // Reset to first page when switching tabs
        _images.clear(); // Clear current images
        _searchController.text = _currentSearchTag; // Update search field with current tab's search
      });
      // Only fetch images if there's a search tag
      if (_currentSearchTag.trim().isNotEmpty) {
        _fetchImages(); // Fetch new images from the new API
      }
    }
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Choose the appropriate base URL based on current mode
    final String baseUrl = _isRule34Mode ? rule34Url : safeBooruUrl;

    // Construct the API endpoint URL.
    // "json=1" returns a JSON-formatted result and "pid" is the page number.
    final String apiUrl = '$baseUrl?page=dapi&s=post&q=index&json=1&pid=$_page&limit=$_limit&tags=$_currentSearchTag';
    final Uri uri = Uri.parse(apiUrl);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Decode the JSON response. It is expected to be a JSON array.
        List<dynamic> decoded = json.decode(response.body);

        if (decoded.isNotEmpty) {
          List<ImagePost> posts =
              decoded.map((json) => ImagePost.fromJson(json)).toList();
          setState(() {
            _images = posts;
          });
        } else {
          setState(() {
            _errorMessage = 'No images found for tag: $_currentSearchTag';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navigate to the previous page (if possible).
  void _previousPage() {
    if (_page > 1) {
      setState(() {
        _page--;
      });
      _fetchImages();
    }
  }

  // Navigate to the next page.
  void _nextPage() {
    setState(() {
      _page++;
    });
    _fetchImages();
  }

  // Pull new images from the current page (refresh).
  void _pullNewImages() {
    _fetchImages();
  }

  // Handle search submission
  void _performSearch() {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      // Update the appropriate search tag based on current tab
      if (_isRule34Mode) {
        _rule34SearchTag = searchText;
      } else {
        _safeBooruSearchTag = searchText;
      }
      _page = 1; // Reset to first page for new search
      _images.clear(); // Clear current images
    });
    _fetchImages();
  }

  // Clear search and return to home state
  void _goToHome() {
    setState(() {
      // Clear search tags for both tabs
      _safeBooruSearchTag = '';
      _rule34SearchTag = '';
      _searchController.clear();
      _images.clear();
      _page = 1;
      _errorMessage = null;
    });
  }

  // Generate dynamic title based on current search tag and tab
  String _getAppTitle() {
    final String currentTag = _currentSearchTag;
    final String platform = _isRule34Mode ? 'Rule34' : 'SafeBooru';

    // Handle empty or whitespace-only tags
    if (currentTag.trim().isEmpty) {
      return 'Search for a image';
    }

    // Capitalize first letter of each word in the tag for better display
    final String formattedTag = currentTag
        .trim()
        .split('_')
        .where((word) => word.isNotEmpty) // Filter out empty strings
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    return '$formattedTag Images - $platform';
  }

  // Load starred images from SharedPreferences
  Future<void> _loadStarredImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starredImagesJson = prefs.getStringList('starred_images') ?? [];

      setState(() {
        _starredImages = starredImagesJson
            .map((jsonString) => StarredImage.fromJson(json.decode(jsonString)))
            .toList();
        _starredImageIds = _starredImages.map((img) => img.id).toSet();
      });
    } catch (e) {
      print('Error loading starred images: $e');
    }
  }

  // Save starred images to SharedPreferences
  Future<void> _saveStarredImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final starredImagesJson = _starredImages
          .map((img) => json.encode(img.toJson()))
          .toList();
      await prefs.setStringList('starred_images', starredImagesJson);
    } catch (e) {
      print('Error saving starred images: $e');
    }
  }

  // Toggle star status of an image with haptic feedback
  Future<void> _toggleStarImage(ImagePost imagePost) async {
    final platform = _isRule34Mode ? 'Rule34' : 'SafeBooru';

    // Add haptic feedback for better user experience
    HapticFeedback.lightImpact();

    setState(() {
      if (_starredImageIds.contains(imagePost.id)) {
        // Remove from starred
        _starredImages.removeWhere((img) => img.id == imagePost.id);
        _starredImageIds.remove(imagePost.id);
      } else {
        // Add to starred
        final starredImage = imagePost.toStarredImage(platform);
        _starredImages.add(starredImage);
        _starredImageIds.add(imagePost.id);
      }
    });

    await _saveStarredImages();
  }

  // Check if an image is starred
  bool _isImageStarred(String imageId) {
    return _starredImageIds.contains(imageId);
  }

  // Show starred images page with slide transition
  void _showStarredImages() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => StarredImagesPage(
          starredImages: _starredImages,
          onRemoveStarred: (starredImage) async {
            setState(() {
              _starredImages.removeWhere((img) => img.id == starredImage.id);
              _starredImageIds.remove(starredImage.id);
            });
            await _saveStarredImages();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  // Show media modal with fade and scale animation (video or image)
  void _showImageModal(ImagePost imagePost) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        // Show video modal for videos, image modal for images
        return imagePost.isVideo
            ? VideoModal(imagePost: imagePost)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppTitle()),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.music_note, color: Color(0xFFE91E63)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _showStarredImages,
            tooltip: 'Starred Images (${_starredImages.length})',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'SafeBooru'),
            Tab(text: 'rule34'),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        child: _currentSearchTag.trim().isEmpty
            ? _buildEmptySearchState()
            : _buildSearchResultsState(),
      ),
    );
  }

  // Build the centered search interface when no search has been performed
  Widget _buildEmptySearchState() {
    return Center(
      key: const ValueKey('empty_search'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 80,
              color: Color(0xFFE91E63),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search for a image',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter tags like "kasane_teto", "vocaloid", or "anime" to find images',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 400,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a image',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the search results interface when a search has been performed
  Widget _buildSearchResultsState() {
    return Column(
      key: ValueKey('search_results_$_currentSearchTag\_$_isRule34Mode'),
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Home button
              IconButton(
                onPressed: _goToHome,
                icon: const Icon(Icons.home),
                tooltip: 'Go to Home',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a image',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? Center(
                        key: ValueKey('error'),
                        child: Text(_errorMessage!),
                      )
                    : GridView.builder(
                        key: ValueKey('grid_$_currentSearchTag\_$_page'),
                        padding: const EdgeInsets.all(4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final imagePost = _images[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: Card(
                                    child: GestureDetector(
                                      onTap: () => _showImageModal(imagePost),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  imagePost.fileUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.error),
                                                ),
                                                // Video play icon overlay (center)
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
                                                // File type badge (top left)
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
                                                // Star button overlay
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      onTap: () => _toggleStarImage(imagePost),
                                                      child: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 200),
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.7),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: AnimatedSwitcher(
                                                          duration: const Duration(milliseconds: 200),
                                                          child: Icon(
                                                            _isImageStarred(imagePost.id)
                                                                ? Icons.star
                                                                : Icons.star_border,
                                                            key: ValueKey(_isImageStarred(imagePost.id)),
                                                            color: _isImageStarred(imagePost.id)
                                                                ? Colors.yellow
                                                                : Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
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
                                              imagePost.tags,
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
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _page > 1 ? _previousPage : null,
                  child: const Text('Back'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Color(0xFFE91E63),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text('Page: $_page (${_isRule34Mode ? 'Rule34' : 'SafeBooru'})'),
                  ],
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Forward'),
                ),
                ElevatedButton(
                  onPressed: _pullNewImages,
                  child: const Text('Pull New Images'),
                ),
              ],
            ),
          ),
        ],
      );
  }
}

// Modal widget for displaying image with save/copy options
class ImageModal extends StatelessWidget {
  final ImagePost imagePost;

  const ImageModal({super.key, required this.imagePost});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Close button
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
                // Image
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
                // Action buttons
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

  // Save image to device gallery
  Future<void> _saveImage(BuildContext context, String imageUrl) async {
    try {
      // Check if we have permission to save images
      if (!await Gal.hasAccess()) {
        // Request permission
        if (!await Gal.requestAccess()) {
          if (context.mounted) {
            _showSnackBar(context, 'Storage permission is required to save images');
          }
          return;
        }
      }

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

      // Save to gallery using Gal
      await Gal.putImageBytes(
        response.data,
        name: 'teto_image_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        _showSnackBar(context, 'Image saved to gallery successfully!');
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

// Video Player Modal widget for displaying videos with controls
class VideoModal extends StatefulWidget {
  final ImagePost imagePost;

  const VideoModal({super.key, required this.imagePost});

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
          autoPlay: false,
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
                    'Error loading video: $errorMessage',
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
          // Video player or loading/error state
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
                    'Loading video...',
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
                    'Error loading video: $_errorMessage',
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
                    child: const Text('Close'),
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
          // Close button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Action buttons
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
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _copyVideo(context, widget.imagePost.fileUrl),
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

  // Save video to device gallery
  Future<void> _saveVideo(BuildContext context, String videoUrl) async {
    try {
      // Check if we have permission to save videos
      if (!await Gal.hasAccess()) {
        // Request permission
        if (!await Gal.requestAccess()) {
          if (context.mounted) {
            _showSnackBar(context, 'Storage permission is required to save videos');
          }
          return;
        }
      }

      // Show loading indicator
      if (context.mounted) {
        _showSnackBar(context, 'Downloading video...');
      }

      // Download video
      final dio = Dio();
      final response = await dio.get(
        videoUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        if (context.mounted) {
          _showSnackBar(context, 'Failed to download video');
        }
        return;
      }

      // Save to gallery using Gal (videos are saved as image bytes in Gal)
      await Gal.putImageBytes(
        response.data,
        name: 'teto_video_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        _showSnackBar(context, 'Video saved to gallery successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error saving video: ${e.toString()}');
      }
    }
  }

  // Copy video URL to clipboard
  Future<void> _copyVideo(BuildContext context, String videoUrl) async {
    try {
      await Clipboard.setData(ClipboardData(text: videoUrl));
      if (context.mounted) {
        _showSnackBar(context, 'Video URL copied to clipboard!');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error copying video: $e');
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

// Starred Images Page
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
        title: Text('Starred Images (${starredImages.length})'),
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
                    'No starred images yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Star images by clicking the star icon when hovering over them',
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
                              // Video play icon overlay (center)
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
                              // File type badge (top left)
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
                              // Remove star button
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
                              // Platform badge (bottom left)
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

  // Show media modal with animation (video or image)
  void _showImageModal(BuildContext context, ImagePost imagePost) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        // Show video modal for videos, image modal for images
        return imagePost.isVideo
            ? VideoModal(imagePost: imagePost)
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