import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final String title;
  final String category;
  final String? imageUrl;
  final String price;
  final String description;
  final List<String>? allergens;

  const ProductDetailPage({
    Key? key,
    required this.productId,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.price,
    required this.description,
    this.allergens,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isImageLoading = false;
  ImageProvider? _loadedImage;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null && widget.imageUrl!.startsWith('firestore://')) {
      _loadFirestoreImage();
    }
  }

  // Firestore'dan base64 görselini yükle
  Future<void> _loadFirestoreImage() async {
    if (widget.imageUrl == null) return;
    
    setState(() {
      _isImageLoading = true;
      _imageError = null;
    });

    try {
      print('🔍 Firestore ürün detay görseli yükleniyor: ${widget.imageUrl}');
      
      // firestore://collection/docId formatından parçaları çıkar
      final parts = widget.imageUrl!.replaceFirst('firestore://', '').split('/');
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
      
      setState(() {
        _loadedImage = MemoryImage(bytes);
        _isImageLoading = false;
      });
    } catch (e) {
      print('❌ Firestore görsel yükleme hatası: $e');
      setState(() {
        _imageError = e.toString();
        _isImageLoading = false;
      });
    }
  }

  // Görsel sağlayıcısını al
  ImageProvider _getImageProvider(String url) {
    // Halihazırda yüklenmiş bir Firestore görseli varsa onu kullan
    if (_loadedImage != null) {
      return _loadedImage!;
    }
    
    try {
      // Placeholder image URL
      const placeholderUrl = 'https://via.placeholder.com/400?text=Ürün+Görseli';
      
      // URL formatına göre işle
      if (url.startsWith('http://') || url.startsWith('https://')) {
        print('🌐 Network image: $url');
        return NetworkImage(url);
      } else if (url.startsWith('data:image')) {
        print('📊 Base64 embedded image detected');
        return NetworkImage(url);
      } else if (url.startsWith('firestore://')) {
        // Firestore görseli yüklenene kadar placeholder göster
        return const NetworkImage(placeholderUrl);
      } else {
        print('⚠️ Unknown image format: $url');
        return const NetworkImage(placeholderUrl);
      }
    } catch (e) {
      print('❌ Error creating image provider: $e');
      return const NetworkImage('https://via.placeholder.com/400?text=Görsel+Yüklenemedi');
    }
  }

  // Alerjen türüne göre ikon döndürür
  IconData _getAllergenIcon(String allergenKey) {
    switch (allergenKey.toLowerCase()) {
      case 'egg':
        return Icons.egg;
      case 'peanut':
        return Icons.scatter_plot;
      case 'milk':
        return Icons.local_drink;
      case 'nuts':
        return Icons.nature;
      case 'salt':
        return Icons.grain;
      case 'soy':
        return Icons.eco;
      case 'fish':
        return Icons.set_meal;
      case 'shellfish':
        return Icons.waves;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sabit alerjen listesi (anahtar, etiket)
    final List<Map<String, dynamic>> allergenList = [
      {'key': 'gluten', 'label': 'Gluten'},
      {'key': 'egg', 'label': 'Yumurta'},
      {'key': 'peanut', 'label': 'Yer fıstığı'},
      {'key': 'milk', 'label': 'Süt'},
      {'key': 'nuts', 'label': 'Sert kabuklu'},
      {'key': 'salt', 'label': 'tuz'},
    ];

    // Detaylı açıklama metinleri ve ikon yolları, sıralı şekilde
    final List<Map<String, String>> allergenDisplayList = [
      {
        'key': 'nuts',
        'icon': 'assets/icons/urundetay/sert-kabuklu.png',
        'desc': 'Sert kabuklu yemişler (badem, fındık, ceviz, kaju, Antep fıstığı vb.)',
      },
      {
        'key': 'milk',
        'icon': 'assets/icons/urundetay/sut.png',
        'desc': 'Süt ve süt ürünleri (laktoz dahil)',
      },
      {
        'key': 'peanut',
        'icon': 'assets/icons/urundetay/yer-fistigi.png',
        'desc': 'Yer fıstığı ve ürünleri',
      },
      {
        'key': 'egg',
        'icon': 'assets/icons/urundetay/yumurta.png',
        'desc': 'Yumurta ve yumurta ürünleri',
      },
      {
        'key': 'gluten',
        'icon': 'assets/icons/urundetay/gluten.png',
        'desc': 'Gluten (Buğday, çavdar, arpa, yulaf vb.)',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26), // Top padding for status bar
              
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                  colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                        shape: OvalBorder(),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Geri',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 17,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 46), // Space before image
              
              // Product Image - Ana görsel
              Container(
                width: double.infinity,
                height: 290,
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? (widget.imageUrl!.startsWith('firestore://')
                          ? FirestoreImage(url: widget.imageUrl!, fit: BoxFit.cover)
                          : Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Görsel yükleme hatası: $error');
                                return Container(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Görsel yüklenemedi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                );
                              },
                            ))
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood,
                                color: Colors.white,
                                size: 64,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ürün Görseli',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 21), // Space after image
              
              // Product Name
              Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Product Description
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.description.isNotEmpty ? widget.description : 'Ürün açıklaması mevcut değil',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                    height: 1.71,
                  ),
                ),
              ),
              
              const SizedBox(height: 28), // Space before ingredients
              
              // İçindekiler Label
              Text(
                'İÇİNDEKİLER',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                ),
              ),
              
              const SizedBox(height: 18), // Space before ingredients list
              
              // İçindekiler Listesi (Tüm Allergenler)
              if (widget.allergens != null && widget.allergens!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: allergenDisplayList
                      .where((item) => widget.allergens!.any((a) => a.toLowerCase() == item['key'] || a.toLowerCase() == _trKey(item['key']!)))
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                    colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      item['icon']!,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item['desc']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF3E2723),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                )
              else
                // Alerjen yoksa varsayılan gösterim
                SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'İçerik bilgisi\nmevcut değil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 26), 
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonavias Delivers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DeliveryServiceButton(
                          image: 'assets/icons/yemeksepeti.png',
                          label: 'Yemeksepeti',
                          onTap: () {
                            // launchUrl('https://www.yemeksepeti.com/');
                          },
                        ),
                        _DeliveryServiceButton(
                          image: 'assets/icons/getiryemek.png',
                          label: 'GetirYemek',
                          onTap: () {
                            // launchUrl('https://getir.com/');
                          },
                        ),
                        _DeliveryServiceButton(
                          image: 'assets/icons/trendyolyemek.png',
                          label: 'TrendyolYemek',
                          onTap: () {
                            // launchUrl('https://trendyol.com/');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
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
          width: 24, 
          height: 24,
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

class _DeliveryServiceButton extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const _DeliveryServiceButton({
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
} 

String _trKey(String key) {
  switch (key) {
    case 'nuts':
      return 'sert kabuklu';
    case 'milk':
      return 'süt';
    case 'peanut':
      return 'yer fıstığı';
    case 'egg':
      return 'yumurta';
    default:
      return key;
  }
} 