// lib/features/post/providers/posts_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart'; // <-- UPDATED IMPORT
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appbase_client/core/data/models/post_model.dart';
import 'package:appbase_client/core/data/repositories/post_repository.dart';

// --- PAGINATION STATE HELPER ---
class PaginatedPostsState {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  PaginatedPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedPostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

// --- THEME PROVIDER ---
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

// --- UI STATE PROVIDERS ---
final searchQueryProvider = StateProvider<String>((ref) => '');
final submittedSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedTagsProvider = StateNotifierProvider<SelectedTagsNotifier, Set<String>>((ref) {
  return SelectedTagsNotifier(ref);
});

final rememberFilterProvider = StateProvider<bool>((ref) {
  return false;
});


// --- DATA FETCHING & CACHING PROVIDERS ---
final postRepositoryProvider = Provider((ref) => PostRepository());

// --- PAGINATED NOTIFIERS ---

// Notifier for latest posts with pagination
class PostSummariesNotifier extends StateNotifier<PaginatedPostsState> {
  final PostRepository _repository;
  final int _limit = 20; // Page size
  int _offset = 0;

  PostSummariesNotifier(this._repository) : super(PaginatedPostsState()) {
    fetchInitialPosts();
  }

  Future<void> fetchInitialPosts() async {
    _offset = 0;
    state = PaginatedPostsState(isLoading: true, hasMore: true);
    try {
      final newPosts = await _repository.getLatestPosts(limit: _limit, offset: _offset);
      state = PaginatedPostsState(
        posts: newPosts,
        hasMore: newPosts.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    _offset += _limit;

    try {
      final newPosts = await _repository.getLatestPosts(limit: _limit, offset: _offset);
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoading: false,
        hasMore: newPosts.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> refresh() async {
      await fetchInitialPosts();
  }
}

final postSummariesProvider = StateNotifierProvider<PostSummariesNotifier, PaginatedPostsState>((ref) {
    return PostSummariesNotifier(ref.watch(postRepositoryProvider));
});


// Notifier for server search with pagination
class ServerSearchNotifier extends StateNotifier<PaginatedPostsState> {
  final PostRepository _repository;
  final int _limit = 10;
  int _offset = 0;
  String _currentQuery = '';

  ServerSearchNotifier(this._repository) : super(PaginatedPostsState(hasMore: false));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _currentQuery = '';
      state = PaginatedPostsState(posts: [], hasMore: false);
      return;
    }
    
    if (_currentQuery == query) return;

    _currentQuery = query;
    _offset = 0;
    state = PaginatedPostsState(isLoading: true, hasMore: true);
    
    try {
      final newPosts = await _repository.searchPosts(_currentQuery, limit: _limit, offset: _offset);
      state = PaginatedPostsState(
        posts: newPosts,
        hasMore: newPosts.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore || _currentQuery.isEmpty) return;
    
    state = state.copyWith(isLoading: true);
    _offset += _limit;

    try {
      final newPosts = await _repository.searchPosts(_currentQuery, limit: _limit, offset: _offset);
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoading: false,
        hasMore: newPosts.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final serverSearchProvider = StateNotifierProvider.autoDispose<ServerSearchNotifier, PaginatedPostsState>((ref) {
    final notifier = ServerSearchNotifier(ref.watch(postRepositoryProvider));
    final query = ref.watch(submittedSearchQueryProvider);
    if (query.isNotEmpty) {
      notifier.search(query);
    }
    return notifier;
});


final availableTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository.getAvailableTags();
});

final filteredPostsProvider = Provider<List<Post>>((ref) {
  final summariesState = ref.watch(postSummariesProvider);
  final selectedTags = ref.watch(selectedTagsProvider);

  if (selectedTags.contains('All') || selectedTags.isEmpty) {
    return summariesState.posts;
  } else {
    return summariesState.posts.where((post) {
      return post.tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }
});


// --- POST DETAILS PROVIDER ---
const String VISITED_POSTS_BOX = 'visited_posts_cache';

final postDetailsProvider = FutureProvider.autoDispose.family<Post, String>((ref, postId) async {
  final repository = ref.watch(postRepositoryProvider);
  final visitedBox = await Hive.openBox<Post>(VISITED_POSTS_BOX);

  if (visitedBox.containsKey(postId)) {
    final cachedPost = visitedBox.get(postId)!;
    if (cachedPost.content != null && cachedPost.content!.isNotEmpty) {
      return cachedPost;
    }
  }
  
  final remotePost = await repository.getPostById(postId);
  await visitedBox.put(postId, remotePost);

  return remotePost;
});

// --- OFFLINE STATE MANAGEMENT ---
const String OFFLINE_BOX_NAME = 'offline_posts';

class OfflinePostsNotifier extends StateNotifier<List<Post>> {
  OfflinePostsNotifier() : super([]) {
    _loadOfflinePosts();
  }

  Future<void> _loadOfflinePosts() async {
    final box = await Hive.openBox<Post>(OFFLINE_BOX_NAME);
    state = box.values.toList();
  }
  
  Future<void> toggleOfflineStatus(Post post) async {
    final box = await Hive.openBox<Post>(OFFLINE_BOX_NAME);
    if (box.containsKey(post.id)) {
      await box.delete(post.id);
    } else {
      final postToSave = post.content == null || post.content!.isEmpty
          ? await PostRepository().getPostById(post.id)
          : post;
      await box.put(postToSave.id, postToSave);
    }
    state = box.values.toList();
  }
}

final offlinePostsProvider = StateNotifierProvider<OfflinePostsNotifier, List<Post>>((ref) {
  return OfflinePostsNotifier();
});

// --- FILTER PREFERENCES NOTIFIER ---
const String _filterPrefsKey = 'selected_filter_tags';
const String _rememberFilterKey = 'remember_filter_choice';

class SelectedTagsNotifier extends StateNotifier<Set<String>> {
  final Ref ref;
  bool _shouldRemember = false;

  SelectedTagsNotifier(this.ref) : super({'All'}) {
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    _shouldRemember = prefs.getBool(_rememberFilterKey) ?? false;
    ref.read(rememberFilterProvider.notifier).state = _shouldRemember;

    if (_shouldRemember) {
      final savedFilters = prefs.getStringList(_filterPrefsKey);
      if (savedFilters != null && savedFilters.isNotEmpty) {
        state = savedFilters.toSet();
      } else {
        state = {'All'};
      }
    }
  }
  
  Future<void> _saveFilters() async {
    if (_shouldRemember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_filterPrefsKey, state.toList());
    }
  }

  Future<void> setRememberPreference(bool value) async {
    _shouldRemember = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberFilterKey, value);
    if (!value) {
      await prefs.remove(_filterPrefsKey);
    } else {
      _saveFilters();
    }
  }

  void updateFilters(Set<String> newFilters) {
    if (newFilters.isEmpty) {
      state = {'All'};
    } else {
      state = newFilters;
    }
    _saveFilters();
  }

  void clearFilters() {
    state = {'All'};
    _saveFilters();
  }
}