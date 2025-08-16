import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'home/home_page.dart';
import 'menu/menu_screen.dart';
import 'branches/branches.dart';
import 'profile/profile_page.dart';
import '../widgets/modern_ui_components.dart';
import '../config/theme.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late int _selectedIndex;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      setState(() {
        _userId = userId;
        _isLoading = false;
      });
    } catch (e) {
      print('Kullanıcı verisi yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    final List<Widget> pages = [
      const HomePage(),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          return MenuScreen(categories: snapshot.data ?? []);
        },
      ),
      const LocationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Soft arka plan
      body: pages[_selectedIndex],
      bottomNavigationBar: ModernBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onCenterButtonTap: () {
          // AR Kod veya ana aksiyon burada!
          // Navigator.push(...);
        },
      ),
    );
  }
} 