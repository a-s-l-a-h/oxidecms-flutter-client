import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appbase_client/features/post/presentation/widgets/post_list_item.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

class OfflinePostsScreen extends ConsumerWidget {
  const OfflinePostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlinePosts = ref.watch(offlinePostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Posts'),
      ),
      body: offlinePosts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You have not saved any posts for offline reading.\n\nClick the download icon on a post to save it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: offlinePosts.length,
              itemBuilder: (_, index) => PostListItem(post: offlinePosts[index]),
            ),
    );
  }
}