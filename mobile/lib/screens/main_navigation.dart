import 'package:flutter/material.dart';
import 'dart:ui';
import 'home/home_page.dart';
import 'menu/menu_page.dart';
import 'branches/branches.dart';
import 'profile/profile_page.dart';
import '../screens/qr_scanner_page.dart';

// NavigationController ile dışarıdan tab değiştirme desteği
class NavigationController {
  static void Function(int)? _switchTab;
  static void setSwitchTabFunction(Function(int)? switchTab) {
    _switchTab = switchTab;
  }
  static void switchToTab(int index) {
    _switchTab?.call(index);
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MenuPage(),
    LocationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    NavigationController.setSwitchTabFunction(_onNavItemSelected);
  }

  @override
  void dispose() {
    NavigationController.setSwitchTabFunction(null);
    super.dispose();
  }

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onQRCodePressed() {
    // QR butonuna basınca kamera açılıp pos cihazındaki kod okutulacak (QRScannerPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF8E9E0),
      body: Stack(
        children: [
          // Aktif sayfa
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _pages[_selectedIndex],
            ),
          ),
          // Menubar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 86 + 36, // bar yüksekliği + yarım QR buton yüksekliği
                width: width,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Yüzen bar (floating, glassmorphic, büyük radius ve gölge)
                    Positioned(
                      bottom: 0,
                      left: 24,
                      right: 24,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            height: 86,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF7B4B2A).withOpacity(0.10),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                              border: Border.all(
                                color: Color(0xFFD7A86E).withOpacity(0.18),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _MenuBarItem(
                                  iconPath: 'assets/icons/bottommenu/home.png',
                                  label: 'Ana Sayfa',
                                  selected: _selectedIndex == 0,
                                  color: const Color(0xFF7B4B2A),
                                  onTap: () => _onNavItemSelected(0),
                                ),
                                _MenuBarItem(
                                  iconPath: 'assets/icons/bottommenu/menu.png',
                                  label: 'Menü',
                                  selected: _selectedIndex == 1,
                                  color: const Color(0xFF7B4B2A),
                                  onTap: () => _onNavItemSelected(1),
                                ),
                                const SizedBox(width: 56), // Ortadaki buton için boşluk
                                _MenuBarItem(
                                  iconPath: 'assets/icons/bottommenu/marker.png',
                                  label: 'Şubeler',
                                  selected: _selectedIndex == 2,
                                  color: const Color(0xFF7B4B2A),
                                  onTap: () => _onNavItemSelected(2),
                                ),
                                _MenuBarItem(
                                  iconPath: 'assets/icons/bottommenu/user.png',
                                  label: 'Profil',
                                  selected: _selectedIndex == 3,
                                  color: const Color(0xFF7B4B2A),
                                  onTap: () => _onNavItemSelected(3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Ortadaki öne çıkan QR butonu (barın üstünde, büyük, yüzen)
                    Positioned(
                      bottom: 43,
                      left: width / 2 - 30,
                      child: GestureDetector(
                        onTap: _onQRCodePressed,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B4B2A).withOpacity(0.18),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuBarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _MenuBarItem({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              width: selected ? 28 : 18,
              height: selected ? 28 : 18,
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.16) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconPath,
                width: selected ? 20 : 16,
                height: selected ? 20 : 16,
                color: selected ? color : color.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              style: TextStyle(
                color: selected ? color : color.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
} 