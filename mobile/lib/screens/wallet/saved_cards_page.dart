import 'package:flutter/material.dart';
import '../../widgets/modern_ui_components.dart';
import '../../services/card_service.dart';
import '../../models/saved_card.dart';
import 'add_new_card_page.dart';
import 'edit_card_page.dart';
import 'package:flutter/services.dart';

class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({Key? key}) : super(key: key);

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  final CardService _cardService = CardService();
  List<SavedCard> savedCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final cards = await _cardService.getUserCards();
      setState(() {
        savedCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ModernUIComponents.showModernSnackBar(
          context, 
          'Kartlar yüklenirken hata oluştu: ${e.toString()}', 
          isSuccess: false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                  colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'Kayıtlı Kartlarım',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sen',
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    
                    // Loading State
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (savedCards.isEmpty)
                      // Empty State
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100),
                            Icon(
                              Icons.credit_card_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kayıtlı kartınız yok',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                fontFamily: 'Sen',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'İlk kartınızı ekleyerek başlayın',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontFamily: 'Sen',
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Saved Cards List
                      Column(
                        children: [
                          ...savedCards.asMap().entries.map((entry) {
                            int index = entry.key;
                            SavedCard card = entry.value;
                            return Column(
                              children: [
                                _buildCardItem(card, index),
                                if (index < savedCards.length - 1) ...[
                                  const SizedBox(height: 24),
                                ],
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 48),
                        ],
                      ),
                    
                    // Add New Card Button
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Sen'),
                          elevation: 2,
                        ),
                        onPressed: _showAddNewCardDialog,
                        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 20),
                        label: Text('YENİ KART EKLE', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(SavedCard card, int index) {
    return GestureDetector(
      onTap: () => _showCardDetailsDialog(card),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Type
            Text(
              card.cardType,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontFamily: 'Sen',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            // Card Details Row
            Row(
              children: [
                // Card Icon
                Container(
                  width: 28,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      card.cardType.toLowerCase().contains('master') 
                          ? Icons.credit_card 
                          : Icons.payment,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Masked Card Number
                Expanded(
                  child: Text(
                    card.maskedNumber,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Edit Button
                GestureDetector(
                  onTap: () async {
                    final updatedCard = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCardPage(card: card),
                      ),
                    );
                    if (updatedCard != null) {
                      setState(() {
                        savedCards[index] = updatedCard;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                GestureDetector(
                  onTap: () => _confirmDeleteCard(card, index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetailsDialog(SavedCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Kart Detayları',
            style: TextStyle(
              fontFamily: 'Sen',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Kart Türü:', card.cardType),
              _buildDetailRow('Kart Numarası:', card.maskedNumber),
              _buildDetailRow('Son Kullanma:', card.expiryDate),
              _buildDetailRow('Kart Sahibi:', card.holderName),
              _buildDetailRow('Son 4 Hane:', card.lastFourDigits),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kapat',
                style: TextStyle(
                  color: Color(0xFFBC8157),
                  fontFamily: 'Sen',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCardDialog(SavedCard card, int index) {
    final _formKey = GlobalKey<FormState>();
    final holderController = TextEditingController(text: card.holderName);
    final numberController = TextEditingController(text: card.maskedNumber);
    final expiryController = TextEditingController(text: card.expiryDate);
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Kartı Düzenle',
            style: TextStyle(
              fontFamily: 'Sen',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: holderController,
                    decoration: const InputDecoration(labelText: 'Kart Sahibi'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: numberController,
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
                      labelText: 'Kart Numarası',
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Zorunlu alan';
                      String cleanValue = v.replaceAll(' ', '');
                      if (cleanValue.length != 16) return 'Kart numarası 16 haneli olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateFormatter(),
                    ],
                    style: const TextStyle(
                      color: Color(0xFF31343D),
                      fontSize: 16,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Son Kullanma (AA/YY)',
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Zorunlu alan';
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}').hasMatch(v)) return 'mm/yy formatında giriniz';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cvvController,
                    decoration: const InputDecoration(labelText: 'CVV'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    savedCards[index] = SavedCard(
                      id: card.id,
                      cardType: card.cardType,
                      maskedNumber: numberController.text,
                      lastFourDigits: numberController.text.substring(numberController.text.length - 4),
                      expiryDate: expiryController.text,
                      holderName: holderController.text,
                      userId: card.userId,
                      createdAt: card.createdAt,
                    );
                  });
                  Navigator.pop(context);
                  ModernUIComponents.showModernSnackBar(context, 'Kart başarıyla güncellendi!', isSuccess: true);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCard(SavedCard card, int index) {
    ModernUIComponents.showModernDeleteDialog(
      context,
      'Kartı Sil',
      'Kayıtlı kartı silmek istediğinize emin misiniz?',
      () async {
        try {
          await _cardService.deleteCard(card.id);
          setState(() {
            savedCards.removeAt(index);
          });
          ModernUIComponents.showModernSnackBar(context, 'Kart başarıyla silindi!', isSuccess: true);
        } catch (e) {
          ModernUIComponents.showModernSnackBar(
            context, 
            'Kart silinirken hata oluştu: ${e.toString()}', 
            isSuccess: false
          );
        }
      },
    );
  }

  void _showAddNewCardDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewCardPage(),
      ),
    ).then((_) {
      // Kart eklendikten sonra listeyi yenile
      _loadCards();
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Sen',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Sen',
                fontSize: 14,
              ),
            ),
          ),
        ],
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

 