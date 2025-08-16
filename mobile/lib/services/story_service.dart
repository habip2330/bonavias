import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story_model.dart';
import '../config/api_config.dart';

class StoryService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Tüm hikayeleri getir
  static Future<List<Story>> fetchStories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Aktif hikayeleri getir
  static Future<List<Story>> fetchActiveStories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Story> allStories = data.map((json) => Story.fromJson(json)).toList();
        
        // Sadece aktif hikayeleri filtrele ve sırala
        final activeStories = allStories
            .where((story) => story.isActive)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        return activeStories;
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Belirli bir hikayenin detaylarını getir
  static Future<Story?> fetchStoryById(String storyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stories/$storyId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Story.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Hikaye içeriklerini getir
  static Future<List<StoryItem>> fetchStoryItems(String storyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/story-items?story_id=$storyId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<StoryItem> items = data.map((json) => StoryItem.fromJson(json)).toList();
        
        // Sırala
        items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        
        return items;
      } else {
        throw Exception('Failed to load story items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Hikaye ve içeriklerini birlikte getir
  static Future<Map<String, dynamic>> fetchStoryWithItems(String storyId) async {
    try {
      final story = await fetchStoryById(storyId);
      if (story == null) {
        throw Exception('Story not found');
      }
      
      final items = await fetchStoryItems(storyId);
      
      return {
        'story': story,
        'items': items,
      };
    } catch (e) {
      throw Exception('Failed to fetch story with items: $e');
    }
  }
} 