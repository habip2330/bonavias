class SliderModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isActive;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  SliderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SliderModel.fromMap(Map<String, dynamic> map) {
    return SliderModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      isActive: map['is_active'] ?? false,
      orderIndex: map['order_index'] ?? 0,
      createdAt: map['created_at'] is String ? DateTime.parse(map['created_at']) : map['created_at'],
      updatedAt: map['updated_at'] is String ? DateTime.parse(map['updated_at']) : map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'order_index': orderIndex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 