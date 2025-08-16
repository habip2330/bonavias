import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../profile/profile_page.dart';
import '../menu/menu_screen.dart';
import '../branches/branches.dart';
import '../notifications/notifications_page.dart';
import '../wallet/wallet_page.dart';
import '../main_navigation.dart';
import '../../services/database_service.dart';
import '../../services/campaign_service.dart';
import '../../models/campaign_model.dart';
import '../campaign/campaign_detail_page.dart';
import '../campaign/campaigns_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/slider_service.dart';
import '../../services/product_service.dart';
import '../../services/branch_service.dart';
import '../../services/notification_service.dart';
import '../../services/story_service.dart';
import '../../models/story_model.dart';
import '../products/product_detail_page.dart';
import '../../widgets/story_widget.dart';
import '../story/story_detail_page.dart';
import 'dart:convert';
import 'dart:math';
import '../../config/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final DatabaseService _db = DatabaseService();
  final SliderService _sliderService = SliderService();
  final ProductService _productService = ProductService();
  final BranchService _branchService = BranchService();
  String _userName = '';
  bool _isLoading = true;
  String _error = '';
  int _selectedNav = 0;
  String? _userId;
  
  // Kampanyalar için değişkenler
  List<Campaign> _campaigns = [];
  bool _loadingCampaigns = true;
  String _campaignError = '';

  // Popüler ürünler için değişkenler
  List<Map<String, dynamic>> _popularProducts = [];
  bool _loadingPopularProducts = true;
  String _popularProductsError = '';
  List<Map<String, dynamic>> _filteredPopularProducts = [];

  bool _loadingRecommendations = true;
  String _recommendationsError = '';

  Map<String, dynamic>? _userData;

  List<Map<String, dynamic>> _featuredProducts = [];
  List<Map<String, dynamic>> _popularCategories = [];
  List<Map<String, dynamic>> _activeCampaigns = [];
  List<Map<String, dynamic>> _sliders = [];
  List<Map<String, dynamic>> _stories = [];

  late Future<List<Map<String, dynamic>>> _sliderFuture;

  int _currentSliderPage = 0;
  final PageController _sliderPageController = PageController();
  
  // Bildirimler için değişkenler
  int _unreadNotificationCount = 0;
  bool _loadingNotifications = true;

  // Kampanyalar için PageView controller
  final PageController _campaignPageController = PageController();
  int _activeCampaignPage = 0;

  String _getGreeting() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final hour = now.hour;
    if (hour >= 18 || hour < 6) {
      return 'İyi Akşamlar!';
    } else {
      return 'İyi Günler!';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserIdAndInit();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sliderPageController.dispose();
    _campaignPageController.dispose(); // Kampanyalar için PageView controller'ı dispose et
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _loadUserIdAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
    _loadUserName();
    _loadCampaigns();
    _loadPopularProducts();
    _loadRecommendations();
    _loadData();
    _sliderFuture = _sliderService.getSliders();
    _loadStories();
    // Şube verilerini arka planda yükle
    _branchService.initializeBranches();
    _loadNotifications();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedFullName = prefs.getString('userFullName');
      String? storedUserName = prefs.getString('userName');
      
      if (storedFullName != null && storedFullName.isNotEmpty) {

        String firstName = storedFullName.split(' ').first;
        setState(() {
          _userName = firstName;
          _isLoading = false;
        });
      } else if (storedUserName != null && storedUserName.isNotEmpty) {
        // userName zaten sadece ilk isim (fallback)
        setState(() {
          _userName = storedUserName;
          _isLoading = false;
        });
      } else {
        // Varsayılan isim
        setState(() {
          _userName = 'Kullanıcı';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      if (mounted) {
        setState(() {
          _userName = 'Kullanıcı';
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _loadCampaigns() async {
    try {
      final campaigns = await CampaignService.getActiveCampaigns();
      if (mounted) {
        setState(() {
          _campaigns = campaigns;
          _loadingCampaigns = false;
        });
      }
    } catch (e) {
      print('Error loading campaigns: $e');
      if (mounted) {
        setState(() {
          _campaignError = 'Kampanyalar yüklenirken bir hata oluştu';
          _loadingCampaigns = false;
        });
      }
    }
  }

  Future<void> _loadPopularProducts() async {
    try {
      final products = await _db.getProducts();
      // Popüler ürün filtresini kaldır, tüm ürünleri göster
      final allProducts = products.toList();
      
      // Debug: Tüm ürünlerin görsel URL'lerini kontrol et
      print('🔍 Tüm ürünler yüklendi: ${allProducts.length} ürün');
      for (var product in allProducts) {
        print('📦 Ürün: ${product['name']} - Görsel URL: ${product['image_url']}');
      }
      
      if (mounted) {
        setState(() {
          _popularProducts = allProducts;
          _loadingPopularProducts = false;
          _filterPopularProducts(); // Kategori filtresi uygula
        });
      }
    } catch (e) {
      print('Error loading popular products: $e');
      if (mounted) {
        setState(() {
          _popularProductsError = 'Ürünler yüklenirken bir hata oluştu';
          _loadingPopularProducts = false;
        });
      }
    }
  }

  void _filterPopularProducts() {
    // Tüm ürünleri göster
    _filteredPopularProducts = _popularProducts;
    
    // Ürünleri ekleme tarihine göre sırala (ilk eklenen ilk başta)
    _filteredPopularProducts.sort((a, b) {
      final aCreated = a['created_at'] as String? ?? '';
      final bCreated = b['created_at'] as String? ?? '';
      return aCreated.compareTo(bCreated); // ASC sıralama (eski tarih önce)
    });
  }

  Future<void> _loadRecommendations() async {
    try {
      // Şimdilik mock data kullanıyoruz
      if (mounted) {
    setState(() {
      _loadingRecommendations = false;
    });
      }
    } catch (e) {
      print('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _recommendationsError = 'Öneriler yüklenirken bir hata oluştu';
          _loadingRecommendations = false;
        });
      }
    }
  }

  Future<void> _loadStories() async {
    try {
      final List<Story> apiStories = await StoryService.fetchActiveStories();
      final List<Map<String, dynamic>> stories = [];
      for (Story story in apiStories) {
        final List<StoryItem> storyItems = await StoryService.fetchStoryItems(story.id);
        if (storyItems.isNotEmpty) {
          stories.add({
            'id': story.id,
            'title': story.title,
            'userImage': _buildFullImageUrl(story.imageUrl),
            'isViewed': false,
          });
        }
      }
      if (mounted) {
        setState(() {
          _stories = stories;
        });
      }
    } catch (e) {
      print('Error loading stories from API: $e');
      if (mounted) {
        setState(() {
          _stories = [];
        });
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      // Gerçek bildirim verilerini yükle
      final notifications = await _db.getNotifications();
      if (mounted) {
        // Okunmamış bildirim sayısını hesapla
        int unreadCount = notifications.where((notification) => 
          notification['is_read'] == false || notification['is_read'] == null
        ).length;
        
        setState(() {
          _unreadNotificationCount = unreadCount;
          _loadingNotifications = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _unreadNotificationCount = 0; // Hata durumunda 0 göster
          _loadingNotifications = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final featuredProducts = await _productService.getProducts();
      setState(() {
        _featuredProducts = featuredProducts.where((p) => p['is_featured'] == true).toList();
      });

      final allCategories = await _db.getCategories();
      setState(() {
        _popularCategories = allCategories.where((c) => c['is_popular'] == true).toList();
      });

      // Load active campaigns
      final activeCampaigns = await CampaignService.getActiveCampaigns();
      setState(() {
        _activeCampaigns = activeCampaigns.map((c) => c.toMap()).toList();
      });

      final allSliders = await _sliderService.getSliders();
      print('API slider verisi: $allSliders');
      setState(() {
        _sliders = allSliders;
        print('Ekrana yazılacak sliderlar: $_sliders');
      });

    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        _error = 'Veriler yüklenirken bir hata oluştu';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Resim URL'ini tam adresle birleştirmek için yardımcı metod
  String _buildFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // URL zaten tam adres
      return imageUrl;
    } else if (imageUrl.startsWith('/public/')) {
      // Sunucu adresiyle birleştir
      return 'http://192.168.1.105:3001$imageUrl';
    } else {
      // Varsayılan olarak sunucu adresiyle birleştir
      return 'http://192.168.1.105:3001$imageUrl';
    }
  }

  void _onStoryTap(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Story',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return StoryDetailPage(story: _stories[index]);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  List<String> _extractAllergens(Map<String, dynamic> product) {
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
    return allergens;
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image_url'] ?? '';
    final productName = product['name'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              productId: product['id']?.toString() ?? '',
              title: productName,
              category: product['category_name'] ?? '',
              imageUrl: imageUrl.isNotEmpty ? _buildFullImageUrl(imageUrl) : null,
              price: product['price']?.toString() ?? '',
              description: product['description'] ?? '',
              allergens: _extractAllergens(product),
            ),
          ),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl.isNotEmpty
                  ? Image.network(
                      _buildFullImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
              ),
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181828),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Base64 formatındaki görselleri Image widget'ında kullanmak için yardımcı metod
  Widget _buildCampaignImage(String imageUrl) {
    final fullUrl = _buildFullImageUrl(imageUrl);
    
    if (imageUrl.startsWith('data:image')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image load error for URL: $fullUrl - Error: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GRADIENT HEADER
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Floating Greeting Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Merhaba ',
                                style: TextStyle(fontSize: 20, color: AppTheme.primaryColor),
                                children: [
                                  TextSpan(
                                    text: _userName.isNotEmpty ? _userName : 'Kullanıcı',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                  TextSpan(
                                    text: ',  ${_getGreeting()}',
                                    style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationsPage()),
                              );
                              _loadNotifications();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.10),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor, size: 24),
                                ),
                                if (_unreadNotificationCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      child: Text(
                                        _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Story Barı (Bubble tarzı)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: StoryWidget(
                        stories: _stories,
                        onStoryTap: _onStoryTap,
                        // bubbleStyle: true, // Eğer widget destekliyorsa
                      ),
                    ),
                    // Cüzdan Kartı (Glassmorphic)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletPage()),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.10),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            backgroundBlendMode: BlendMode.overlay,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 18),
                                child: Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor, size: 38),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cüzdanım', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('${_userData?['balance']?.toStringAsFixed(2) ?? '0.00'}₺', style: TextStyle(color: AppTheme.primaryColor, fontSize: 18)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ALT ALAN (SOFT BEJ KUTU)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8E9E0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown,
                    blurRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Popüler Ürünler (Yatay kaydırmalı, büyük kartlar)
                    Container(
                      margin: const EdgeInsets.only(top: 32, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popüler Ürünler',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B4B2A)),
                          ),
                          TextButton(
                            onPressed: () {
                              NavigationController.switchToTab(1);
                            },
                            child: const Text('Tümünü Gör', style: TextStyle(color: Color(0xFFB8835A))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: _loadingPopularProducts
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8835A)))
                          : _popularProductsError.isNotEmpty
                              ? Center(child: Text(_popularProductsError, style: const TextStyle(color: Colors.red)))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _filteredPopularProducts.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final product = _filteredPopularProducts[index];
                                    return Container(
                                      width: 160,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.brown.withOpacity(0.06),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _buildProductCard(product),
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 32),
                    // Kampanyalar (Kare kartlar, carousel ve dots)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Kampanyalar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B4B2A)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_campaigns.isEmpty)
                      Center(child: Text('Kampanya yok', style: TextStyle(color: Colors.grey)))
                    else ...[
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          itemCount: _campaigns.length,
                          controller: _campaignPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _activeCampaignPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final campaign = _campaigns[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CampaignDetailPage(campaign: campaign),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    image: campaign.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(_buildFullImageUrl(campaign.imageUrl!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey[300],
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.brown.withOpacity(0.10),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.black.withOpacity(0.18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            campaign.title ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            campaign.description ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_campaigns.length, (index) =>
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _activeCampaignPage == index ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _activeCampaignPage == index ? Color(0xFF7B4B2A) : Color(0xFFD7A86E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedNav = index;
    });
  }

  void _onQRCodePressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CampaignsPage()),
    );
  }



}

 