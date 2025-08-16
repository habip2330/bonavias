import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';  // Build hatası
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Dio _dio = Dio();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Kullanıcı kendi API adresini buraya girecek
  final String baseUrl = 'http://192.168.1.105:3001/api';
  final String serverUrl = 'http://192.168.1.105:3001'; // Server base URL for images

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Görsel URL'lerini tam URL'ye dönüştür
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    // Eğer zaten tam URL ise olduğu gibi döndür
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Eğer /public/ ile başlıyorsa server URL'si ile birleştir
    if (imageUrl.startsWith('/public/')) {
      return '$serverUrl$imageUrl';
    }
    
    // Eğer public/ ile başlıyorsa / ekleyerek server URL'si ile birleştir
    if (imageUrl.startsWith('public/')) {
      return '$serverUrl/$imageUrl';
    }
    
    // Diğer durumlar için server URL'si ile birleştir
    return '$serverUrl/$imageUrl';
  }

  // --- Firebase Authentication ---
  Future<UserCredential> authenticateUser(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Authentication error: $e');
      rethrow;
    }
  }

  Future<UserCredential> registerUser(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // İlk olarak mevcut oturumu temizle
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        print('Google Sign-In canceled by user');
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication tokens are null');
      }

      print('Google authentication tokens obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Google credential created');

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase authentication successful: ${userCredential.user?.email}');
      
      return userCredential;
    } catch (e) {
      print('Google sign in error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Apple Sign-In geçici olarak kapatıldı - build hatası
  Future<UserCredential?> signInWithApple() async {
    throw Exception('Apple Sign-In şu anda kullanılamıyor - build hatası');
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      print('Facebook Sign-In başlatılıyor...');

      // Facebook giriş işlemi
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        print('Facebook login başarılı');
        
        // Facebook access token al
        final AccessToken accessToken = result.accessToken!;
        
        // Facebook kullanıcı bilgilerini al
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );
        
        print('Facebook user data: $userData');

        // Firebase credential oluştur
        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);

        print('Facebook credential oluşturuldu');

        // Firebase ile giriş yap
        final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
        
        // Kullanıcı bilgilerini güncelle
        if (userData['name'] != null && userCredential.user != null) {
          await userCredential.user!.updateDisplayName(userData['name']);
        }

        print('Facebook Sign-In başarılı: ${userCredential.user?.email}');
        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook Sign-In kullanıcı tarafından iptal edildi');
        return null;
      } else {
        throw Exception('Facebook Sign-In başarısız: ${result.message}');
      }
    } catch (e) {
      print('Facebook sign in error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // --- Firebase Storage (Dosya Yükleme) ---
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload profile image error: $e');
      rethrow;
    }
  }

  // --- PostgreSQL (REST API) ile CRUD işlemleri ---
  // Kullanıcı verisi
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final response = await _dio.get('$baseUrl/users/$userId');
      final data = response.data;
      if (data is List) {
        if (data.isNotEmpty && data.first is Map<String, dynamic>) {
          return data.first as Map<String, dynamic>;
        }
        return null;
      } else if (data is Map<String, dynamic>) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _dio.put('$baseUrl/users/$userId', data: data);
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    }
  }

  // Ürünler
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products');
      final data = response.data;
      if (data is List) {
        return data.map((item) {
          final product = Map<String, dynamic>.from(item as Map);
          // Görsel URL'sini tam URL'ye dönüştür
          if (product['image_url'] != null) {
            product['image_url'] = _getFullImageUrl(product['image_url']);
          }
          return product;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _dio.get('$baseUrl/products?category_id=$categoryId');
      final data = response.data;
      if (data is List) {
        return data.map((item) {
          final product = Map<String, dynamic>.from(item as Map);
          // Görsel URL'sini tam URL'ye dönüştür
          if (product['image_url'] != null) {
            product['image_url'] = _getFullImageUrl(product['image_url']);
          }
          return product;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get products by category error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    try {
      final response = await _dio.get('$baseUrl/products/$id');
      final data = response.data;
      Map<String, dynamic>? product;
      if (data is Map<String, dynamic>) {
        product = data;
      } else if (data is Map) {
        product = Map<String, dynamic>.from(data);
      }
      
      // Görsel URL'sini tam URL'ye dönüştür
      if (product != null && product['image_url'] != null) {
        product['image_url'] = _getFullImageUrl(product['image_url']);
      }
      
      return product;
    } catch (e) {
      print('Get product error: $e');
      return null;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> product) async {
    try {
      await _dio.post('$baseUrl/products', data: product);
      return true;
    } catch (e) {
      print('Create product error: $e');
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      await _dio.put('$baseUrl/products/$id', data: product);
      return true;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _dio.delete('$baseUrl/products/$id');
      return true;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  // Kategoriler
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('$baseUrl/categories');
      final data = response.data;
      if (data is List) {
        return data.map((item) {
          final category = Map<String, dynamic>.from(item as Map);
          // Görsel URL'sini tam URL'ye dönüştür
          if (category['image_url'] != null) {
            category['image_url'] = _getFullImageUrl(category['image_url']);
          }
          return category;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get categories error: $e');
      return [];
    }
  }

  // Kampanyalar
  Future<List<Map<String, dynamic>>> getCampaigns() async {
    try {
      final response = await _dio.get('$baseUrl/campaigns');
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Get campaigns error: $e');
      return [];
    }
  }

  // Sliderlar
   Future<List<Map<String, dynamic>>> getSliders() async {
    try {
      print('Slider endpoint: $baseUrl/sliders');
      final response = await _dio.get('$baseUrl/sliders');
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Get sliders error: $e');
      return [];
    }
  }

  // Arama
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _dio.get('$baseUrl/products/search?q=$query');
      final data = response.data;
      if (data is List) {
        return data.map((item) {
          final product = Map<String, dynamic>.from(item as Map);
          // Görsel URL'sini tam URL'ye dönüştür
          if (product['image_url'] != null) {
            product['image_url'] = _getFullImageUrl(product['image_url']);
          }
          return product;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Search products error: $e');
      return [];
    }
  }

  // Şubeler (Branches)
  Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      final response = await _dio.get('$baseUrl/branches');
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Get branches error: $e');
      return [];
    }
  }

  // Bildirimler
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('$baseUrl/notifications');
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  // SSS (FAQ)
  Future<List<Map<String, dynamic>>> getFaqs() async {
    try {
      final response = await _dio.get('$baseUrl/faqs');
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Get faqs error: $e');
      return [];
    }
  }

  // --- Firebase Notification (isteğe bağlı) ---
  // Bildirim fonksiyonları burada kalabilir (Firebase Cloud Messaging veya Firestore ile)

  Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }
}

Future<void> _checkFirstTime(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final userId = prefs.getString('userId');

  print('Splash: hasSeenOnboarding=$hasSeenOnboarding, userId=$userId');

  if (!hasSeenOnboarding) {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  } else if (userId != null) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    Navigator.of(context).pushReplacementNamed('/login');
  }
} 
