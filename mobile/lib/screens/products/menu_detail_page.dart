import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../services/database_service.dart';

class MenuDetailPage extends StatefulWidget {
  final String categoryName;
  
  const MenuDetailPage({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String _errorMessage = '';
  Timer? _retryTimer;
  int _retryCount = 0;
  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔍 PostgreSQL\'den ürünler yükleniyor... Kategori: "${widget.categoryName}"');
      
      // Kategori kontrolü
      if (widget.categoryName.isEmpty) {
        throw Exception('Geçersiz kategori adı');
      }
      
      // PostgreSQL'den ürünleri çek
      List<Map<String, dynamic>> products;
      
      if (widget.categoryName.toLowerCase() == 'tümü' || widget.categoryName.toLowerCase() == 'all') {
        // Tüm ürünleri getir
        products = await _db.getProducts();
        print('📦 Tüm ürünler yüklendi: ${products.length} ürün');
      } else {
        // Backend filtreleme çalışmadığı için tüm ürünleri alıp manuel filtreleme yapacağız
        print('🔍 Kategoriler yükleniyor...');
        final categories = await _db.getCategories();
        print('📋 Mevcut kategoriler: ${categories.map((c) => '${c['name']} (ID: ${c['id']})').join(', ')}');
        
        // Kategori ID'sini bul
        final category = categories.firstWhere(
          (cat) => cat['name'] == widget.categoryName,
          orElse: () => <String, dynamic>{},
        );
        
        print('🎯 Aranan kategori: "${widget.categoryName}"');
        print('✅ Bulunan kategori: ${category.isNotEmpty ? '${category['name']} (ID: ${category['id']})' : 'BULUNAMADI'}');
        
        // Tüm ürünleri al
        print('📦 Tüm ürünler alınıyor...');
        final allProducts = await _db.getProducts();
        print('📦 Toplam ${allProducts.length} ürün yüklendi');
        
        if (category.isNotEmpty && category['id'] != null) {
          // Kategori ID'si ile manuel filtreleme
          final categoryId = category['id'].toString();
          print('🔍 Kategori ID $categoryId ile manuel filtreleme yapılıyor...');
          
          products = allProducts.where((product) {
            final productCategoryId = product['category_id']?.toString() ?? '';
            final match = productCategoryId == categoryId;
            if (match) {
              print('✅ Eşleşen ürün: ${product['name']} (kategori_id: $productCategoryId)');
            }
            return match;
          }).toList();
          
          print('📦 Kategori ID bazlı filtreleme ile kategori "${widget.categoryName}" ürünleri bulundu: ${products.length} ürün');
        } else {
          // Kategori adı ile manuel filtreleme (fallback)
          print('⚠️ Kategori ID bulunamadı, kategori adı ile manuel filtreleme yapılıyor...');
          
          products = allProducts.where((product) {
            final categoryName = product['category_name'] as String? ?? '';
            final match = categoryName.toLowerCase() == widget.categoryName.toLowerCase();
            if (match) {
              print('✅ Eşleşen ürün: ${product['name']} (kategori: $categoryName)');
            }
            return match;
          }).toList();
          
          print('📦 İsim bazlı filtreleme ile kategori "${widget.categoryName}" ürünleri bulundu: ${products.length} ürün');
        }
      }
      
      if (products.isEmpty) {
        print('⚠️ Kategori "${widget.categoryName}" için hiç ürün bulunamadı');
        setState(() {
          _isLoading = false;
          _products = [];
          _errorMessage = 'Bu kategoride henüz ürün bulunmuyor';
        });
        return;
      }

      // Ürünleri ekleme tarihine göre sırala (ilk eklenen ilk başta)
      products.sort((a, b) {
        final aCreated = a['created_at'] as String? ?? '';
        final bCreated = b['created_at'] as String? ?? '';
        return aCreated.compareTo(bCreated); // ASC sıralama (eski tarih önce)
      });
      
      print('✅ Toplam ${products.length} ürün başarıyla yüklendi ve sıralandı');

      setState(() {
        _products = products;
        _isLoading = false;
        _retryCount = 0;
      });
    } catch (e, stackTrace) {
      print('❌ PostgreSQL ürün yükleme hatası: $e');
      print('❌ Hata detayı: $stackTrace');
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ürünler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
      });
      
      // Otomatik yeniden deneme
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('🔄 Yeniden deneniyor... (Deneme: $_retryCount/$_maxRetries)');
        _retryTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _loadProducts();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header Section with Figma Design
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
            child: Stack(
              children: [
                // Back Button
                Positioned(
                  left: 24,
                  top: 55,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const ShapeDecoration(
                        color: Colors.white24,
                        shape: OvalBorder(),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Category Name (Large, Centered)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sen',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFFB67A4B),
                  ))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB67A4B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? const Center(
                            child: Text(
                              'Bu kategoride henüz ürün bulunmuyor',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            color: Theme.of(context).colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 24,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: _products.length,
                                itemBuilder: (context, index) {
                                  final product = _products[index];
                                  
                                  // Ingredients'i allergens'e dönüştür
                                  List<String> allergens = [];
                                  if (product['ingredients'] != null) {
                                    if (product['ingredients'] is String) {
                                      try {
                                        final parsed = jsonDecode(product['ingredients']);
                                        if (parsed is List) {
                                          allergens = List<String>.from(parsed);
                                        }
                                      } catch (e) {
                                        print('⚠️ JSON parse hatası: $e');
                                        allergens = [];
                                      }
                                    } else if (product['ingredients'] is List) {
                                      allergens = List<String>.from(product['ingredients']);
                                    }
                                  }
                                  
                                  return _MenuItem(
                                    productId: product['id'],
                                    title: product['name'] ?? 'İsimsiz Ürün',
                                    category: widget.categoryName,
                                    imageUrl: product['image_url'],
                                    price: product['price']?.toString() ?? '',
                                    description: product['description'] ?? '',
                                    allergens: allergens,
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String productId;
  final String title;
  final String category;
  final String? imageUrl;
  final String price;
  final String description;
  final List<String> allergens;

  const _MenuItem({
    required this.productId,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.price,
    required this.description,
    required this.allergens,
  });

  // Firestore base64 görselleri için yükleyici
  Future<ImageProvider> _getFirestoreImageProvider(String url) async {
    try {
      if (!url.startsWith('firestore://')) {
        throw Exception('Geçersiz URL formatı');
      }
      
      print('⚠️ Firestore görseli desteklenmiyor, placeholder gösteriliyor');
      
      // Firestore artık kullanılmıyor, placeholder göster
      return const NetworkImage('https://via.placeholder.com/200?text=Görsel+Bulunamadı');
    } catch (e) {
      print('❌ Firestore görsel yükleme hatası: $e');
      // Hata durumunda placeholder göster
      return const NetworkImage('https://via.placeholder.com/200?text=Hata');
    }
  }

  // Görsel sağlayıcısını al
  ImageProvider _getImageProvider(String url) {
    try {
      // Placeholder image URL
      const placeholderUrl = 'https://via.placeholder.com/200?text=Ürün';
      
      // Handle different image URL formats
      if (url.startsWith('firestore://')) {
        // For Firestore images, we use a placeholder initially
        // The actual image will be loaded by FirestoreImage widget
        print('🔍 Firestore base64 görsel referansı algılandı: $url');
        return const NetworkImage(placeholderUrl);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        // Regular network images
        print('🌐 Network image: $url');
        return NetworkImage(url);
      } else if (url.startsWith('data:image')) {
        // Inline base64 images (data URIs)
        print('📊 Base64 embedded image detected');
        return NetworkImage(url);
      } else {
        // Unknown format, use a placeholder
        print('⚠️ Unknown image format: $url');
        return const NetworkImage(placeholderUrl);
      }
    } catch (e) {
      print('❌ Error creating image provider: $e');
      // Return a placeholder on error
      return const NetworkImage('https://via.placeholder.com/200?text=Hata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              productId: productId,
              title: title,
              category: category,
              imageUrl: imageUrl,
              price: price,
              description: description,
              allergens: allergens,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image Container (Figma Design)
          Container(
            width: 130,
            height: 130,
            decoration: ShapeDecoration(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? (imageUrl!.startsWith('firestore://')
                      ? FirestoreImage(url: imageUrl!, fit: BoxFit.cover)
                      : Image(
                          image: _getImageProvider(imageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).cardColor,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 30,
                              ),
                            );
                          },
                        ))
                  : Container(
                      color: Theme.of(context).cardColor,
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 2),
          
          // Product Name
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 15,
                fontFamily: 'Sen',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.33,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Category Name
          Flexible(
            child: Text(
              category,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 13,
                fontFamily: 'Sen',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Firestore base64 görselleri için özel widget
class FirestoreImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  
  const FirestoreImage({
    Key? key,
    required this.url,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  State<FirestoreImage> createState() => _FirestoreImageState();
}

class _FirestoreImageState extends State<FirestoreImage> {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;
  
  @override
  void initState() {
    super.initState();
    _loadFirestoreImage();
  }
  
  Future<void> _loadFirestoreImage() async {
    try {
      if (!widget.url.startsWith('firestore://')) {
        throw Exception('Geçersiz URL formatı');
      }
      
      print('⚠️ Firestore görseli desteklenmiyor');
      
      // Firestore artık kullanılmıyor, hata durumu göster
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Firestore görsel yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20, 
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFB67A4B),
          ),
        ),
      );
    }
    
    if (_hasError || _imageBytes == null) {
      return const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 24,
      );
    }
    
    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
    );
  }
} 