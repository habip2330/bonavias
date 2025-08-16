import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Merhaba',
      description: 'Bonavias Coffee & Dessert dünyasına hoş geldiniz. Tatlı ve kahve tutkunuzu en iyi şekilde karşılamak için buradayız.',
      imageUrl: 'assets/images/onboarding1.png', // Placeholder görsel
    ),
    OnboardingPage(
      title: 'Size Özel Kampanyalar',
      description: 'Size özel kampanya ve fırsatlarla dolu bir dünya sizi bekliyor. Sadece Bonavias\'a özel avantajları kaçırmayın.',
      imageUrl: 'assets/images/onboarding2.png',
    ),
    OnboardingPage(
      title: 'QR İle Ödeme',
      description: 'Uygulamadaki cüzdanınıza bakiye yükleyin, QR kodu okutarak kolayca ödeyin. Bonavias\'ta ödeme artık daha pratik!',
      imageUrl: 'assets/images/onboarding3.png',
    ),
    OnboardingPage(
      title: 'Bana Seni Seviyor',
      description: '7/24 müşteri desteği, güvenli ödeme sistemi ve profesyonel hizmet anlayışı ile fark yaratıyoruz.', // 4. sayfada açıklama yok
      imageUrl: 'assets/images/onboarding4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Sistem UI ayarları
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            // Ana içerik
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_pages[index]);
              },
            ),
            
            
            // Sıradaki butonu
            Positioned(
              left: 24,
              right: 24,
              bottom: screenHeight * 0.14,
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  height: 62,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBC8157),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'BAŞLA' : 'SIRADAKİ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Atla butonu - sadece ilk 3 sayfada göster
            if (_currentPage < 3)
              Positioned(
                left: 0,
                right: 0,
                bottom: screenHeight * 0.09,
                child: Center(
                  child: GestureDetector(
                    onTap: _skipOnboarding,
                    child: const Text(
                      'Atla',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF646982),
                        fontSize: 16,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Sayfa göstergeleri (dots)
            Positioned(
              left: 0,
              right: 0,
              bottom: screenHeight * 0.25,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: ShapeDecoration(
                        color: _currentPage == index 
                            ? const Color(0xFFBC8157) 
                            : const Color(0xFFFFE0CD),
                        shape: const OvalBorder(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Üst boşluk
          SizedBox(height: screenHeight * 0.1),
          
          // Görsel alan
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.35,
            decoration: ShapeDecoration(
              color: const Color(0xFF98A8B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                page.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder eğer görsel yoksa
                  return Container(
                    decoration: ShapeDecoration(
                      color: const Color(0xFF98A8B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Başlık ve açıklama arası boşluk
          SizedBox(height: screenHeight * 0.08),
          
          // Başlık
          Container(
            width: double.infinity,
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF31343D),
                fontSize: 28,
                fontFamily: 'Sen',
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          
          // Başlık ve açıklama arası boşluk
          SizedBox(height: screenHeight * 0.03),
          
          // Açıklama - 4. sayfada gösterme
          if (page.description.isNotEmpty)
            Container(
              width: double.infinity,
              child: Text(
                page.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF646982),
                  fontSize: 16,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          
          // Alt kısım için boşluk
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
} 