// lib/core/services/posts_cache_manager.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PostsCacheManager {
  static const key = 'customImageCacheKey';
  
  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // How long to cache images
      maxNrOfCacheObjects: 300, // Max number of images in cache
    ),
  );
}