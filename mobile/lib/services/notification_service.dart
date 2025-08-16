import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createNotification({
    required String title,
    required String body,
    String? topic,
  }) async {
    try {
      final docRef = await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'topic': topic,
        'user_id': _auth.currentUser?.uid,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      print('Bildirim oluşturma hatası: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Bildirimleri getirme hatası: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'is_read': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bildirim işaretleme hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Bildirim silme hatası: $e');
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }
} 