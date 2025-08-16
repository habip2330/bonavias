import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/fcm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Sistem UI ayarları
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // FCM token alma işlemini başlat
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      print('🔔 FCM başlatma süreci başladı...');
      
      final fcmService = FCMService();
      await fcmService.initializeLocalNotifications();
      await fcmService.saveFCMToken();
      
      // Test local notification göster
      await fcmService.showLocalNotification(
        title: 'FCM Test',
        body: 'FCM token başarıyla alındı!',
      );
      
      print('✅ FCM başarıyla başlatıldı');
    } catch (e) {
      print('❌ FCM başlatma hatası: $e');
    }
    
    // 3 saniye sonra ana sayfaya yönlendir
    Future.delayed(const Duration(seconds: 3), () {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      int? loginTimestamp = prefs.getInt('loginTimestamp');
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (!mounted) return;

      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
        return;
      }
      
      if (isLoggedIn && loginTimestamp != null) {
        // 30 gün = 30 * 24 * 60 * 60 * 1000 milisaniye
        const thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000;
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        
        if (currentTime - loginTimestamp < thirtyDaysInMs) {
          // 30 gün geçmemiş, direkt ana navigasyon sayfasına git
          Navigator.pushReplacementNamed(context, '/home');
          return;
        } else {
          // 30 gün geçmiş, oturumu sonlandır
          await prefs.remove('isLoggedIn');
          await prefs.remove('loginTimestamp');
          await prefs.remove('userId');
          await prefs.remove('userEmail');
          await prefs.remove('userName');
        }
      }
      
      // Giriş yapmamış veya oturumu dolmuş, login sayfasına git
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Otomatik giriş kontrolü hatası: $e');
      // Hata durumunda login sayfasına git
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFBC8157),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFBC8157),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            // Üst dekoratif daire
            Positioned(
              left: screenWidth * 0.35,
              top: -(screenHeight * 0.15),
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: screenWidth * 0.45,
                  height: screenWidth * 0.45,
                  decoration: ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 94,
                        color: Colors.white.withOpacity(0.1),
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Alt dekoratif daire
            Positioned(
              right: -(screenWidth * 0.25),
              bottom: -(screenHeight * 0.12),
              child: Container(
                width: screenWidth * 0.74,
                height: screenHeight * 0.36,
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: BorderSide(
                      width: 50,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: const Color(0xFFFFD78C).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
            
            // Ana logo ve içerik
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bonavias Logo
                    Container(
                      width: screenWidth * 0.71,
                      height: screenHeight * 0.17,
                      child: Image.asset(
                        'assets/images/bonavias-logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Logo yükleme hatası: $error');
                          // Fallback - eğer logo yoksa text logo
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: const Text(
                              'bonavias',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    const SizedBox(height: 40),
                    
                    // Loading indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 