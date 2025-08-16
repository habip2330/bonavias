import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_results_page.dart';
import '../services/database_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _popularDesserts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularDesserts();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recentSearches') ?? [];
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      print('Son aramalar yüklenirken hata: $e');
    }
  }

  Future<void> _loadPopularDesserts() async {
    try {
      final desserts = await _databaseService.getPopularDesserts();
      setState(() {
        _popularDesserts = desserts;
      });
    } catch (e) {
      print('Popüler tatlılar yüklenirken hata: $e');
    }
  }

  Future<void> _saveSearch(String searchTerm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recentSearches') ?? [];
      
      // Aynı aramayı tekrar eklememek için kontrol et
      if (!searches.contains(searchTerm)) {
        searches.insert(0, searchTerm);
        // Son 5 aramayı tut
        if (searches.length > 5) {
          searches.removeLast();
        }
        await prefs.setStringList('recentSearches', searches);
        setState(() {
          _recentSearches = searches;
        });
      }
    } catch (e) {
      print('Arama kaydedilirken hata: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFB6B6C2)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ara',
                    style: TextStyle(fontSize: 18, color: Color(0xFF181828)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFB6B6C2)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'İçecek',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _saveSearch(value);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchResultsPage(searchTerm: value),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFB6B6C2)),
                      onPressed: () {
                        controller.clear();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFB6B6C2)),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          _saveSearch(controller.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultsPage(searchTerm: controller.text),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_recentSearches.isNotEmpty) ...[
                const Text(
                  'Son Aramalar',
                  style: TextStyle(fontSize: 16, color: Color(0xFF181828), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _recentSearches.map((e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(e, style: const TextStyle(color: Color(0xFF181828), fontWeight: FontWeight.w500)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        onDeleted: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final searches = prefs.getStringList('recentSearches') ?? [];
                          searches.remove(e);
                          await prefs.setStringList('recentSearches', searches);
                          setState(() {
                            _recentSearches = searches;
                          });
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Popüler Tatlılar',
                style: TextStyle(fontSize: 16, color: Color(0xFF181828), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              if (_popularDesserts.isNotEmpty)
                Row(
                  children: _popularDesserts.map((dessert) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade300,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: dessert['image_url'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        dessert['image_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dessert['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF181828),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dessert['subtitle'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB8835A),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 