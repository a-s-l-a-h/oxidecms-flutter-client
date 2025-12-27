// lib/features/post/presentation/widgets/latest_posts_slider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:appbase_client/core/data/models/post_model.dart';
import 'package:appbase_client/core/services/posts_cache_manager.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

class LatestPostsSlider extends ConsumerWidget {
  const LatestPostsSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- THIS IS THE FIX ---
    // 1. We now watch the provider which returns a `PaginatedPostsState` object.
    final postsState = ref.watch(postSummariesProvider);

    // 2. We handle the UI state by directly checking the properties of the state object,
    // instead of using the old `.when()` method.

    // Show a loader only on the initial fetch when the list is still empty.
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // If there's an error and we never loaded any posts, hide the widget.
    if (postsState.error != null && postsState.posts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // If the final list of posts is empty, hide the widget.
    if (postsState.posts.isEmpty) {
      return const SizedBox.shrink();
    }

    // 3. If we have posts, we access them directly from `postsState.posts`.
    final posts = postsState.posts;
    final initialPosts = posts.take(5).toList();
    List<Post> orderedPosts;

    if (initialPosts.length == 5) {
      orderedPosts = [ initialPosts[2], initialPosts[3], initialPosts[4], initialPosts[0], initialPosts[1] ];
    } else {
      orderedPosts = initialPosts;
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.65),
        itemCount: orderedPosts.length,
        itemBuilder: (context, index) {
          final post = orderedPosts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _LatestPostCard(post: post),
          );
        },
      ),
    );
  }
}

class _LatestPostCard extends StatelessWidget {
  final Post post;
  const _LatestPostCard({required this.post});

  Color _getTagColor(int index) {
    final colors = [ Colors.cyanAccent, Colors.lightGreenAccent, Colors.deepOrangeAccent, Colors.yellowAccent ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.goNamed('postDetails', pathParameters: {'id': post.id}, extra: post),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (post.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: post.imageUrl,
                cacheManager: PostsCacheManager.instance,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade300),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.95)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      shadows: [const Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  if (post.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 6.0, runSpacing: 4.0,
                        children: post.tags.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tag = entry.value;
                          final color = _getTagColor(index);
                          return Chip(
                            label: Text(tag),
                            labelStyle: TextStyle(
                              color: color, fontSize: 10, fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 2, color: color)],
                            ),
                            backgroundColor: Colors.black.withOpacity(0.4),
                            side: BorderSide(color: color, width: 1),
                            shape: const StadiumBorder(),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          );
                        }).toList(),
                      ),
                    ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          post.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.read_more, size: 16),
                        label: const Text('Read'),
                        onPressed: () => context.goNamed('postDetails', pathParameters: {'id': post.id}, extra: post),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}