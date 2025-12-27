import 'package:hive_ce_flutter/hive_flutter.dart'; // <-- UPDATED IMPORT
import 'package:path_provider/path_provider.dart';
import 'package:appbase_client/core/data/models/post_model.dart';

class CacheService {
  Future<void> init() async {
    // This method is now empty.
    // All Hive initialization is now handled globally in main.dart to ensure it runs only once.
    // The original logic has been moved and improved there.
  }

  Future<void> cachePosts(List<Post> posts, String category) async {
    final box = await Hive.openBox<Post>('posts_$category');
    await box.clear();
    for (final post in posts) {
      await box.put(post.id, post);
    }
  }

  Future<List<Post>> getCachedPosts(String category) async {
    final box = await Hive.openBox<Post>('posts_$category');
    return box.values.toList();
  }
}