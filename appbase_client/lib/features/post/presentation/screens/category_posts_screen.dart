import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';
import 'package:appbase_client/features/post/presentation/widgets/post_list_item.dart';

class CategoryPostsScreen extends ConsumerWidget {
  final String categoryKey;
  final String categoryName;

  const CategoryPostsScreen({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(postsProvider(categoryKey));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found in this category.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostListItem(post: posts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('An error occurred: $err')),
      ),
    );
  }
}