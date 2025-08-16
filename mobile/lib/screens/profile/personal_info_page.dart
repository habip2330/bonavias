import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_service.dart';
import 'edit_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _userName = '';
  String _userFullName = '';
  String _profileImageUrl = '';
  String _loginMethod = '';
  String _userEmail = '';
  String _userBirthDate = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      final userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data() ?? {};
      setState(() {
        _userName = user.displayName ?? '';
        _userEmail = user.email ?? '';
        _profileImageUrl = user.photoURL ?? data['profile_image'] ?? '';
        _userBirthDate = data['birthdate'] ?? '';
        _userPhone = data['phone'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFBC8157)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header Section
                Row(
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
                    
                    const SizedBox(width: 20),
                    
                    // Title
                    Text(
                      'Kişisel Bilgiler',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sen',
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Edit Button
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                        setState(() {
                          _isLoading = true;
                        });
                        await _loadUserData();
                      },
                      child: Text(
                        'DÜZENLE',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                
                
                // Profile Section
                // Row(
                //   children: [
                //     // Profile Image
                //     Container(
                //       width: 80,
                //       height: 80,
                //       decoration: BoxDecoration(
                //         color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                //         shape: BoxShape.circle,
                //       ),
                //       child: _buildProfileImage(),
                //     ),
                //     const SizedBox(width: 20),
                //     // Profile Info
                //     Expanded(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             _getDisplayName(),
                //             style: TextStyle(
                //               color: Theme.of(context).colorScheme.onBackground,
                //               fontSize: 20,
                //               fontWeight: FontWeight.bold,
                //               fontFamily: 'Sen',
                //             ),
                //           ),
                //           const SizedBox(height: 8),
                //           Text(
                //             'Bona Seni Seviyor',
                //             style: TextStyle(
                //               color: Theme.of(context).textTheme.bodyMedium?.color,
                //               fontSize: 14,
                //               fontFamily: 'Sen',
                //               fontWeight: FontWeight.w400,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                
                const SizedBox(height: 40),
                
                // Missing Info Warning
                if (_isMissingInfo())
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF9800),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lütfen eksik bilgilerinizi tamamlayın: ${_getMissingFields()}',
                            style: const TextStyle(
                              color: Color(0xFFBC8157),
                              fontSize: 13,
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Info Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0x4CF1F1F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // İsim & Soyisim
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFFBC8157),
                        title: 'İSİM & SOYİSİM',
                        value: _getDisplayName(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // E-Posta
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFF6C5CE7),
                        title: 'E-POSTA',
                        value: _getDisplayEmail(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Telefon
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFF00CEC9),
                        title: 'TELEFON',
                        value: _getDisplayPhone(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Doğum Tarihi
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFFFF7675),
                        title: 'DOĞUM TARİHİ',
                        value: _getDisplayBirthDate(),
                      ),
                    ],
                  ),
                ),
              
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildProfileImage() {
  //   if (_profileImageUrl.isNotEmpty) {
  //     return ClipOval(
  //       child: Image.network(
  //         _profileImageUrl,
  //         width: 80,
  //         height: 80,
  //         fit: BoxFit.cover,
  //         errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary),
  //       ),
  //     );
  //   } else {
  //     return Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary);
  //   }
  // }

  // Widget _buildDatabaseProfileImage() {
  //   if (_userData?['profile_image'] != null) {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.circular(40),
  //       child: Image.network(
  //         _userData!['profile_image'],
  //         width: 80,
  //         height: 80,
  //         fit: BoxFit.cover,
  //         errorBuilder: (context, error, stackTrace) {
  //           return const Icon(
  //             Icons.person,
  //             size: 40,
  //             color: Colors.white,
  //           );
  //         },
  //       ),
  //     );
  //   } else {
  //     return const Icon(
  //       Icons.person,
  //       size: 40,
  //       color: Colors.white,
  //     );
  //   }
  // }

  String _getDisplayName() {
    if (_userFullName.isNotEmpty) {
      return _userFullName;
    } else if (_userData?['name'] != null && _userData!['name'].isNotEmpty) {
      return _userData!['name'];
    } else if (_userName.isNotEmpty) {
      return _userName;
    } else {
      return 'Örnek İsim';
    }
  }

  String _getDisplayEmail() {
    if (_userEmail.isNotEmpty) {
      return _userEmail;
    } else if (_userData?['email'] != null && _userData!['email'].isNotEmpty) {
      return _userData!['email'];
    } else {
      return 'ornek@gmail.com';
    }
  }

  String _getDisplayPhone() {
    if (_userPhone.isNotEmpty) {
      return _userPhone;
    } else if (_userData?['phone'] != null && _userData!['phone'].isNotEmpty) {
      return _userData!['phone'];
    } else {
      return '0 555 555 55 55';
    }
  }

  String _getDisplayBirthDate() {
    if (_userBirthDate.isNotEmpty) {
      return _userBirthDate;
    } else if (_userData?['birthdate'] != null && _userData!['birthdate'].isNotEmpty) {
      return _userData!['birthdate'];
    } else {
      return '01.01.1990';
    }
  }

  bool _isMissingInfo() {
    return (_userPhone.isEmpty) ||
           (_userBirthDate.isEmpty);
  }

  String _getMissingFields() {
    List<String> missing = [];
    
    if (_userPhone.isEmpty) {
      missing.add('Telefon');
    }
    if (_userBirthDate.isEmpty) {
      missing.add('Doğum Tarihi');
    }
    
    if (missing.length == 2) {
      return '${missing[0]} ve ${missing[1]}';
    } else if (missing.length == 1) {
      return missing[0];
    } else {
      return '';
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        // Icon Container
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Info Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF32343E),
                  fontSize: 14,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF6B6E82),
                  fontSize: 14,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 