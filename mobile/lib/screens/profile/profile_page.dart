import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../login/login_page.dart';
import 'personal_info_page.dart';
import '../../screens/campaign/campaigns_page.dart';
import '../../screens/notifications/notifications_page.dart';
import '../../screens/faq/faq_page.dart';
import '../../screens/wallet/wallet_page.dart';
import '../../screens/address/addresses_screen.dart';
import '../home/home_page.dart';
import '../menu/menu_page.dart';
import '../branches/branches.dart';
import '../../widgets/modern_ui_components.dart';
import '../home/home_page.dart';
import '../../screens/wallet/payment_history_page.dart';
import '../../config/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _userName = '';
  String _userFullName = '';
  String _profileImageUrl = '';
  String _loginMethod = '';
  int _selectedNav = 3; // Profile is index 3

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Sistem UI ayarları
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      // SharedPreferences'tan kullanıcı bilgilerini al
      setState(() {
        _userName = prefs.getString('userName') ?? '';
        _userFullName = prefs.getString('userFullName') ?? '';
        _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
        _loginMethod = prefs.getString('loginMethod') ?? '';
      });
      
      if (userId != null) {
        final userData = await _databaseService.getUserData(userId);
        setState(() {
          _userData = userData ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Firebase'den çıkış yap
      await FirebaseAuth.instance.signOut();
      
      // SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        // Login sayfasına yönlendir ve tüm önceki sayfaları temizle
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Çıkış yapma hatası: $e');
      // Hata durumunda da login sayfasına yönlendir
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      // Scaffold arka planı
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Profile Section
                Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Profile Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDisplayName(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 20,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bona Seni Seviyor',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Hesap Alanı
                const SizedBox(height: 24),
                Text(
                  'Hesap',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        iconColor: Theme.of(context).colorScheme.primary,
                        text: 'Kişisel Bilgiler',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalInfoPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Cüzdan Alanı
                const SizedBox(height: 24),
                Text(
                  'Cüzdan',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppTheme.secondaryColor,
                        text: 'Cüzdan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.transparent),
                      _buildMenuItem(
                        icon: Icons.receipt_long,
                        iconColor: AppTheme.primaryColor,
                        text: 'Hesap Hareketleri',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentHistoryPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Bize Ulaşın
                const SizedBox(height: 24),
                Text(
                  'Bize Ulaşın',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.mail_outline,
                        iconColor: AppTheme.cardColor,
                        text: 'Bize Ulaşın',
                        onTap: () {
                          // Bize Ulaşın işlemi
                        },
                      ),
                      const Divider(height: 1, color: Colors.transparent),
                      _buildMenuItem(
                        icon: Icons.support_agent,
                        iconColor: AppTheme.successColor,
                        text: 'Bona Asistan',
                        onTap: () {
                          // Bona Asistan işlemi
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Politikalar
                Text(
                  'Politikalar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: Color(0xFF8D9440),
                        text: 'Kullanıcı Sözleşmesi',
                        onTap: () {
                          // Kullanıcı Sözleşmesi sayfasına yönlendirme
                        },
                      ),
                      const Divider(height: 1, color: Colors.transparent),
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: Color(0xFFBC8157),
                        text: 'Kişisel Veri Aydınlatma Metni',
                        onTap: () {
                          // KVKK sayfasına yönlendirme
                        },
                      ),
                      const Divider(height: 1, color: Colors.transparent),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        iconColor: Color(0xFFD7A86E),
                        text: 'Ticari Aydınlatma Metni',
                        onTap: () {
                          // Ticari Aydınlatma sayfasına yönlendirme
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                
                // Group 4: Logout (Single Item)
                // Çıkış Yap butonunu en alta taşı (Expanded yok)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildMenuItem(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFFF4757),
                    text: 'Çıkış Yap',
                    onTap: _logout,
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 15),
            
            // Text
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF32343E),
                  fontSize: 16,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFA0A5BA),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName() {
    if (_userFullName.isNotEmpty) {
      return _userFullName;
    } else if (_userData?['name'] != null && _userData!['name'].isNotEmpty) {
      return _userData!['name'];
    } else if (_userName.isNotEmpty) {
      return _userName;
    } else {
      return 'Örnek İsim';
    }
  }


} 