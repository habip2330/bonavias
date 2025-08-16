import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:postgres/postgres.dart';
import '../../config/theme.dart';

class RateBranchPage extends StatefulWidget {
  final String branchId;
  final String branchName;

  const RateBranchPage({
    Key? key,
    required this.branchId,
    required this.branchName,
  }) : super(key: key);

  @override
  State<RateBranchPage> createState() => _RateBranchPageState();
}

class _RateBranchPageState extends State<RateBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    try {
      // Gmail SMTP ayarları
      final smtpServer = gmail('habipbahceci24@gmail.com', 'awzy jejt dfwq jtbb');

      // E-posta içeriği
      final message = Message()
        ..from = Address('habipbahceci24@gmail.com', 'Bonavias Değerlendirme')
        ..recipients.add('habipbahceci30@gmail.com')
        ..subject = 'Şube Değerlendirmesi - ${widget.branchName}'
        ..text = '''
Şube Değerlendirmesi

Şube: ${widget.branchName}
Değerlendiren: ${_nameController.text}
Telefon: ${_phoneController.text}
E-posta: ${_emailController.text}
Puan: $_rating
Yorum: ${_commentController.text}
Tarih: ${DateTime.now().toString()}
''';

      final sendReport = await send(message, smtpServer);
      print('E-posta gönderildi: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('E-posta gönderilirken hata: ${e.message}');
      if (e.message.contains('535')) {
        throw 'Gmail kimlik doğrulama hatası. Lütfen 2 Adımlı Doğrulama ve Uygulama Şifresi ayarlarını kontrol edin.';
      }
      throw 'E-posta gönderilirken bir hata oluştu: ${e.message}';
    } catch (e) {
      print('Beklenmeyen hata: $e');
      throw 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      setState(() {
        _errorMessage = 'Lütfen bir puan verin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // PostgreSQL bağlantısı
      final connection = PostgreSQLConnection(
        "localhost", // PostgreSQL sunucu adresi
        5432, // PostgreSQL port
        "bonavias_db", // Veritabanı adı
        username: "postgres", // PostgreSQL kullanıcı adı
        password: "your_password", // PostgreSQL şifresi
      );
      await connection.open();

      // Değerlendirmeyi veritabanına kaydet
      await connection.execute(
        '''
        INSERT INTO branch_ratings (
          branch_id, branch_name, name, phone, email, rating, comment, date
        ) VALUES (
          @branchId, @branchName, @name, @phone, @email, @rating, @comment, @date
        )
        ''',
        substitutionValues: {
          'branchId': widget.branchId,
          'branchName': widget.branchName,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'rating': _rating,
          'comment': _commentController.text,
          'date': DateTime.now(),
        },
      );

      await connection.close();

      // E-posta gönder
      await _sendEmail();

      if (mounted) {
        // Modern bildirim göster
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Teşekkürler!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Değerlendirmeniz başarıyla kaydedildi ve e-posta gönderildi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog'u kapat
                        Navigator.pop(context); // Form sayfasını kapat
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tamam',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
      });
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.branchName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Şube bilgisi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.branchName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Form alanları
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Adınız Soyadınız',
                    labelStyle: GoogleFonts.poppins(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı ve soyadınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numaranız',
                    labelStyle: GoogleFonts.poppins(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen telefon numaranızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta Adresiniz',
                    labelStyle: GoogleFonts.poppins(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Puanlama
                Text(
                  'Puanınız',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Yorum
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Yorumunuz',
                    labelStyle: GoogleFonts.poppins(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir yorum yazın';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Gönder butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Değerlendirmeyi Gönder',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 