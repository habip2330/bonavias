import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database_service.dart';
import '../products/menu_detail_page.dart';
import '../products/product_detail_page.dart';

class MenuScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categories;

  const MenuScreen({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late List<Map<String, dynamic>> _categories;
  bool _isLoading = true;
  List<Map<String, dynamic>> _popularItems = [];
  int _selectedNav = 1; // Menu is index 1

  @override
  void initState() {
    super.initState();
    _categories = widget.categories;
    _loadPopularItems();
    
    // Sistem UI ayarları
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _loadPopularItems() async {
    try {
      final allItems = await _databaseService.getProducts();
      final items = allItems.where((item) => item['is_popular'] == true).toList();
      setState(() {
        _popularItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading popular items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }



  Widget _buildCategoryImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFD9D9D9),
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 40,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFD9D9D9),
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFD9D9D9),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFB8835A),
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB8835A),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Center(
                child: Text(
                  'Menü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sen',
                  ),
                ),
              ),
            ),
            
            // Kategoriler
            Padding(
              padding: const EdgeInsets.fromLTRB(16.7, 0, 16.7, 24),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final name = category['name']?.toString() ?? 'Kategori Adı';
                  final imageUrl = (category['imageUrl']?.toString().isNotEmpty ?? false)
                      ? category['imageUrl'].toString()
                      : (category['image_url']?.toString().isNotEmpty ?? false)
                          ? category['image_url'].toString()
                          : '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuDetailPage(
                            categoryName: category['name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildCategoryImage(imageUrl),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Sen',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Popüler Ürünler başlığı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Popüler Ürünler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontFamily: 'Sen',
                    ),
                  ),
                ],
              ),
            ),
            // Popüler Ürünler
            if (_popularItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _popularItems.length,
                itemBuilder: (context, index) {
                  final item = _popularItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          (item['image_url'] is String && (item['image_url'] ?? '').isNotEmpty)
                              ? item['image_url']
                              : '',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Sen',
                        ),
                      ),
                      subtitle: Text(
                        item['description'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13,
                          fontFamily: 'Sen',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              productId: item['id'].toString(),
                              title: item['name'] ?? '',
                              category: item['category'] ?? '',
                              imageUrl: item['image_url'],
                              price: item['price']?.toString() ?? '',
                              description: item['description'] ?? '',
                              allergens: (item['allergens'] is List)
                                  ? List<String>.from(item['allergens'])
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
} 