import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign_model.dart';
import 'database_service.dart';
import '../config/api_config.dart';

class CampaignService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const String serverUrl = ApiConfig.serverUrl;

  static Future<List<Campaign>> getCampaigns() async {
    print('🚀 CampaignService.getCampaigns() started');
    
    try {
      final token = await DatabaseService.getAuthToken();
      print('🔑 Auth token: ${token != null ? "Found" : "Not found"}');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('📡 Making request to: $baseUrl/campaigns');
      print('📋 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/campaigns'),
        headers: headers,
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        print('🔍 Decoded JSON type: ${jsonData.runtimeType}');
        print('🔍 Decoded JSON: $jsonData');
        
        if (jsonData is Map<String, dynamic>) {
          // If response is wrapped in an object
          if (jsonData.containsKey('campaigns')) {
            final List<dynamic> campaignsList = jsonData['campaigns'] as List<dynamic>;
            print('📦 Found ${campaignsList.length} campaigns in wrapped response');
            return campaignsList.map((json) {
              final campaignMap = json as Map<String, dynamic>;
              // Fix image URL
              if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
                campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
                print('🔧 Fixed campaign image URL: ${campaignMap['image_url']}');
              }
              return Campaign.fromJson(campaignMap);
            }).toList();
          } else if (jsonData.containsKey('data')) {
            final List<dynamic> campaignsList = jsonData['data'] as List<dynamic>;
            print('📦 Found ${campaignsList.length} campaigns in data field');
            return campaignsList.map((json) {
              final campaignMap = json as Map<String, dynamic>;
              // Fix image URL
              if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
                campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
                print('🔧 Fixed campaign image URL: ${campaignMap['image_url']}');
              }
              return Campaign.fromJson(campaignMap);
            }).toList();
          } else if (jsonData.containsKey('success') && jsonData['success'] == true) {
            // Handle success response format
            final List<dynamic> campaignsList = jsonData['data'] as List<dynamic>? ?? [];
            print('📦 Found ${campaignsList.length} campaigns in success response');
            return campaignsList.map((json) {
              final campaignMap = json as Map<String, dynamic>;
              // Fix image URL
              if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
                campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
                print('🔧 Fixed campaign image URL: ${campaignMap['image_url']}');
              }
              return Campaign.fromJson(campaignMap);
            }).toList();
          }
        } else if (jsonData is List<dynamic>) {
          // If response is directly a list
          print('📦 Found ${jsonData.length} campaigns in direct list');
          return jsonData.map((json) {
            final campaignMap = json as Map<String, dynamic>;
            // Fix image URL
            if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
              campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
              print('🔧 Fixed campaign image URL: ${campaignMap['image_url']}');
            }
            return Campaign.fromJson(campaignMap);
          }).toList();
        }
        
        print('❌ Unexpected response format');
        return [];
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Exception in getCampaigns: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Error fetching campaigns: $e');
    }
  }

  static Future<List<Campaign>> getActiveCampaigns() async {
    print('🎯 CampaignService.getActiveCampaigns() started');
    
    try {
      // Önce server-side active endpoint'ini deneyelim
      final token = await DatabaseService.getAuthToken();
      print('🔑 Auth token: ${token != null ? "Found" : "Not found"}');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('📡 Making request to: $baseUrl/campaigns/active');
      print('📋 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/campaigns/active'),
        headers: headers,
      );
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('📝 Response body: ${response.body}');
        final dynamic jsonData = json.decode(response.body);
        print('🔍 Decoded JSON type: ${jsonData.runtimeType}');
        
        List<Campaign> campaigns = [];
        
        if (jsonData is Map<String, dynamic>) {
          // If response is wrapped in an object
          if (jsonData.containsKey('campaigns')) {
            final List<dynamic> campaignsList = jsonData['campaigns'] as List<dynamic>;
            print('📦 Found ${campaignsList.length} campaigns in wrapped response');
            campaigns = campaignsList.map((json) {
              final campaignMap = json as Map<String, dynamic>;
              // Fix image URL
              if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
                campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
                print('🔧 Fixed active campaign image URL: ${campaignMap['image_url']}');
              }
              return Campaign.fromJson(campaignMap);
            }).toList();
          } else if (jsonData.containsKey('data')) {
            final List<dynamic> campaignsList = jsonData['data'] as List<dynamic>;
            print('📦 Found ${campaignsList.length} campaigns in data field');
            campaigns = campaignsList.map((json) {
              final campaignMap = json as Map<String, dynamic>;
              // Fix image URL
              if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
                campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
                print('🔧 Fixed active campaign image URL: ${campaignMap['image_url']}');
              }
              return Campaign.fromJson(campaignMap);
            }).toList();
          }
        } else if (jsonData is List<dynamic>) {
          // If response is directly a list
          print('📦 Found ${jsonData.length} campaigns in direct list');
          campaigns = jsonData.map((json) {
            final campaignMap = json as Map<String, dynamic>;
            // Fix image URL
            if (campaignMap['image_url'] != null && !campaignMap['image_url'].toString().startsWith('http')) {
              campaignMap['image_url'] = '$serverUrl${campaignMap['image_url']}';
              print('🔧 Fixed active campaign image URL: ${campaignMap['image_url']}');
            }
            return Campaign.fromJson(campaignMap);
          }).toList();
        }
        
        print('✅ Server-side active campaigns: ${campaigns.length}');
        for (final campaign in campaigns) {
          print('📋 Active campaign: ${campaign.toString()}');
        }
        
        return campaigns;
      } else {
        print('❌ Server-side active endpoint failed with status: ${response.statusCode}');
        print('❌ Falling back to client-side filtering...');
      }
    } catch (e) {
      print('❌ Server-side active endpoint error: $e');
      print('❌ Falling back to client-side filtering...');
    }
    
    // Fallback: Client-side filtering
    try {
      final allCampaigns = await getCampaigns();
      print('📊 Total campaigns fetched: ${allCampaigns.length}');
      
      // Tüm kampanyaları detaylı logla
      for (int i = 0; i < allCampaigns.length; i++) {
        final campaign = allCampaigns[i];
        print('📋 Campaign $i: ID=${campaign.id}, Title=${campaign.title}, Active=${campaign.isActive}');
        print('   StartDate=${campaign.startDate}, EndDate=${campaign.endDate}');
      }
      
      final activeCampaigns = allCampaigns.where((campaign) {
        final isActive = campaign.isActive;
        final now = DateTime.now();
        
        print('🔍 Campaign ${campaign.id}: ${campaign.title}');
        print('   isActive: $isActive');
        print('   startDate: ${campaign.startDate}');
        print('   endDate: ${campaign.endDate}');
        print('   now: $now');
        
        // Tarih kontrolü yapalım ama daha detaylı log'larla
        bool dateCheck = true;
        if (campaign.endDate != null) {
          dateCheck = campaign.endDate!.isAfter(now);
          print('   endDate check: ${campaign.endDate} > $now = $dateCheck');
        }
        
        final result = isActive && dateCheck;
        print('   FINAL RESULT: $result');
        print('   ---');
        
        return result;
      }).toList();
      
      print('✅ Client-side active campaigns: ${activeCampaigns.length}');
      for (final campaign in activeCampaigns) {
        print('📋 Active campaign: ${campaign.toString()}');
      }
      
      return activeCampaigns;
    } catch (e, stackTrace) {
      print('❌ Exception in client-side filtering: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Error fetching active campaigns: $e');
    }
  }

  static Future<Campaign?> getCampaignById(String id) async {
    print('🔍 CampaignService.getCampaignById($id) started');
    
    try {
      final token = await DatabaseService.getAuthToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/campaigns/$id'),
        headers: headers,
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('campaign')) {
            return Campaign.fromJson(jsonData['campaign'] as Map<String, dynamic>);
          } else if (jsonData.containsKey('data')) {
            return Campaign.fromJson(jsonData['data'] as Map<String, dynamic>);
          } else {
            return Campaign.fromJson(jsonData);
          }
        }
        
        return null;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Exception in getCampaignById: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  Future<bool> addCampaign(Campaign campaign) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/campaigns'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(campaign.toMap()),
      );
      return true;
    } catch (e) {
      print('Add campaign error: $e');
      return false;
    }
  }

  Future<bool> updateCampaign(String id, Campaign campaign) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/campaigns/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(campaign.toMap()),
      );
      return true;
    } catch (e) {
      print('Update campaign error: $e');
      return false;
    }
  }

  Future<bool> deleteCampaign(String id) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/campaigns/$id'),
      );
      return true;
    } catch (e) {
      print('Delete campaign error: $e');
      return false;
    }
  }
} 