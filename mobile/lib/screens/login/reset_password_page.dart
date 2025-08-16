import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.sendVerificationCode(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _codeSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre sıfırlama kodu e-posta adresinize gönderildi'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kod gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kodu girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _databaseService.verifyCode(_emailController.text.trim(), _codeController.text.trim());
      
      if (isValid) {
        if (mounted) {
          setState(() {
            _codeVerified = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kod doğrulandı. Yeni şifrenizi belirleyin'),
              backgroundColor: Color(0xFFBC8157),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kod yanlış veya süresi dolmuş'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kod doğrulama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kullanıcının e-posta adresine göre Firebase'den kullanıcıyı bul
      final methods = await _databaseService.auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      
      if (methods.isEmpty) {
        throw Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı');
      }
      
      // Firebase ile şifre sıfırlama e-postası gönder
      await _databaseService.auth.sendPasswordResetEmail(email: _emailController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen e-postanızı kontrol edin'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
        
        // Login sayfasına geri dön
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre sıfırlama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: screenWidth * 0.45,
                  height: screenWidth * 0.45,
                  decoration: const ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 94,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Back button
            Positioned(
              left: screenWidth * 0.061,
              top: padding.top + 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: OvalBorder(),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF121223),
                    size: 20,
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
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
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
              child: const Text(
                'Şifre Sıfırla',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                  'E-posta adresinizi girin ve şifre sıfırlama kodunu alın',
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
                      if (!_codeSent) ...[
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
                            enabled: !_codeSent,
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
                        
                        const SizedBox(height: 30),
                        
                        // Send Code Button
                        GestureDetector(
                          onTap: _isLoading ? null : _sendResetCode,
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
                                      'KOD GÖNDER',
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
                      ] else if (!_codeVerified) ...[
                        // Email display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.email, color: Color(0xFFBC8157)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _emailController.text,
                                  style: const TextStyle(
                                    color: Color(0xFF31343D),
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _codeSent = false;
                                    _codeController.clear();
                                  });
                                },
                                child: const Text(
                                  'Değiştir',
                                  style: TextStyle(
                                    color: Color(0xFFBC8157),
                                    fontSize: 12,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // KOD Label
                        const Text(
                          'DOĞRULAMA KODU',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Code Input Field
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '6 haneli kodu girin',
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
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Verify Code Button
                        GestureDetector(
                          onTap: _isLoading ? null : _verifyCode,
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
                                      'KODU DOĞRULA',
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
                        
                        // Resend code link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Kod gelmedi mi? ',
                              style: TextStyle(
                                color: Color(0xFF646982),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : _sendResetCode,
                              child: const Text(
                                'Tekrar Gönder',
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
                      ] else ...[
                        // YENİ ŞİFRE Label
                        const Text(
                          'YENİ ŞİFRE',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // New Password Input Field
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            decoration: InputDecoration(
                              hintText: 'Yeni şifrenizi girin',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA0A5BA),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFA0A5BA),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
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
                                return 'Yeni şifre gerekli';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // ŞİFRE TEKRAR Label
                        const Text(
                          'ŞİFRE TEKRAR',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Confirm Password Input Field
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Şifrenizi tekrar girin',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA0A5BA),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFA0A5BA),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                return 'Şifre tekrarı gerekli';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Reset Password Button
                        GestureDetector(
                          onTap: _isLoading ? null : _resetPassword,
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
                                      'ŞİFREYİ SIFIRLA',
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
                      ],
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