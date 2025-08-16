import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import '../../services/database_service.dart';
import '../main_screen.dart';
import '../main_navigation.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import '../../widgets/modern_ui_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
  }

  String _extractFirstName(String? fullName, String? email) {
    String name = fullName ?? email?.split('@').first ?? 'Kullanıcı';
    return name.split(' ').first;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _databaseService.authenticateUser(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      final user = userCredential.user;
      if (user != null) {
        try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', _extractFirstName(user.displayName, user.email));
          await prefs.setString('userFullName', user.displayName ?? '');
          await prefs.setString('profileImageUrl', user.photoURL ?? '');
          await prefs.setString('loginMethod', 'email');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        } catch (prefsError) {
          print('SharedPreferences hatası: $prefsError');
          // Yine de devam et
        if (mounted) {
          Navigator.pushReplacement(
            context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
          );
          }
        }
      } else {
        if (mounted) {
          ModernUIComponents.showModernSnackBar(context, 'E-posta veya şifre hatalı', isError: true);
        }
      }
    } catch (e) {
      print('Giriş hatası: $e');
      if (mounted) {
        String errorMessage = 'Giriş başarısız';
        if (e.toString().contains('type')) {
          errorMessage = 'Giriş işlemi tamamlandı ancak veri işlemede sorun yaşandı';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'Bu e-posta adresi kayıtlı değil';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Şifre hatalı';
        }
        
        ModernUIComponents.showModernSnackBar(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _databaseService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        print('Google Sign-In başarılı: ${user.email}');
        
        // Güvenli shared preferences işlemi
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', _extractFirstName(user.displayName, user.email));
          await prefs.setString('userFullName', user.displayName ?? '');
          await prefs.setString('profileImageUrl', user.photoURL ?? '');
          await prefs.setString('loginMethod', 'google');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        } catch (prefsError) {
          print('SharedPreferences hatası: $prefsError');
          // Yine de devam et
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        }
      } else {
        // User canceled or failed
        if (mounted) {
          ModernUIComponents.showModernSnackBar(context, 'Google ile giriş iptal edildi', isError: true);
        }
      }
    } catch (e) {
      print('Google giriş hatası: $e');
      
      // Type casting hatası varsa ve Firebase authentication başarılıysa, devam et
      if (e.toString().contains('type') && e.toString().contains('PigeonUserDetails')) {
        print('Type casting hatası ama authentication başarılı, devam ediliyor...');
        
        // Firebase'den current user bilgisini al
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userId', currentUser.uid);
            await prefs.setString('userEmail', currentUser.email ?? '');
            await prefs.setString('userName', _extractFirstName(currentUser.displayName, currentUser.email));
            await prefs.setString('userFullName', currentUser.displayName ?? '');
            await prefs.setString('profileImageUrl', currentUser.photoURL ?? '');
            await prefs.setString('loginMethod', 'google');
            await prefs.setBool('isLoggedIn', true);
            await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
            
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationPage()),
              );
            }
            return;
          } catch (prefsError) {
            print('SharedPreferences hatası: $prefsError');
          }
        }
      }
      
      String errorMessage = 'Google ile giriş başarısız';
      
      if (mounted) {
        ModernUIComponents.showModernSnackBar(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _databaseService.signInWithApple();
      
      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', _extractFirstName(user.displayName, user.email));
          await prefs.setString('userFullName', user.displayName ?? '');
          await prefs.setString('profileImageUrl', user.photoURL ?? '');
          await prefs.setString('loginMethod', 'apple');
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        } catch (prefsError) {
          print('SharedPreferences hatası: $prefsError');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        }
      } else {
        if (mounted) {
          ModernUIComponents.showModernSnackBar(context, 'Apple ile giriş iptal edildi', isError: true);
        }
      }
    } catch (e) {
      print('Apple giriş hatası: $e');
      String errorMessage = 'Apple ile giriş başarısız';
      
      if (e.toString().contains('sadece iOS')) {
        errorMessage = 'Apple ile giriş sadece iOS cihazlarda kullanılabilir';
      } else if (e.toString().contains('kullanılamıyor')) {
        errorMessage = 'Apple ile giriş bu cihazda desteklenmiyor';
      }
      
      if (mounted) {
        ModernUIComponents.showModernSnackBar(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _databaseService.signInWithFacebook();
      
      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', _extractFirstName(user.displayName, user.email));
          await prefs.setString('userFullName', user.displayName ?? '');
          await prefs.setString('profileImageUrl', user.photoURL ?? '');
          await prefs.setString('loginMethod', 'facebook');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        } catch (prefsError) {
          print('SharedPreferences hatası: $prefsError');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          }
        }
      } else {
        if (mounted) {
          ModernUIComponents.showModernSnackBar(context, 'Facebook ile giriş iptal edildi', isError: true);
        }
      }
    } catch (e) {
      print('Facebook giriş hatası: $e');
      String errorMessage = 'Facebook ile giriş başarısız';
      
      if (e.toString().contains('iptal edildi')) {
        errorMessage = 'Facebook ile giriş iptal edildi';
      }
      
      if (mounted) {
        ModernUIComponents.showModernSnackBar(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF121223),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            // Background circle decoration
            Positioned(
              left: -(screenWidth * 0.21),
              top: -(screenHeight * 0.12),
              child: Container(
                width: screenWidth * 0.45,
                height: screenWidth * 0.45,
                decoration: const ShapeDecoration(
                  shape: OvalBorder(
                    side: BorderSide(
                      width: 94,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Color(0xFF1E1E2E),
                    ),
                  ),
                ),
              ),
            ),
            
            // White container for form
            Positioned(
              left: 0,
              top: screenHeight * 0.29,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.71,
                decoration: ShapeDecoration(
                  color: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
            
            // Title
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: Text(
                'Giriş Yap',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            // Subtitle
            Positioned(
              top: screenHeight * 0.19,
              left: 0,
              right: 0,
              child: const Opacity(
                opacity: 0.85,
                child: Text(
                  'Lütfen mevcut hesabınıza giriş yapın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                    height: 1.62,
                  ),
                ),
              ),
            ),
            
            // Form
            Positioned(
              left: screenWidth * 0.061,
              top: screenHeight * 0.32,
              child: SizedBox(
                width: screenWidth * 0.878,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // E-POSTA Label
                      const Text(
                        'E-POSTA',
                        style: TextStyle(
                          color: Color(0xFF31343D),
                          fontSize: 13,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Email Input Field
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'örnek@gmail.com',
                            hintStyle: TextStyle(
                              color: Color(0xFFA0A5BA),
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 14,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta adresi gerekli';
                            }
                            if (!value.contains('@')) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // ŞİFRE Label
                      const Text(
                        'ŞİFRE',
                        style: TextStyle(
                          color: Color(0xFF31343D),
                          fontSize: 13,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Password Input Field
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '**********',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA0A5BA),
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 6.72,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFA0A5BA),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 14,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Remember me and forgot password row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _rememberMe ? const Color(0xFFBC8157) : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _rememberMe ? const Color(0xFFBC8157) : const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: _rememberMe
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Beni Hatırla',
                                style: TextStyle(
                                  color: Color(0xFF646982),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Şifremi Unuttum',
                              style: TextStyle(
                                color: Color(0xFFBC8157),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Login Button
                      GestureDetector(
                        onTap: _isLoading ? null : _login,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFBC8157),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'GİRİŞ YAP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text(
                                'veya',
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
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Social Login Buttons
                      // Google Login
                      GestureDetector(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage("https://developers.google.com/identity/images/g-logo.png"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Google İle Giriş Yap',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Apple Login (Sadece iOS)
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _isLoading ? null : _signInWithApple,
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: ShapeDecoration(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.apple,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Apple İle Giriş Yap',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      
                      // Facebook Login
                      GestureDetector(
                        onTap: _isLoading ? null : _signInWithFacebook,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF1877F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Facebook İle Giriş Yap',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabınız yok mu? ',
                            style: TextStyle(
                              color: Color(0xFF646982),
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: Color(0xFFBC8157),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }
} 
