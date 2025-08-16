import 'package:dio/dio.dart';

class ProductService {
  final Dio _dio = Dio();
  // Kullanıcı kendi API adresini buraya girecek
  final String baseUrl = 'http://192.168.1.105:3001/api';
  final String serverUrl = 'http://192.168.1.105:3001'; // Server base URL for images

  // Görsel URL'lerini tam URL'ye dönüştür
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    print('🔄 URL dönüştürme: "$imageUrl"');
    
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

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products');
      final data = List<Map<String, dynamic>>.from(response.data);
      // Görsel URL'lerini tam URL'ye dönüştür
      return data.map((product) {
        if (product['image_url'] != null) {
          product['image_url'] = _getFullImageUrl(product['image_url']);
        }
        return product;
      }).toList();
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _dio.get('$baseUrl/products?category_id=$categoryId');
      final data = List<Map<String, dynamic>>.from(response.data);
      // Görsel URL'lerini tam URL'ye dönüştür
      return data.map((product) {
        if (product['image_url'] != null) {
          product['image_url'] = _getFullImageUrl(product['image_url']);
        }
        return product;
      }).toList();
    } catch (e) {
      print('Get products by category error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    try {
      final response = await _dio.get('$baseUrl/products/$id');
      final product = response.data as Map<String, dynamic>?;
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

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _dio.get('$baseUrl/products/search?q=$query');
      final data = List<Map<String, dynamic>>.from(response.data);
      // Görsel URL'lerini tam URL'ye dönüştür
      return data.map((product) {
        if (product['image_url'] != null) {
          product['image_url'] = _getFullImageUrl(product['image_url']);
        }
        return product;
      }).toList();
    } catch (e) {
      print('Search products error: $e');
      return [];
    }
  }
} 