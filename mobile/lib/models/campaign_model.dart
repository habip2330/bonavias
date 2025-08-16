class Campaign {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? code;
  final double? discountAmount;
  final String? discountType;
  final double? minOrderAmount;
  final String? terms;
  final String? campaignType; // 'general', 'buy_x_get_y', 'loyalty'
  final int? requiredCount; // Kaç adet alınması gerektiği
  final int? rewardCount; // Kaç adet hediye verileceği
  final String? rewardProductId; // Hediye edilecek ürün ID'si
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Campaign({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.code,
    this.discountAmount,
    this.discountType,
    this.minOrderAmount,
    this.terms,
    this.campaignType,
    this.requiredCount,
    this.rewardCount,
    this.rewardProductId,
    this.createdAt,
    this.updatedAt,
  });

  Campaign copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? code,
    double? discountAmount,
    String? discountType,
    double? minOrderAmount,
    String? terms,
    String? campaignType,
    int? requiredCount,
    int? rewardCount,
    String? rewardProductId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      code: code ?? this.code,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      terms: terms ?? this.terms,
      campaignType: campaignType ?? this.campaignType,
      requiredCount: requiredCount ?? this.requiredCount,
      rewardCount: rewardCount ?? this.rewardCount,
      rewardProductId: rewardProductId ?? this.rewardProductId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    print('🔍 Campaign.fromJson received: ${json['title']} - Image URL: ${json['image_url']}');
    
    final campaign = Campaign(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      code: json['code']?.toString(),
      discountAmount: _parseDouble(json['discount_amount']),
      discountType: json['discount_type']?.toString(),
      minOrderAmount: _parseDouble(json['min_order_amount']),
      terms: json['terms']?.toString(),
      campaignType: json['campaign_type']?.toString(),
      requiredCount: json['required_count']?.toInt(),
      rewardCount: json['reward_count']?.toInt(),
      rewardProductId: json['reward_product_id']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
    
    print('📱 Campaign created: ${campaign.title} - Image URL: ${campaign.imageUrl}');
    return campaign;
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign.fromJson(map);
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is DateTime) {
      print('📅 DateTime already parsed: $dateValue');
      return dateValue;
    }
    
    if (dateValue is String) {
      try {
        final parsed = DateTime.parse(dateValue);
        print('📅 String date parsed: $dateValue -> $parsed');
        return parsed;
      } catch (e) {
        print('❌ Error parsing date string: $dateValue - $e');
        return null;
      }
    }
    
    if (dateValue is int) {
      try {
        final parsed = DateTime.fromMillisecondsSinceEpoch(dateValue);
        print('📅 Timestamp parsed: $dateValue -> $parsed');
        return parsed;
      } catch (e) {
        print('❌ Error parsing timestamp: $dateValue - $e');
        return null;
      }
    }
    
    print('❌ Unknown date type: ${dateValue.runtimeType} - $dateValue');
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('❌ Error parsing double: $value - $e');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'code': code,
      'discount_amount': discountAmount,
      'discount_type': discountType,
      'min_order_amount': minOrderAmount,
      'terms': terms,
      'campaign_type': campaignType,
      'required_count': requiredCount,
      'reward_count': rewardCount,
      'reward_product_id': rewardProductId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, description: $description, imageUrl: $imageUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Campaign &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.imageUrl == imageUrl &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
} 