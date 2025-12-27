// lib/features/post/presentation/widgets/post_list_item.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appbase_client/core/data/models/post_model.dart';
import 'package:appbase_client/core/services/posts_cache_manager.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

class PostListItem extends ConsumerWidget {
  final Post post;
  final bool showDownloadIcon;

  const PostListItem({
    super.key, 
    required this.post,
    this.showDownloadIcon = true,
  });
  
  // --- NEW: Helper for neon tag colors that adapts to theme ---
  Color _getTagBorderColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark 
      ? [Colors.cyanAccent, Colors.lightGreenAccent, Colors.orangeAccent] 
      : [Colors.blue.shade700, Colors.green.shade800, Colors.deepOrange.shade700];
    return colors[index % colors.length];
  }

  Color _getTagBackgroundColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _getTagBorderColor(index, context).withOpacity(isDark ? 0.25 : 0.15);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlinePostsProvider).any((p) => p.id == post.id);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          'postDetails',
          pathParameters: {'id': post.id},
          extra: post,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl.isNotEmpty)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  cacheManager: PostsCacheManager.instance,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey.shade300),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.summary,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // --- MODIFIED: Show all tags with new neon style ---
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: post.tags.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tag = entry.value;
                        final borderColor = _getTagBorderColor(index, context);
                        final bgColor = _getTagBackgroundColor(index, context);

                        return Chip(
                          label: Text(tag),
                          labelStyle: textTheme.bodySmall?.copyWith(color: borderColor, fontWeight: FontWeight.bold),
                          backgroundColor: bgColor,
                          side: BorderSide(color: borderColor.withOpacity(0.5)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  if (showDownloadIcon) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            isOffline ? Icons.download_done_rounded : Icons.download_for_offline_outlined,
                            color: isOffline ? Colors.green : Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () => ref.read(offlinePostsProvider.notifier).toggleOfflineStatus(post),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}