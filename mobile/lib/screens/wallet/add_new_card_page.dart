import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/modern_ui_components.dart';
import '../../services/card_service.dart';
import '../../models/saved_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({Key? key}) : super(key: key);

  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final CardService _cardService = CardService();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'\D'), '');
    
    // Add spaces every 4 digits
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String _formatExpiryDate(String value) {
    // Remove all non-digits
    value = value.replaceAll(RegExp(r'\D'), '');
    
    // Add slash after 2 digits (mm/yyyy)
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Kullanıcı girişi yapılmamış');
        }

        // Kart numarasını temizle
        String cleanCardNumber = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
        String lastFourDigits = cleanCardNumber.substring(cleanCardNumber.length - 4);
        
        // Yeni kart oluştur
        SavedCard newCard = SavedCard(
          id: '', // Firestore tarafından otomatik oluşturulacak
          cardType: _cardService.getCardType(cleanCardNumber),
          maskedNumber: _cardService.maskCardNumber(cleanCardNumber),
          lastFourDigits: lastFourDigits,
          expiryDate: _expiryDateController.text,
          holderName: _cardHolderController.text.toUpperCase(),
          userId: user.uid,
          createdAt: DateTime.now(),
        );

        // Firebase'e kaydet
        await _cardService.addCard(newCard);

        setState(() {
          _isLoading = false;
        });

        ModernUIComponents.showModernSnackBar(
          context, 
          'Kart başarıyla kaydedildi!', 
          isSuccess: true
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ModernUIComponents.showModernSnackBar(
          context, 
          'Kart kaydedilirken hata oluştu: ${e.toString()}', 
          isSuccess: false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Main Content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 37),
                      
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: const BoxDecoration(
                                color: Color(0xFFECF0F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF181C2E),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Text(
                            'Geri',
                            style: TextStyle(
                              color: Color(0xFF181C2E),
                              fontSize: 17,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 136),
                      
                      // Card Holder Name
                      const Text(
                        'KART ÜZERİNDEKİ İSİM',
                        style: TextStyle(
                          color: Color(0xFFA0A5BA),
                          fontSize: 14,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cardHolderController,
                        style: const TextStyle(
                          color: Color(0xFF31343D),
                          fontSize: 16,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Örnek İsim',
                          hintStyle: TextStyle(
                            color: const Color(0xFF31343D).withOpacity(0.3),
                            fontSize: 16,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF454750)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF454750)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFBC8157)),
                          ),
                          contentPadding: const EdgeInsets.only(left: 20, bottom: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kart sahibinin adını giriniz';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Card Number
                      const Text(
                        'KART NUMARASI',
                        style: TextStyle(
                          color: Color(0xFFA0A5BA),
                          fontSize: 14,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        style: const TextStyle(
                          color: Color(0xFF31343D),
                          fontSize: 16,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: '2134 _ _ _ _   _ _ _ _',
                          hintStyle: TextStyle(
                            color: const Color(0xFF31343D).withOpacity(0.3),
                            fontSize: 16,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF454750)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF454750)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFBC8157)),
                          ),
                          contentPadding: const EdgeInsets.only(left: 20, bottom: 8),
                        ),
                        onChanged: (value) {
                          String formatted = _formatCardNumber(value);
                          if (formatted != value) {
                            _cardNumberController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kart numarasını giriniz';
                          }
                          String cleanValue = value.replaceAll(' ', '');
                          if (cleanValue.length != 16) {
                            return 'Kart numarası 16 haneli olmalıdır';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Expiry Date and CVC
                      Row(
                        children: [
                          // Expiry Date
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SON KUL. TARİHİ',
                                  style: TextStyle(
                                    color: Color(0xFFA0A5BA),
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _expiryDateController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4), // mmYY
                                    _ExpiryDateFormatter(), // özel formatter
                                  ],
                                  style: const TextStyle(
                                    color: Color(0xFF31343D),
                                    fontSize: 16,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'mm/yy',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF31343D).withOpacity(0.3),
                                      fontSize: 16,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF454750)),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF454750)),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFBC8157)),
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 20, bottom: 8),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Son kullanma tarihini giriniz';
                                    }
                                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}').hasMatch(value)) {
                                      return 'mm/yy formatında giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 40),
                          
                          // CVC
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CVC',
                                  style: TextStyle(
                                    color: Color(0xFFA0A5BA),
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _cvcController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  obscureText: true,
                                  style: const TextStyle(
                                    color: Color(0xFF31343D),
                                    fontSize: 16,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '***',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF31343D).withOpacity(0.3),
                                      fontSize: 16,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF454750)),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF454750)),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFBC8157)),
                                    ),
                                    contentPadding: const EdgeInsets.only(left: 20, bottom: 8),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'CVC giriniz';
                                    }
                                    if (value.length != 3) {
                                      return '3 haneli olmalı';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
              
              // Save Button (Fixed at bottom)
              Positioned(
                left: 24,
                right: 24,
                bottom: 34,
                child: GestureDetector(
                  onTap: _isLoading ? null : _saveCard,
                  child: Container(
                    width: double.infinity,
                    height: 62,
                    decoration: BoxDecoration(
                      color: _isLoading 
                          ? const Color(0xFFBC8157).withOpacity(0.6)
                          : const Color(0xFFBC8157),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'KAYDET',
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
      ),
    );
  }
} 

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 2) {
      text = text.substring(0, 2) + '/' + text.substring(2, text.length > 4 ? 4 : text.length);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
} 