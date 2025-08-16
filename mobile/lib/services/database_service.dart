import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Public getters for external access
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final Dio _dio = Dio();

  // API konfigürasyonunu import edin: import '../config/api_config.dart';
  final String baseUrl = ApiConfig.baseUrl;
  final String serverUrl = ApiConfig.serverUrl; // Server URL

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Auth token'ı SharedPreferences'den al
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔑 DatabaseService.getAuthToken(): ${token != null ? "Found" : "Not found"}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Auth token'ı SharedPreferences'e kaydet
  static Future<void> setAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('🔑 DatabaseService.setAuthToken(): Token saved');
    } catch (e) {
      print('❌ Error setting auth token: $e');
    }
  }

  // Auth token'ı temizle
  static Future<void> clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('🔑 DatabaseService.clearAuthToken(): Token cleared');
    } catch (e) {
      print('❌ Error clearing auth token: $e');
    }
  }

  // Firebase Firestore (kullanım dışı, şimdi PostgreSQL kullanıyoruz)
  DocumentReference getUserDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Görsel URL'lerini tam URL'ye dönüştür
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      print('⚠️ _getFullImageUrl: imageUrl is null or empty');
      return '';
    }
    
    print('🔄 DatabaseService URL dönüştürme başlıyor...');
    print('   Input: "$imageUrl"');
    print('   Server URL: "$serverUrl"');
    
    // Eğer zaten tam URL ise olduğu gibi döndür
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      print('✅ Zaten tam URL: $imageUrl');
      return imageUrl;
    }
    
    // Eğer /public/products/ ile başlıyorsa /public/uploads/products/ olarak düzelt
    if (imageUrl.startsWith('/public/products/')) {
      final correctedUrl = imageUrl.replaceFirst('/public/products/', '/public/uploads/products/');
      final fullUrl = '$serverUrl$correctedUrl';
      print('✅ /public/products/ düzeltildi: $imageUrl -> $fullUrl');
      return fullUrl;
    }
    
    // Eğer /public/uploads/ ile başlıyorsa server URL'si ile birleştir
    if (imageUrl.startsWith('/public/uploads/')) {
      final fullUrl = '$serverUrl$imageUrl';
      print('✅ /public/uploads/ ile başlıyor: $imageUrl -> $fullUrl');
      print('   Final URL: "$fullUrl"');
      return fullUrl;
    }
    
    // Eğer /public/ ile başlıyorsa server URL'si ile birleştir
    if (imageUrl.startsWith('/public/')) {
      final fullUrl = '$serverUrl$imageUrl';
      print('✅ /public/ ile başlıyor: $imageUrl -> $fullUrl');
      return fullUrl;
    }
    
    // Eğer public/ ile başlıyorsa / ekleyerek server URL'si ile birleştir
    if (imageUrl.startsWith('public/')) {
      final fullUrl = '$serverUrl/$imageUrl';
      print('✅ public/ ile başlıyor: $imageUrl -> $fullUrl');
      return fullUrl;
    }
    
    // Diğer durumlar için server URL'si ile birleştir
    final fullUrl = '$serverUrl/$imageUrl';
    print('✅ Diğer durum: $imageUrl -> $fullUrl');
    return fullUrl;
  }

  // Ingredients'i allergens'e dönüştür (helper function)
  List<String> _processIngredients(dynamic ingredients) {
    if (ingredients == null) return <String>[];
    
    if (ingredients is String) {
      try {
        final parsed = jsonDecode(ingredients);
        if (parsed is List) {
          return List<String>.from(parsed);
        }
      } catch (e) {
        print('⚠️ Ingredients JSON parse hatası: $e');
        return <String>[];
      }
    } else if (ingredients is List) {
      return List<String>.from(ingredients);
    }
    
    return <String>[];
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

  // Verification kodu gönderme
  Future<void> sendVerificationCode(String email) async {
    try {
      print('📧 Verification kodu gönderiliyor: $email');
      
      // 6 haneli rastgele kod oluştur
      final verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      
      // Firestore'a verification kodu kaydet
      await _firestore.collection('verification_codes').doc(email).set({
        'code': verificationCode,
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'used': false,
      });
      
      print('✅ Verification kodu Firestore\'a kaydedildi: $email');
      print('📧 Verification code for $email: $verificationCode');
      
      // Kodu SharedPreferences'a da kaydet (geçici olarak)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verification_code_$email', verificationCode);
      await prefs.setInt('verification_code_expiry_$email', DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch);
      
    } catch (e) {
      print('❌ Verification kodu gönderme hatası: $e');
      rethrow;
    }
  }

  // Verification kodunu doğrulama
  Future<bool> verifyCode(String email, String code) async {
    try {
      print('🔍 Verification kodu doğrulanıyor: $email');
      
      // Firestore'dan verification kodu al
      final doc = await _firestore.collection('verification_codes').doc(email).get();
      
      if (!doc.exists) {
        print('❌ Verification kodu bulunamadı: $email');
        return false;
      }
      
      final data = doc.data()!;
      final savedCode = data['code'] as String;
      final expiresAt = (data['expires_at'] as Timestamp).toDate();
      final used = data['used'] as bool;
      
      // Süre kontrolü
      if (DateTime.now().isAfter(expiresAt)) {
        print('❌ Verification kodu süresi dolmuş: $email');
        await _firestore.collection('verification_codes').doc(email).delete();
        return false;
      }
      
      // Kullanılmış mı kontrolü
      if (used) {
        print('❌ Verification kodu zaten kullanılmış: $email');
        return false;
      }
      
      // Kod kontrolü
      if (savedCode == code) {
        print('✅ Verification kodu doğrulandı: $email');
        
        // Kodu kullanıldı olarak işaretle
        await _firestore.collection('verification_codes').doc(email).update({
          'used': true,
        });
        
        // SharedPreferences'dan kodu temizle
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('verification_code_$email');
        await prefs.remove('verification_code_expiry_$email');
        
        return true;
      } else {
        print('❌ Verification kodu yanlış: $email');
        return false;
      }
    } catch (e) {
      print('❌ Verification kodu doğrulama hatası: $e');
      return false;
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
        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);

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
          // Ingredients'i allergens olarak dönüştür
          product['allergens'] = _processIngredients(product['ingredients']);
          print('🧪 Product ${product['name']}: allergens = ${product['allergens']}');
          return product;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  // Kategori ürünleri
  Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _dio.get('$baseUrl/products/category/$categoryId');
      final data = response.data;
      if (data is List) {
        return data.map((item) {
          final product = Map<String, dynamic>.from(item as Map);
          // Görsel URL'sini tam URL'ye dönüştür
          if (product['image_url'] != null) {
            product['image_url'] = _getFullImageUrl(product['image_url']);
          }
          // Ingredients'i allergens olarak dönüştür
          product['allergens'] = _processIngredients(product['ingredients']);
          print('🧪 Category Product ${product['name']}: allergens = ${product['allergens']}');
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
      
      // Ingredients'i allergens olarak dönüştür
      if (product != null) {
        product['allergens'] = _processIngredients(product['ingredients']);
        print('🧪 Single Product ${product['name']}: allergens = ${product['allergens']}');
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
        return data.map((item) {
          final campaign = Map<String, dynamic>.from(item as Map);
          print('🔍 Original campaign data: ${campaign['title']} - Image: ${campaign['image_url']}');
          // Görsel URL'sini tam URL'ye dönüştür
          if (campaign['image_url'] != null) {
            final originalUrl = campaign['image_url'];
            final convertedUrl = _getFullImageUrl(campaign['image_url']);
            campaign['image_url'] = convertedUrl;
            print('🔄 URL conversion: "$originalUrl" -> "$convertedUrl"');
            print('🖼️ Final campaign image URL: ${campaign['image_url']}');
          }
          return campaign;
        }).toList();
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
          // Ingredients'i allergens olarak dönüştür
          product['allergens'] = _processIngredients(product['ingredients']);
          print('🧪 Search Product ${product['name']}: allergens = ${product['allergens']}');
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

  Future<void> sendNotification(String userId, String title, String message) async {
    try {
      final userDoc = await getUserDocument(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        final fcmToken = data?['fcmToken'];
        
        if (fcmToken != null) {
          // FCM gönderme işlemi burada yapılabilir
          print('Sending notification to $fcmToken: $title - $message');
        }
      }
    } catch (e) {
      print('Send notification error: $e');
    }
  }

  // Tek bildirimi okundu olarak işaretle
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dio.put('$baseUrl/notifications/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Mark notification as read error: $e');
      return false;
    }
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.put('$baseUrl/notifications/mark-all-read');
      return response.statusCode == 200;
    } catch (e) {
      print('Mark all notifications as read error: $e');
      return false;
    }
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
    Navigator.of(context).pushReplacementNamed('/signin');
  }
} 