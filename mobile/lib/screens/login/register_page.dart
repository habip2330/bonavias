import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBC8157),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF31343D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _databaseService.registerUser(
        _emailController.text,
        _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        // Kullanıcı bilgilerini Firestore'a kaydet
        try {
          await _databaseService.firestore.collection('users').doc(user.uid).set({
            'email': _emailController.text.trim(),
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'birth_date': _selectedBirthDate?.toIso8601String(),
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'is_verified': false,
            'profile_image_url': '',
            'login_method': 'email',
          });
          
          print('✅ Kullanıcı bilgileri Firestore\'a kaydedildi');
        } catch (e) {
          print('❌ Firestore kayıt hatası: $e');
          // Firestore hatası olsa bile devam et
        }
        
        // Verification kodu gönder
        try {
          await _databaseService.sendVerificationCode(_emailController.text.trim());
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationPage(
                  email: _emailController.text.trim(),
                ),
              ),
            );
          }
        } catch (e) {
          print('Verification kodu gönderme hatası: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification kodu gönderilemedi: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu e-posta adresi zaten kullanımda'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Kayıt hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
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
                'Kayıt Ol',
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
                  'Başlamak için lütfen kaydolun',
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
            
            // Scrollable Form Area
            Positioned(
              left: 0,
              top: screenHeight * 0.29,
              child: SizedBox(
                width: screenWidth,
                height: screenHeight * 0.71,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.061, 24, screenWidth * 0.061, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ADINIZ & SOYADINIZ
                        const Text(
                          'ADINIZ & SOYADINIZ',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Adınız ve soyadınız',
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
                                return 'Ad ve soyad gerekli';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // E-POSTA
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
                        
                        // TELEFON
                        const Text(
                          'TELEFON',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '+90 5XX XXX XX XX',
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
                                return 'Telefon numarası gerekli';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // DOĞUM TARİHİ
                        const Text(
                          'DOĞUM TARİHİ',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 13,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectBirthDate,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedBirthDate != null
                                        ? _formatDate(_selectedBirthDate!)
                                        : 'GG/AA/YYYY',
                                    style: TextStyle(
                                      color: _selectedBirthDate != null
                                          ? const Color(0xFF31343D)
                                          : const Color(0xFFA0A5BA),
                                      fontSize: 14,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFFA0A5BA),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // ŞİFRE
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
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6.65,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFA0A5BA),
                                  size: 18,
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
                        
                        const SizedBox(height: 20),
                        
                        // ŞİFRE TEKRAR
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
                              hintText: '**********',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA0A5BA),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6.65,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFA0A5BA),
                                  size: 18,
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
                              if (value != _passwordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Register Button
                        GestureDetector(
                          onTap: _isLoading ? null : _register,
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
                                      'KAYIT OL',
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
                        
                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Zaten hesabınız var mı? ',
                              style: TextStyle(
                                color: Color(0xFF646982),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Giriş Yap',
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
            ),
          ],
        ),
      ),
    );
  }
} 