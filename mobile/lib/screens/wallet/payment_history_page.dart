import 'package:flutter/material.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  // Örnek ödeme geçmişi verileri
  List<PaymentHistoryItem> paymentHistory = [
    PaymentHistoryItem(
      id: '#242432',
      productName: 'İce Americano',
      category: 'Soğuk Kahveler',
      price: 100.90,
      date: '23 MART 2025',
      quantity: 1,
      status: PaymentStatus.completed,
      imageColor: const Color(0xFF98A8B8),
    ),
    PaymentHistoryItem(
      id: '#242433',
      productName: 'Cappuccino',
      category: 'Sıcak Kahveler',
      price: 85.50,
      date: '22 MART 2025',
      quantity: 2,
      status: PaymentStatus.completed,
      imageColor: const Color(0xFFBC8157),
    ),
    PaymentHistoryItem(
      id: '#242434',
      productName: 'Latte',
      category: 'Sıcak Kahveler',
      price: 95.00,
      date: '21 MART 2025',
      quantity: 1,
      status: PaymentStatus.pending,
      imageColor: const Color(0xFF6C5CE7),
    ),
    PaymentHistoryItem(
      id: '#242435',
      productName: 'Espresso',
      category: 'Sıcak Kahveler',
      price: 65.00,
      date: '20 MART 2025',
      quantity: 3,
      status: PaymentStatus.completed,
      imageColor: const Color(0xFF4ECDC4),
    ),
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
                    'Ödeme Geçmişi',
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
            const SizedBox(height: 20),
            
            // Payment History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: paymentHistory.length,
                itemBuilder: (context, index) {
                  final item = paymentHistory[index];
                  final isFirst = index == 0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header (only for first item)
                      if (isFirst) ...[
                        Text(
                          item.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 15,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getStatusText(item.status),
                              style: TextStyle(
                                color: _getStatusColor(item.status),
                                fontSize: 14,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                      
                      // Divider
                      if (!isFirst) ...[
                        Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Payment Item
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Product Image Placeholder
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.coffee,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                            ),
                            
                            const SizedBox(width: 14),
                            
                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name and Order ID Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground,
                                          fontSize: 14,
                                          fontFamily: 'Sen',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _showOrderDetails(item);
                                        },
                                        child: Text(
                                          item.id,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontSize: 14,
                                            fontFamily: 'Sen',
                                            fontWeight: FontWeight.w400,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 10),
                                  
                                  // Price, Date and Quantity Row
                                  Row(
                                    children: [
                                      // Price
                                      Text(
                                        '${item.price.toStringAsFixed(2)}₺',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground,
                                          fontSize: 14,
                                          fontFamily: 'Sen',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 14),
                                      
                                      // Vertical Divider
                                      Container(
                                        width: 1,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              width: 1,
                                              color: Theme.of(context).dividerColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 14),
                                      
                                      // Date and Quantity
                                      Row(
                                        children: [
                                          Text(
                                            item.date,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontSize: 12,
                                              fontFamily: 'Sen',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.quantity} Adet',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontSize: 12,
                                              fontFamily: 'Sen',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return const Color(0xFF059C69);
      case PaymentStatus.pending:
        return const Color(0xFFFF9500);
      case PaymentStatus.cancelled:
        return const Color(0xFFE74C3C);
    }
  }

  void _showOrderDetails(PaymentHistoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sipariş Detayları',
            style: const TextStyle(
              fontFamily: 'Sen',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Sipariş No:', item.id),
              _buildDetailRow('Ürün:', item.productName),
              _buildDetailRow('Kategori:', item.category),
              _buildDetailRow('Fiyat:', '${item.price.toStringAsFixed(2)}₺'),
              _buildDetailRow('Adet:', '${item.quantity}'),
              _buildDetailRow('Tarih:', item.date),
              _buildDetailRow('Durum:', _getStatusText(item.status)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

// Payment History Item Model
class PaymentHistoryItem {
  final String id;
  final String productName;
  final String category;
  final double price;
  final String date;
  final int quantity;
  final PaymentStatus status;
  final Color imageColor;

  PaymentHistoryItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.price,
    required this.date,
    required this.quantity,
    required this.status,
    required this.imageColor,
  });
}

// Payment Status Enum
enum PaymentStatus {
  completed,
  pending,
  cancelled,
} 