import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
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
              left: screenWidth * 0.20,
              top: screenHeight * 0.15,
              child: const Text(
                'Şifremi Unuttum',
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
              left: screenWidth * 0.15,
              top: screenHeight * 0.19,
              child: const Opacity(
                opacity: 0.85,
                child: Text(
                  'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim',
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
                      
                      const SizedBox(height: 30),
                      
                      // Send Button
                      GestureDetector(
                        onTap: _isLoading ? null : _sendResetEmail,
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
                                    'GÖNDER',
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
                      
                      // Back to login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Giriş sayfasına dönmek için ',
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
                              'tıklayın',
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