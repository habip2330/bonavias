import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String title;
  final String name;
  final String address;
  final String phone;
  final String city;
  final String district;
  final String postalCode;
  bool isDefault;

  Address({
    required this.title,
    required this.name,
    required this.address,
    required this.phone,
    required this.city,
    required this.district,
    required this.postalCode,
    this.isDefault = false,
  });
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .orderBy('createdAt', descending: true)
            .get();

        setState(() {
          _addresses = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _addresses = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Adresler yüklenirken hata: $e');
      setState(() {
        _addresses = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .doc(addressId)
            .delete();
        
        _showModernSnackBar(context, 'Adres başarıyla silindi', isSuccess: true);
        
        // Refresh the addresses list
        _loadAddresses();
      }
    } catch (e) {
      _showModernSnackBar(context, 'Adres silinirken hata oluştu: $e', isError: true);
    }
  }

  void _showModernSnackBar(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    IconData icon;
    Color backgroundColor;
    
    if (isError) {
      icon = Icons.error_outline;
      backgroundColor = const Color(0xFFE74C3C);
    } else if (isSuccess) {
      icon = Icons.check_circle_outline;
      backgroundColor = const Color(0xFFBC8157);
    } else {
      icon = Icons.info_outline;
      backgroundColor = const Color(0xFF6C757D);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
        elevation: 4,
      ),
    );
  }

  void _showModernDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE74C3C),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF32343E),
                    fontSize: 18,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF8F9FA),
                          foregroundColor: const Color(0xFF6C757D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sil',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getAddressIcon(String title) {
    switch (title.toUpperCase()) {
      case 'EV':
        return const Icon(
          Icons.home,
          color: Color(0xFF32A8F5),
          size: 24,
        );
      case 'İŞ':
        return const Icon(
          Icons.work,
          color: Color(0xFF9C27B0),
          size: 24,
        );
      default:
        return const Icon(
          Icons.location_on,
          color: Color(0xFF32343E),
          size: 24,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFBC8157)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: 395,
            height: 812,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                // Back Button
                Positioned(
                  left: 24,
                  top: 50,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFECF0F4),
                        shape: OvalBorder(),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF32343E),
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Title
                const Positioned(
                  left: 85,
                  top: 62,
                  child: Text(
                    'Adreslerim',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 17,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                    ),
                  ),
                ),

                // Address Cards (Dynamic based on _addresses list)
                ...List.generate(_addresses.length, (index) {
                  final address = _addresses[index];
                  final topPosition = 119 + (index * 121.0); // 101 height + 20 spacing
                  
                  return [
                    // Address Container Background
                    Positioned(
                      left: 24,
                      top: topPosition,
                      child: Container(
                        width: 357,
                        height: 101,
                        decoration: ShapeDecoration(
                          color: const Color(0x4CF1F1F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    // Address Title
                    Positioned(
                      left: 101,
                      top: topPosition + 16,
                      child: Text(
                        (address['title'] ?? '').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF32343E),
                          fontSize: 14,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // Address Details
                    Positioned(
                      left: 101,
                      top: topPosition + 42,
                      child: SizedBox(
                        width: 180,
                        child: Opacity(
                          opacity: 0.50,
                          child: Text(
                            '${address['address'] ?? ''}, ${address['neighborhood'] ?? ''}',
                            style: const TextStyle(
                              color: Color(0xFF31343D),
                              fontSize: 14,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    // Address Icon Circle
                    Positioned(
                      left: 39,
                      top: topPosition + 16,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: OvalBorder(),
                        ),
                        child: Center(
                          child: _getAddressIcon(address['title'] ?? ''),
                        ),
                      ),
                    ),

                    // Edit Button
                    Positioned(
                      right: 70,
                      top: topPosition + 16,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAddressScreen(address: address),
                            ),
                          );
                          
                          if (result == true) {
                            _loadAddresses();
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBC8157).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFFBC8157),
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Delete Button
                    Positioned(
                      right: 24,
                      top: topPosition + 16,
                      child: GestureDetector(
                        onTap: () {
                          _showModernDialog(
                            context,
                            'Adresi Sil',
                            'Bu adresi silmek istediğinizden emin misiniz?',
                            () => _deleteAddress(address['id']),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBC8157).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFBC8157),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ];
                }).expand((element) => element).toList(),

                // Empty State (when no addresses)
                if (_addresses.isEmpty) ...[
                  const Positioned(
                    left: 100,
                    top: 300,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 80,
                      color: Color(0xFF98A8B8),
                    ),
                  ),
                  const Positioned(
                    left: 50,
                    top: 400,
                    right: 50,
                    child: Column(
                      children: [
                        Text(
                          'Henüz Kayıtlı Adresiniz Yok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF32343E),
                            fontSize: 20,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Sipariş verebilmek için lütfen bir adres ekleyiniz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF98A8B8),
                            fontSize: 14,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Add Address Button
                Positioned(
                  left: 24,
                  top: 720,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressScreen(),
                        ),
                      );
                      
                      if (result == true) {
                        _loadAddresses();
                      }
                    },
                    child: Container(
                      width: 327,
                      height: 62,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFBC8157),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                // Add Address Button Text
                Positioned(
                  left: 124,
                  top: 742,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressScreen(),
                        ),
                      );
                      
                      if (result == true) {
                        _loadAddresses();
                      }
                    },
                    child: const Text(
                      'YENİ ADRES EKLE',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
