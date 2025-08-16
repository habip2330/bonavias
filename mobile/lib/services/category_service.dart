import 'package:dio/dio.dart';

class CategoryService {
  final Dio _dio = Dio();
  // Kullanıcı kendi API adresini buraya girecek
  final String baseUrl = 'http://192.168.1.105:3001/api';

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('$baseUrl/categories');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Get categories error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/categories/$id');
      return response.data;
    } catch (e) {
      print('Get category by id error: $e');
      return null;
    }
  }

  Future<bool> addCategory(Map<String, dynamic> category) async {
    try {
      await _dio.post('$baseUrl/categories', data: category);
      return true;
    } catch (e) {
      print('Add category error: $e');
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> category) async {
    try {
      await _dio.put('$baseUrl/categories/$id', data: category);
      return true;
    } catch (e) {
      print('Update category error: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _dio.delete('$baseUrl/categories/$id');
      return true;
    } catch (e) {
      print('Delete category error: $e');
      return false;
    }
  }
} 