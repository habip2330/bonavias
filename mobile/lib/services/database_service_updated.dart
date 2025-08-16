import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio();

  final String baseUrl = 'http://192.168.1.105:3001/api';
  final String serverUrl = 'http://192.168.1.105:3001'; // Server URL

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