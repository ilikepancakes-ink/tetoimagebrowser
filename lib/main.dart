import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model for an image post from SafeBooru.
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

  // Get current search tag based on active tab
  String get _currentSearchTag => _isRule34Mode ? _rule34SearchTag : _safeBooruSearchTag;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController = TextEditingController(text: _safeBooruSearchTag); // Start with SafeBooru search
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

  // Show image modal with save/copy options
  void _showImageModal(ImagePost imagePost) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ImageModal(imagePost: imagePost);
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
      body: _currentSearchTag.trim().isEmpty
          ? _buildEmptySearchState()
          : _buildSearchResultsState(),
    );
  }

  // Build the centered search interface when no search has been performed
  Widget _buildEmptySearchState() {
    return Center(
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : GridView.builder(
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
                          return Card(
                            child: GestureDetector(
                              onTap: () => _showImageModal(imagePost),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      imagePost.fileUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error),
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
                          );
                        },
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