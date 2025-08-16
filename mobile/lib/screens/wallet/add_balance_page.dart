import 'package:flutter/material.dart';
import 'add_new_card_page.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({Key? key}) : super(key: key);

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  double currentBalance = 100.90;
  String selectedAmount = '100';
  int selectedCardIndex = 1; // İkinci kart seçili
  
  List<Map<String, String>> savedCards = [
    {'type': 'Master Card', 'number': '5678 **** **** 1345'},
    {'type': 'Master Card', 'number': '5678 **** **** 1345'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  // Back Button
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
                        size: 20,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 18),
                  
                  // Title
                  const Text(
                    'Bakiye Ekle',
                    style: TextStyle(
                      color: Color(0xFF181C2E),
                      fontSize: 17,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Current Balance Card
                    Container(
                      width: double.infinity,
                      height: 129,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC8157),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Kullanılabilir Bakiyeniz',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentBalance.toStringAsFixed(2)}₺',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 54),
                    
                    // Amount to Load Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'YÜKLENECEK TUTAR :',
                          style: TextStyle(
                            color: Color(0xFFA0A5BA),
                            fontSize: 14,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Opacity(
                          opacity: 0.50,
                          child: Text(
                            selectedAmount,
                            style: const TextStyle(
                              color: Color(0xFF31343D),
                              fontSize: 16,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 70),
                    
                    // Saved Cards Section
                    Column(
                      children: [
                        // First Card
                        _buildCardItem(
                          cardType: savedCards[0]['type']!,
                          cardNumber: savedCards[0]['number']!,
                          cvv: '436',
                          isSelected: selectedCardIndex == 0,
                          onTap: () {
                            setState(() {
                              selectedCardIndex = 0;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 34),
                        
                        // Divider line
                        Container(
                          height: 1,
                          color: Colors.black.withOpacity(0.1),
                        ),
                        
                        const SizedBox(height: 34),
                        
                        // Second Card
                        _buildCardItem(
                          cardType: savedCards[1]['type']!,
                          cardNumber: savedCards[1]['number']!,
                          cvv: '345',
                          isSelected: selectedCardIndex == 1,
                          onTap: () {
                            setState(() {
                              selectedCardIndex = 1;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 84),
                    
                    // Add New Card Button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Yeni kart ekleme fonksiyonu
                          _showAddNewCardDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFBC8157),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: Color(0xFFBC8157),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'YENİ KART EKLE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFBC8157),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 122),
                  ],
                ),
              ),
            ),
            
            // Payment Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: GestureDetector(
                onTap: () {
                  _processPayment();
                },
                child: Container(
                  width: double.infinity,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC8157),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'ÖDEMEYİ GERÇEKLEŞTİR',
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

  Widget _buildCardItem({
    required String cardType,
    required String cardNumber,
    required String cvv,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Card Icon
          Container(
            width: 28,
            height: 17.65,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(3.60),
            ),
          ),
          
          const SizedBox(width: 7),
          
          // Card Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardType,
                  style: const TextStyle(
                    color: Color(0xFF31343D),
                    fontSize: 16,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Opacity(
                      opacity: 0.50,
                      child: Text(
                        cardNumber,
                        style: const TextStyle(
                          color: Color(0xFF31343D),
                          fontSize: 16,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      cvv,
                      style: const TextStyle(
                        color: Color(0xFF31343D),
                        fontSize: 16,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Selection Indicator
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6EC056) : Colors.white,
              shape: BoxShape.circle,
              border: isSelected 
                ? null 
                : Border.all(
                    width: 1,
                    color: const Color(0xFF8B8B8B),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNewCardDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewCardPage(),
      ),
    );
  }

  void _processPayment() {
    // Ödeme işlemi simülasyonu
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ödeme Başarılı',
            style: TextStyle(
              fontFamily: 'Sen',
              fontWeight: FontWeight.w600,
              color: Color(0xFF6EC056),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6EC056),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '$selectedAmount₺ bakiye başarıyla eklendi!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context, double.parse(selectedAmount)); // Ana sayfaya dön ve tutarı gönder
              },
              child: const Text(
                'Tamam',
                style: TextStyle(
                  color: Color(0xFFBC8157),
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
