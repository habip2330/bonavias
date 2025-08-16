import 'package:flutter/material.dart';

class BalanceHistoryPage extends StatefulWidget {
  const BalanceHistoryPage({Key? key}) : super(key: key);

  @override
  State<BalanceHistoryPage> createState() => _BalanceHistoryPageState();
}

class _BalanceHistoryPageState extends State<BalanceHistoryPage> {
  // Örnek bakiye yükleme geçmişi verileri
  List<BalanceHistoryItem> balanceHistory = [
    BalanceHistoryItem(
      amount: 100.90,
      date: '23 MART 2025',
      status: BalanceStatus.completed,
    ),
    BalanceHistoryItem(
      amount: 50.00,
      date: '20 MART 2025',
      status: BalanceStatus.completed,
    ),
    BalanceHistoryItem(
      amount: 25.00,
      date: '18 MART 2025',
      status: BalanceStatus.pending,
    ),
    BalanceHistoryItem(
      amount: 75.50,
      date: '15 MART 2025',
      status: BalanceStatus.completed,
    ),
    BalanceHistoryItem(
      amount: 200.00,
      date: '12 MART 2025',
      status: BalanceStatus.failed,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  // Back Button
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
                  
                  const SizedBox(width: 16),
                  
                  // Title
                  const Text(
                    'Bakiye Yükleme Geçmişi',
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
            
            const SizedBox(height: 20),
            
            // Balance History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: balanceHistory.length,
                itemBuilder: (context, index) {
                  final item = balanceHistory[index];
                  final isFirst = index == 0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status (only for first item or when status changes)
                      if (isFirst || 
                          (index > 0 && balanceHistory[index - 1].status != item.status)) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                      
                      // Divider (except for first item)
                      if (!isFirst && 
                          !(index > 0 && balanceHistory[index - 1].status != item.status)) ...[
                        Container(
                          width: double.infinity,
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xFFEDF1F5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Balance History Item
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction Title
                          const Text(
                            'Bakiye Yükleme',
                            style: TextStyle(
                              color: Color(0xFF181C2E),
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Amount and Date Row
                          Row(
                            children: [
                              // Amount
                              Text(
                                '${item.amount.toStringAsFixed(2)}₺',
                                style: const TextStyle(
                                  color: Color(0xFF181C2E),
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
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 1,
                                      color: Color(0xFFCACCD9),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 14),
                              
                              // Date
                              Text(
                                item.date,
                                style: const TextStyle(
                                  color: Color(0xFF6B6E81),
                                  fontSize: 12,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  String _getStatusText(BalanceStatus status) {
    switch (status) {
      case BalanceStatus.completed:
        return 'Tamamlandı';
      case BalanceStatus.pending:
        return 'Beklemede';
      case BalanceStatus.failed:
        return 'Başarısız';
    }
  }

  Color _getStatusColor(BalanceStatus status) {
    switch (status) {
      case BalanceStatus.completed:
        return const Color(0xFF059C69);
      case BalanceStatus.pending:
        return const Color(0xFFFF9500);
      case BalanceStatus.failed:
        return const Color(0xFFE74C3C);
    }
  }
}

// Balance History Item Model
class BalanceHistoryItem {
  final double amount;
  final String date;
  final BalanceStatus status;

  BalanceHistoryItem({
    required this.amount,
    required this.date,
    required this.status,
  });
}

// Balance Status Enum
enum BalanceStatus {
  completed,
  pending,
  failed,
} 