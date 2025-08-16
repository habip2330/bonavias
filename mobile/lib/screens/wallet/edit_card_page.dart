import 'package:flutter/material.dart';
import '../../widgets/modern_ui_components.dart';
import '../../services/card_service.dart';
import '../../models/saved_card.dart';

class EditCardPage extends StatefulWidget {
  final dynamic card;
  const EditCardPage({Key? key, required this.card}) : super(key: key);

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final CardService _cardService = CardService();
  late TextEditingController _holderController;
  late TextEditingController _expiryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _holderController = TextEditingController(text: widget.card.holderName);
    _expiryController = TextEditingController(text: widget.card.expiryDate);
  }

  @override
  void dispose() {
    _holderController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Güncellenmiş kart oluştur
        final updatedCard = SavedCard(
          id: widget.card.id,
          cardType: widget.card.cardType,
          maskedNumber: widget.card.maskedNumber,
          lastFourDigits: widget.card.lastFourDigits,
          expiryDate: _expiryController.text,
          holderName: _holderController.text.toUpperCase(),
          userId: widget.card.userId,
          createdAt: widget.card.createdAt,
        );

        // Firebase'e kaydet
        await _cardService.updateCard(updatedCard);

        setState(() {
          _isLoading = false;
        });

        ModernUIComponents.showModernSnackBar(
          context, 
          'Kart başarıyla güncellendi!', 
          isSuccess: true
        );
        Navigator.pop(context, updatedCard);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ModernUIComponents.showModernSnackBar(
          context, 
          'Kart güncellenirken hata oluştu: ${e.toString()}', 
          isSuccess: false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Kartı Düzenle'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _holderController,
                    decoration: const InputDecoration(labelText: 'Kart Sahibi'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 24),
                  // Kart numarası gösterimi (salt okunur)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kart Numarası',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.card.maskedNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(labelText: 'Son Kullanma (AA/YY)'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
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
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                        : Theme.of(context).colorScheme.primary,
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
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
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