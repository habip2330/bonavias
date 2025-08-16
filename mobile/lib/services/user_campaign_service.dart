import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_campaign_progress.dart';

class UserCampaignService {
  static const String baseUrl = 'http://192.168.1.105:3001/api';

  // Kullanıcının tüm kampanya ilerlemesini getir
  static Future<List<Map<String, dynamic>>> getUserCampaignProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-campaign-progress/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load campaign progress: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting user campaign progress: $e');
      throw Exception('Kampanya ilerlemesi yüklenirken hata oluştu');
    }
  }

  // Belirli bir kampanya için ilerleme getir
  static Future<Map<String, dynamic>> getCampaignProgress(String userId, String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-campaign-progress/$userId/$campaignId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load campaign progress: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting campaign progress: $e');
      throw Exception('Kampanya ilerlemesi yüklenirken hata oluştu');
    }
  }

  // Kampanya ilerlemesini artır (sipariş tamamlandığında)
  static Future<Map<String, dynamic>> incrementCampaignProgress(String userId, String campaignId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-campaign-progress/$userId/$campaignId/increment'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to increment campaign progress');
      }
    } catch (e) {
      print('❌ Error incrementing campaign progress: $e');
      throw Exception('Kampanya ilerlemesi güncellenirken hata oluştu');
    }
  }

  // Kampanya ödülünü talep et
  static Future<Map<String, dynamic>> claimCampaignReward(String userId, String campaignId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-campaign-progress/$userId/$campaignId/claim-reward'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to claim reward');
      }
    } catch (e) {
      print('❌ Error claiming campaign reward: $e');
      throw Exception('Kampanya ödülü alınırken hata oluştu');
    }
  }
} 