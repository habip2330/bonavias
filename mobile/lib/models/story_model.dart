String buildFullImageUrl(String imageUrl) {
  if (imageUrl.startsWith('http')) {
    return imageUrl;
  } else {
    return 'http://192.168.1.105:3001$imageUrl';
  }
}

class Story {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: buildFullImageUrl(json['image_url'] ?? ''),
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Story(id: $id, title: $title, displayOrder: $displayOrder, isActive: $isActive)';
  }
}

class StoryItem {
  final String id;
  final String storyId;
  final String imageUrl;
  final String description;
  final int displayOrder;
  final bool isActive;

  StoryItem({
    required this.id,
    required this.storyId,
    required this.imageUrl,
    required this.description,
    required this.displayOrder,
    required this.isActive,
  });

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    return StoryItem(
      id: json['id'] ?? '',
      storyId: json['story_id'] ?? '',
      imageUrl: buildFullImageUrl(json['image_url'] ?? ''),
      description: json['description'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story_id': storyId,
      'image_url': imageUrl,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
} 