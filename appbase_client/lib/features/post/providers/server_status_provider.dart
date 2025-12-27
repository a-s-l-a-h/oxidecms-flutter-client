// lib/features/post/providers/server_status_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appbase_client/core/data/repositories/post_repository.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

final serverStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return await repository.isServerActive();
});