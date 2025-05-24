import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: ImageBrowserPage(),
    );
  }
}

class ImageBrowserPage extends StatefulWidget {
  const ImageBrowserPage({super.key});

  @override
  ImageBrowserPageState createState() => ImageBrowserPageState();
}

class ImageBrowserPageState extends State<ImageBrowserPage> {
  List<ImagePost> _images = [];
  int _page = 1;
  bool _isLoading = false;
  String? _errorMessage;

  // How many posts to fetch per page.
  final int _limit = 20;
  // Base URL for SafeBooru using the provided link.
  final String baseUrl = 'https://safebooru.org/index.php';
  // Search tag
  final String searchTag = 'kasane_teto';

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Construct the API endpoint URL.
    // "json=1" returns a JSON-formatted result and "pid" is the page number.
    final String apiUrl = '$baseUrl?page=dapi&s=post&q=index&json=1&pid=$_page&limit=$_limit&tags=$searchTag';
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
            _errorMessage = 'No images found for tag: $searchTag';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasane Teto Images'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/teto_icon.png'),
        ),
      ),
      body: Column(
        children: [
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
                    Image.asset(
                      'assets/images/teto_icon.png',
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text('Page: $_page'),
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
      ),
    );
  }
}