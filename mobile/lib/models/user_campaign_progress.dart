class UserCampaignProgress {
  final String id;
  final String userId;
  final String campaignId;
  final int currentCount;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserCampaignProgress({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.currentCount,
    required this.isCompleted,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  UserCampaignProgress copyWith({
    String? id,
    String? userId,
    String? campaignId,
    int? currentCount,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserCampaignProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserCampaignProgress.fromJson(Map<String, dynamic> json) {
    return UserCampaignProgress(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      campaignId: json['campaign_id']?.toString() ?? '',
      currentCount: json['current_count']?.toInt() ?? 0,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1 || json['is_completed'] == '1',
      completedAt: _parseDateTime(json['completed_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is DateTime) return dateValue;
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('❌ Error parsing date string: $dateValue - $e');
        return null;
      }
    }
    
    if (dateValue is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } catch (e) {
        print('❌ Error parsing timestamp: $dateValue - $e');
        return null;
      }
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'campaign_id': campaignId,
      'current_count': currentCount,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserCampaignProgress(id: $id, userId: $userId, campaignId: $campaignId, currentCount: $currentCount, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserCampaignProgress &&
      other.id == id &&
      other.userId == userId &&
      other.campaignId == campaignId &&
      other.currentCount == currentCount &&
      other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      campaignId.hashCode ^
      currentCount.hashCode ^
      isCompleted.hashCode;
  }
} 