import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_service.dart';
import '../main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String? verificationCode;

  const VerificationPage({
    Key? key,
    required this.email,
    this.verificationCode,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  bool _isVerified = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _sendInitialCode();
  }

  void _sendInitialCode() async {
    try {
      await _databaseService.sendVerificationCode(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama kodu e-posta adresinize gönderildi'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification kodu gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  void _resendCode() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.sendVerificationCode(widget.email);
      if (mounted) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama kodu tekrar gönderildi'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
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

  void _verifyCode() async {
    String code = _controllers.map((controller) => controller.text).join();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 6 haneli kodu tam olarak girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verification kodunu doğrula
      final isValid = await _databaseService.verifyCode(widget.email, code);
      
      if (isValid) {
        // Firestore'daki kullanıcı bilgilerini güncelle
        try {
          final user = _databaseService.currentUser;
          if (user != null) {
            await _databaseService.firestore.collection('users').doc(user.uid).update({
              'is_verified': true,
              'verified_at': FieldValue.serverTimestamp(),
              'updated_at': FieldValue.serverTimestamp(),
            });
            print('✅ Kullanıcı doğrulandı ve Firestore güncellendi');
          }
        } catch (e) {
          print('❌ Firestore güncelleme hatası: $e');
          // Firestore hatası olsa bile devam et
        }
        
        // Kullanıcı bilgilerini kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', widget.email);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doğrulama kodu yanlış veya süresi dolmuş'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama hatası: $e'),
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

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto verify when all 6 digits are entered
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _verifyCode();
      });
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
                'Doğrulama',
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
                  'E-posta adresinize gönderilen 6 haneli kodu girin',
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
            
            // Email display
            Positioned(
              top: screenHeight * 0.23,
              left: 0,
              right: 0,
              child: Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w700,
                  height: 1.48,
                ),
              ),
            ),
            
            // KOD Label
            Positioned(
              left: screenWidth * 0.061,
              top: screenHeight * 0.32,
              child: const Text(
                'KOD',
                style: TextStyle(
                  color: Color(0xFF31343D),
                  fontSize: 13,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Code input fields ve tekrar gönder
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.35,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: EdgeInsets.only(right: index < 5 ? screenWidth * 0.032 : 0),
                        child: Container(
                          width: screenWidth * 0.11,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF31343D),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                color: Color(0xFF31343D),
                                fontSize: 16,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) => _onCodeChanged(value, index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Kodu almadınız mı? ',
                        style: TextStyle(
                          color: Color(0xFF646982),
                          fontSize: 14,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendTimer == 0 && !_isLoading ? _resendCode : null,
                        child: _resendTimer == 0
                            ? const Text(
                                'Tekrar Gönder',
                                style: TextStyle(
                                  color: Color(0xFFBC8157),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Text(
                                'Tekrar Gönder (${_resendTimer} sn)',
                                style: TextStyle(
                                  color: Color(0xFFBC8157).withOpacity(0.5),
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
            
            // Verify Button
            Positioned(
              left: screenWidth * 0.061,
              top: screenHeight * 0.50,
              child: GestureDetector(
                onTap: _isLoading ? null : _verifyCode,
                child: Container(
                  width: screenWidth * 0.878,
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
                            'DOĞRULA',
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
            ),
          ],
        ),
      ),
    );
  }
} 