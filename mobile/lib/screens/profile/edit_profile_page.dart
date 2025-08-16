import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  bool _isLoading = true;
  String? _profileImageUrl;
  File? _selectedImage;
  String _loginMethod = '';
  String _socialProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      final userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = doc.data() ?? {};
      setState(() {
        _nameController.text = userData['name'] ?? user.displayName ?? '';
        _emailController.text = userData['email'] ?? user.email ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _birthdateController.text = userData['birthdate'] ?? '';
        _profileImageUrl = userData['profile_image'];
        _isLoading = false;
      });
    } catch (e) {
      print('Kullanıcı verisi yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      final userId = user.uid;
      String? photoUrl = _profileImageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
        await ref.putFile(_selectedImage!);
        photoUrl = await ref.getDownloadURL();
        try {
          await user.updatePhotoURL(photoUrl);
          await user.reload();
        } catch (e) {
          print('Profil fotoğrafı güncellenemedi: $e');
        }
      }
      // Ad güncelle
      if (_nameController.text != user.displayName) {
        try {
          await user.updateDisplayName(_nameController.text);
          await user.reload();
        } catch (e) {
          print('Ad güncellenemedi: $e');
        }
      }
      // E-posta güncelle
      if (_emailController.text != user.email) {
        try {
          await user.updateEmail(_emailController.text);
          await user.reload();
        } catch (e) {
          print('E-posta güncellenemedi: $e');
        }
      }
      // Firestore'da telefon ve doğum tarihi güncelle
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).set({
        'phone': _phoneController.text,
        'birthdate': _birthdateController.text,
        'profile_image': photoUrl,
        'name': _nameController.text,
        'email': _emailController.text,
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Color(0xFFBC8157),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil güncellenirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFBC8157),
          ),
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
            child: Form(
              key: _formKey,
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
                        'Profili Düzenle',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sen',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Profil resmi, placeholder ve kamera ikonu ile ilgili kodlar kaldırıldı
                  
                  const SizedBox(height: 30),
                  
                  // Form Fields
                  // İsim & Soyisim
                  const Text(
                    'İSİM & SOYİSİM',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    validator: (value) => value == null || value.isEmpty ? 'Ad Soyad zorunlu' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // E-Posta
                  const Text(
                    'E-POSTA',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-Posta',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    validator: (value) => value == null || value.isEmpty ? 'E-posta zorunlu' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Telefon
                  const Text(
                    'TELEFON',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      counterText: '',
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Telefon zorunlu';
                      if (value.length != 11) return 'Telefon numarası 11 haneli olmalı';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Doğum Tarihi
                  const Text(
                    'DOĞUM TARİHİ',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    onTap: () async {
                      if (Platform.isIOS) {
                        DateTime initialDate = DateTime.tryParse(_birthdateController.text.split('.').reversed.join('-')) ?? DateTime(2000, 1, 1);
                        DateTime? pickedDate = await showCupertinoModalPopup<DateTime>(
                          context: context,
                          builder: (BuildContext context) {
                            DateTime tempPicked = initialDate;
                            return Container(
                              height: 250,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      initialDateTime: initialDate,
                                      minimumDate: DateTime(1900),
                                      maximumDate: DateTime.now(),
                                      onDateTimeChanged: (DateTime newDate) {
                                        tempPicked = newDate;
                                      },
                                    ),
                                  ),
                                  CupertinoButton(
                                    child: const Text('Seç'),
                                    onPressed: () {
                                      Navigator.of(context).pop(tempPicked);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _birthdateController.text = "${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}";
                          });
                        }
                      } else {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_birthdateController.text.split('.').reversed.join('-')) ?? DateTime(2000, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setState(() {
                            _birthdateController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
                          });
                        }
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Doğum Tarihi',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    validator: (value) => value == null || value.isEmpty ? 'Doğum tarihi zorunlu' : null,
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Save Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Sen'),
                        ),
                        onPressed: _saveProfile,
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Profil resmi ile ilgili kodlar ve fonksiyonlar kaldırıldı
}

