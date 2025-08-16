import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FCM Token'ı kaydet
  Future<void> saveFCMToken() async {
    try {
      print('🔔 FCM Token alma süreci başladı...');
      
      // FCM izinlerini iste
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 FCM İzin Durumu: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🔔 FCM izinleri verildi, token alınıyor...');
        
        // FCM token'ı al
        String? token = await _messaging.getToken();
        
        if (token != null) {
          print('🔔 FCM Token başarıyla alındı: $token');
          
          // Token'ı SharedPreferences'a kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', token);
          print('🔔 FCM Token SharedPreferences\'a kaydedildi');
          
          // Kullanıcı giriş yapmışsa Firestore'a kaydet
          final user = _auth.currentUser;
          if (user != null) {
            print('🔔 Kullanıcı giriş yapmış, Firestore\'a kaydediliyor...');
            await _firestore.collection('users').doc(user.uid).update({
              'fcm_token': token,
              'last_token_update': FieldValue.serverTimestamp(),
            });
            print('🔔 FCM Token Firestore\'a kaydedildi');
          } else {
            print('🔔 Kullanıcı giriş yapmamış, Firestore kaydı atlandı');
          }
        } else {
          print('❌ FCM Token alınamadı!');
        }
      } else {
        print('❌ FCM izinleri verilmedi: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ FCM Token kaydetme hatası: $e');
    }
  }

  // FCM Token'ı güncelle
  Future<void> updateFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final oldToken = prefs.getString('fcm_token');
        
        if (oldToken != token) {
          await prefs.setString('fcm_token', token);
          
          final user = _auth.currentUser;
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'fcm_token': token,
              'last_token_update': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      print('FCM Token güncelleme hatası: $e');
    }
  }

  // Topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Topic aboneliği başarılı: $topic');
    } catch (e) {
      print('Topic aboneliği hatası: $e');
    }
  }

  // Topic'ten çık
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Topic aboneliği kaldırıldı: $topic');
    } catch (e) {
      print('Topic aboneliği kaldırma hatası: $e');
    }
  }

  // Local notification'ları başlat
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification'a tıklandığında yapılacak işlemler
        print('Notification tıklandı: ${response.payload}');
      },
    );
  }

  // Local notification göster
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bonavias_channel',
      'Bonavias Notifications',
      channelDescription: 'Bonavias uygulama bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Background message handler
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Background message alındı: ${message.messageId}');
    
    // Local notification göster
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bonavias_channel',
      'Bonavias Notifications',
      channelDescription: 'Bonavias uygulama bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Yeni Bildirim',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  // Foreground message handler
  void onMessageReceived(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message alındı: ${message.messageId}');
      
      // Local notification göster
      showLocalNotification(
        title: message.notification?.title ?? 'Yeni Bildirim',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
      
      // Callback'i çağır
      onMessage(message);
    });
  }

  // Notification'a tıklandığında
  void onMessageOpenedApp(Function(RemoteMessage) onMessageOpenedApp) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tıklandı: ${message.messageId}');
      onMessageOpenedApp(message);
    });
  }

  // Uygulama kapalıyken notification'a tıklandığında
  Future<void> getInitialMessage(Function(RemoteMessage) onInitialMessage) async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      print('Initial message: ${initialMessage.messageId}');
      onInitialMessage(initialMessage);
    }
  }
} 