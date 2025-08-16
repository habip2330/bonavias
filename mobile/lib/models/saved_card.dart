class SavedCard {
  final String id;
  final String cardType;
  final String maskedNumber;
  final String lastFourDigits;
  final String expiryDate;
  final String holderName;
  final String userId;
  final DateTime createdAt;

  SavedCard({
    required this.id,
    required this.cardType,
    required this.maskedNumber,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.holderName,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardType': cardType,
      'maskedNumber': maskedNumber,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'holderName': holderName,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SavedCard.fromMap(Map<String, dynamic> map) {
    return SavedCard(
      id: map['id'] ?? '',
      cardType: map['cardType'] ?? '',
      maskedNumber: map['maskedNumber'] ?? '',
      lastFourDigits: map['lastFourDigits'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      holderName: map['holderName'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  SavedCard copyWith({
    String? id,
    String? cardType,
    String? maskedNumber,
    String? lastFourDigits,
    String? expiryDate,
    String? holderName,
    String? userId,
    DateTime? createdAt,
  }) {
    return SavedCard(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryDate: expiryDate ?? this.expiryDate,
      holderName: holderName ?? this.holderName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 