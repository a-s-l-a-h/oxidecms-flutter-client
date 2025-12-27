// lib/features/settings/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:appbase_client/core/services/posts_cache_manager.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

enum ClearOption {
  cachedPosts,
  offlinePosts,
  images,
}

final isClearingProvider = StateProvider<bool>((ref) => false);

final clearSettingsProvider = StateNotifierProvider<ClearSettingsNotifier, Map<ClearOption, bool>>((ref) {
  return ClearSettingsNotifier(ref);
});

class ClearSettingsNotifier extends StateNotifier<Map<ClearOption, bool>> {
  final Ref _ref;

  ClearSettingsNotifier(this._ref)
      : super({
          ClearOption.cachedPosts: false,
          ClearOption.offlinePosts: false,
          ClearOption.images: false,
        });

  void toggleOption(ClearOption option, bool value) {
    state = {...state, option: value};
  }

  Future<String> clearSelectedCaches() async {
    _ref.read(isClearingProvider.notifier).state = true;
    final List<String> clearedItems = [];

    try {
      if (state[ClearOption.cachedPosts] == true) {
        await Hive.deleteBoxFromDisk(VISITED_POSTS_BOX);
        clearedItems.add('cached posts');
      }

      if (state[ClearOption.offlinePosts] == true) {
        await Hive.deleteBoxFromDisk(OFFLINE_BOX_NAME);
        _ref.invalidate(offlinePostsProvider); // To refresh the UI
        clearedItems.add('offline posts');
      }

      if (state[ClearOption.images] == true) {
        await PostsCacheManager.instance.emptyCache();
        clearedItems.add('images');
      }
      
      state = {
        ClearOption.cachedPosts: false,
        ClearOption.offlinePosts: false,
        ClearOption.images: false,
      };

      _ref.read(isClearingProvider.notifier).state = false;
      
      if (clearedItems.isEmpty) {
        return "No items selected to clear.";
      }
      
      return "Successfully cleared: ${clearedItems.join(', ')}.";

    } catch (e) {
      _ref.read(isClearingProvider.notifier).state = false;
      return "An error occurred: $e";
    }
  }
}