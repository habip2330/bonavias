import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modern_bottom_nav_bar.dart' as modern_nav;
import 'home_page.dart';
import 'menu_detail_page.dart';
import 'profile_page.dart';
import 'modern_bottom_nav_bar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class MenuPartPage extends StatefulWidget {
  const MenuPartPage({Key? key}) : super(key: key);

  @override
  State<MenuPartPage> createState() => _MenuPartPageState();
}

class _MenuPartPageState extends State<MenuPartPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  String _errorMessage = '';
  Timer? _retryTimer;
  int _retryCount = 0;
  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
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

    if (imageUrl.startsWith('firestore://')) {
      return FirestoreImage(url: imageUrl, fit: BoxFit.cover);
    } else if (imageUrl.startsWith('category_images/')) {
      return CategoryImage(url: imageUrl, fit: BoxFit.cover);
    } else {
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
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔍 Kategoriler yükleniyor...');
      final response = await http.get(Uri.parse('http://192.168.1.105:3001/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API DATA:');
        print(data);
        final categories = data.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'isActive': item['is_active'] ?? true,
          'imageUrl': item['image_url'] ?? '',
          'description': item['description'] ?? '',
          'icon': item['icon'] ?? '0',
        }).toList();
        print('CATEGORIES MAP:');
        print(categories);
        setState(() {
          _categories = categories;
          _isLoading = false;
          _retryCount = 0;
        });
      } else {
        throw Exception('Kategoriler yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Kategori yükleme hatası: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kategoriler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
      });
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('🔄 Yeniden deneniyor... (Deneme: $_retryCount/$_maxRetries)');
        _retryTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _loadCategories();
          }
        });
      }
    }
  }

  // Firestore bağlantısını kontrol et
  Future<bool> _checkFirestoreConnection() async {
    try {
      print('📡 Firestore bağlantısı kontrol ediliyor...');
      
      // Önce Firebase düzgün başlatıldı mı kontrol et
      if (!FirebaseFirestore.instance.app.isAutomaticDataCollectionEnabled) {
        print('⚠️ Firebase otomatik veri toplama devre dışı. Bu bir sorun işareti olabilir.');
      }
      
      // Firebase Project ID'sini logla
      print('🔑 Firebase Project ID: ${FirebaseFirestore.instance.app.options.projectId}');
      
      // Test sorgusu çalıştır
      final test = await FirebaseFirestore.instance.collection('categories').limit(1).get();
      print('✅ Firestore bağlantısı başarılı. Dönen veri sayısı: ${test.size}');
      
      return true;
    } catch (e) {
      print('❌ Firestore bağlantı hatası: $e');
      return false;
    }
  }

  // Firestore'dan base64 görseli çek
  Future<ImageProvider> _loadFirestoreImage(String url) async {
    try {
      print('🔍 Firestore görseli yükleniyor: $url');
      // firestore://collection/docId formatından parçaları çıkar
      final parts = url.replaceFirst('firestore://', '').split('/');
      if (parts.length != 2) {
        throw Exception('Geçersiz Firestore görsel URL formatı');
      }

      final collection = parts[0];
      final docId = parts[1];
      
      print('📂 Koleksiyon: $collection, Doküman ID: $docId');
      
      // Firestore'dan dokümanı çek
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Görsel dokümanı bulunamadı');
      }
      
      // Base64 verisini çıkar
      final data = doc.data();
      if (data == null || !data.containsKey('base64')) {
        throw Exception('Doküman içinde base64 verisi yok');
      }
      
      final base64String = data['base64'] as String;
      print('✅ Base64 verisi alındı (${base64String.length} karakter)');
      
      // Base64'ü çöz
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      print('❌ Firestore görsel yükleme hatası: $e');
      // Hata durumunda placeholder göster
      return const NetworkImage('https://via.placeholder.com/150?text=Hata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8835A)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              : _categories.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz kategori bulunmuyor',
                        style: TextStyle(
                          color: Color(0xFFB6B6C2),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.7, 40, 16.7, 24),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final name = category['name']?.toString() ?? 'Kategori Adı';
                        final imageUrl = (category['imageUrl']?.toString().isNotEmpty ?? false)
                            ? category['imageUrl'].toString()
                            : 'https://bona1.menulerimiz.com/storage/files/qr-resimler/bonavias/category-cards/pancake67a9108696d0e.png';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuDetailPage(
                                  category: category,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 340,
                            height: 109,
                            margin: const EdgeInsets.only(bottom: 25),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF8F8F8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Left Image Container
                                Container(
                                  margin: const EdgeInsets.only(left: 11, top: 9, bottom: 9),
                                  width: 91,
                                  height: 91,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: _buildCategoryImage(imageUrl),
                                  ),
                                ),
                                
                                // Category Name
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 46),
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'Sen',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String categoryId;
  final String title;
  final String? imageUrl;
  
  const _MenuItem({
    required this.categoryId,
    required this.title,
    this.imageUrl,
  });

  ImageProvider _getImageProvider(String url) {
    try {
      // Placeholder image URL
      const placeholderUrl = 'https://via.placeholder.com/150?text=Kategori';
      
      // Handle different image URL formats
      if (url.startsWith('firestore://')) {
        // For Firestore images, we use a placeholder initially
        print('🔍 Firestore görsel referansı: $url');
        return const NetworkImage(placeholderUrl);
      } else if (url.startsWith('category_images/')) {
        // Kategori görselleri için özel işleme
        print('🔍 Kategori görseli referansı: $url');
        // Bu durumda CategoryImage widget'ı görüntüyü yükleyecek, bu sadece placeholder
        return const NetworkImage(placeholderUrl);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        // Regular network images
        print('🌐 Network image: $url');
        return NetworkImage(url);
      } else if (url.startsWith('data:image')) {
        // Inline base64 images
        print('📊 Base64 image');
        return NetworkImage(url);
      } else {
        // Unknown format
        print('⚠️ Unknown image format: $url');
        return const NetworkImage(placeholderUrl);
      }
    } catch (e) {
      print('❌ Error loading image: $e');
      return const NetworkImage('https://via.placeholder.com/150?text=Hata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(
              categoryId: categoryId,
              categoryName: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.category,
                        color: Colors.grey,
                        size: 30,
                      ),
                    )
                  : imageUrl!.startsWith('firestore://')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FirestoreImage(url: imageUrl!),
                        )
                  : imageUrl!.startsWith('category_images/')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CategoryImage(url: imageUrl!),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image(
                            image: _getImageProvider(imageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('🚨 Resim yükleme hatası: $error');
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFB67A4B),
            ),
          ],
        ),
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
      
      final parts = widget.url.replaceFirst('firestore://', '').split('/');
      if (parts.length != 2) {
        throw Exception('Geçersiz Firestore görsel URL formatı');
      }

      final collection = parts[0];
      final docId = parts[1];
      
      // Firestore'dan dokümanı çek
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Görsel dokümanı bulunamadı');
      }
      
      // Base64 verisini çıkar
      final data = doc.data();
      if (data == null || !data.containsKey('base64')) {
        throw Exception('Doküman içinde base64 verisi yok');
      }
      
      final base64String = data['base64'] as String;
      
      // Base64'ü çöz
      final bytes = base64Decode(base64String);
      
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
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

// Kategori görselleri için özel widget (category_images/ formatı için)
class CategoryImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  
  const CategoryImage({
    Key? key,
    required this.url,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  State<CategoryImage> createState() => _CategoryImageState();
}

class _CategoryImageState extends State<CategoryImage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Uint8List? _imageBytes;
  
  @override
  void initState() {
    super.initState();
    _loadCategoryImage();
  }
  
  Future<void> _loadCategoryImage() async {
    try {
      if (!widget.url.startsWith('category_images/')) {
        throw Exception('Geçersiz kategori görsel URL formatı');
      }
      
      final docId = widget.url.split('/').last;
      print('📷 Kategori görseli yükleniyor: $docId');
      
      // Firestore'dan dokümanı çek
      final doc = await FirebaseFirestore.instance
          .collection('category_images')
          .doc(docId)
          .get();
      
      if (!doc.exists) {
        print('⚠️ Görsel dokümanı bulunamadı: $docId');
        throw Exception('Görsel dokümanı bulunamadı');
      }
      
      // Base64 verisini çıkar
      final data = doc.data();
      if (data == null) {
        throw Exception('Doküman verisi boş');
      }
      
      print('📋 Doküman alanları: ${data.keys.toList()}');
      
      // Yeni formatta imageData alanı kullanılıyor
      if (data.containsKey('imageData')) {
        final base64String = data['imageData'] as String;
        print('✅ ImageData alanı bulundu (${base64String.length} karakter)');
        
        // Base64'ü çöz
        try {
          final bytes = base64Decode(base64String);
          print('✅ Base64 çözüldü: ${bytes.length} bytes');
          
          if (mounted) {
            setState(() {
              _imageBytes = bytes;
              _isLoading = false;
            });
          }
        } catch (decodeError) {
          print('❌ Base64 çözme hatası: $decodeError');
          throw Exception('Base64 verisi çözülemedi: $decodeError');
        }
      } else {
        print('❌ imageData alanı bulunamadı. Mevcut alanlar: ${data.keys.toList()}');
        throw Exception('Doküman içinde imageData verisi yok');
      }
    } catch (e) {
      print('❌ Kategori görsel yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 8, color: Colors.red),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    }
    
    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Memory image hatası: $error');
        return const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.red,
            size: 24,
          ),
        );
      },
    );
  }
} 