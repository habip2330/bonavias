import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  final void Function(String)? onScanned;

  const QRScannerPage({Key? key, this.onScanned}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text('QR Kod Tara', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 320,
            height: 320,
            color: theme.cardColor,
            child: MobileScanner(
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    Navigator.of(context).pop();
                    if (onScanned != null) onScanned!(code);
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
} 