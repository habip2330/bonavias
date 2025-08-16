import 'package:dio/dio.dart';
import '../config/api_config.dart';

class SliderService {
  final Dio _dio = Dio();
  // API config'den URL'yi al
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getSliders() async {
    try {
      final response = await _dio.get('$baseUrl/sliders');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Get sliders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSliderById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/sliders/$id');
      return response.data;
    } catch (e) {
      print('Get slider by id error: $e');
      return null;
    }
  }

  Future<bool> addSlider(Map<String, dynamic> slider) async {
    try {
      await _dio.post('$baseUrl/sliders', data: slider);
      return true;
    } catch (e) {
      print('Add slider error: $e');
      return false;
    }
  }

  Future<bool> updateSlider(String id, Map<String, dynamic> slider) async {
    try {
      await _dio.put('$baseUrl/sliders/$id', data: slider);
      return true;
    } catch (e) {
      print('Update slider error: $e');
      return false;
    }
  }

  Future<bool> deleteSlider(String id) async {
    try {
      await _dio.delete('$baseUrl/sliders/$id');
      return true;
    } catch (e) {
      print('Delete slider error: $e');
      return false;
    }
  }
} 