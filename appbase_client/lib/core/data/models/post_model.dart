// lib/core/data/models/post_model.dart

import 'package:hive_ce/hive.dart'; // <-- 1. UPDATED IMPORT
import 'package:appbase_client/core/config/api_config.dart';

// 2. REMOVED: part 'post_model.g.dart';
// 3. REMOVED: @HiveType annotation

class Post extends HiveObject {
  // 4. REMOVED: All @HiveField annotations

  final String id;
  final String title;
  final String summary;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final List<String> tags;
  final String? coverImage;
  final String? content;
  final String author;
  final String primaryCategory;

  Post({
    required this.id,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.tags,
    this.coverImage,
    this.content,
    this.author = 'Admin',
    this.primaryCategory = 'General',
  });

  String get imageUrl {
    final image = coverImage;
    if (image == null || image.isEmpty) {
      return '';
    }
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return '${ApiConfig.baseUrl}$image';
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final metadata = json.containsKey('metadata') ? json['metadata'] : json;

    return Post(
      id: json['id'],
      title: metadata['title'],
      summary: metadata['summary'],
      createdAt: DateTime.parse(metadata['created_at']),
      lastUpdatedAt: metadata['last_updated_at'] != null
          ? DateTime.parse(metadata['last_updated_at'])
          : null,
      tags: List<String>.from(metadata['tags']),
      coverImage: metadata['cover_image'],
      content: json.containsKey('content') ? json['content'] : null,
      author: metadata['author'] ?? 'Admin',
      primaryCategory: metadata['primary_category'] ?? 'General',
    );
  }

  Post withContent(String newContent) {
    return Post(
      id: id,
      title: title,
      summary: summary,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      tags: tags,
      coverImage: coverImage,
      content: newContent,
      author: author,
      primaryCategory: primaryCategory,
    );
  }
}