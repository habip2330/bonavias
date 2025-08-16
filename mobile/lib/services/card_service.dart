import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saved_card.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının kartlarını getir
  Future<List<SavedCard>> getUserCards() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

      final querySnapshot = await _firestore
          .collection('saved_cards')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedCard.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Kartlar yüklenirken hata oluştu: $e');
    }
  }

  // Yeni kart ekle
  Future<void> addCard(SavedCard card) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

      await _firestore.collection('saved_cards').add(card.toMap());
    } catch (e) {
      throw Exception('Kart eklenirken hata oluştu: $e');
    }
  }

  // Kart güncelle
  Future<void> updateCard(SavedCard card) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

      await _firestore
          .collection('saved_cards')
          .doc(card.id)
          .update(card.toMap());
    } catch (e) {
      throw Exception('Kart güncellenirken hata oluştu: $e');
    }
  }

  // Kart sil
  Future<void> deleteCard(String cardId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı girişi yapılmamış');

      await _firestore.collection('saved_cards').doc(cardId).delete();
    } catch (e) {
      throw Exception('Kart silinirken hata oluştu: $e');
    }
  }

  // Kart numarasını maskele
  String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    String cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 4) return cardNumber;
    
    String lastFour = cleanNumber.substring(cleanNumber.length - 4);
    String masked = '**** **** **** $lastFour';
    return masked;
  }

  // Kart türünü belirle
  String getCardType(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5')) {
      return 'Master Card';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    } else {
      return 'Credit Card';
    }
  }
} 