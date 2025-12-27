// lib/features/post/presentation/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // <-- IMPORT THE NEW PACKAGE
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:appbase_client/core/config/api_config.dart';
import 'package:appbase_client/core/data/models/post_model.dart';
import 'package:appbase_client/core/services/posts_cache_manager.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  final Post? postSummary; // Optional post summary for instant UI

  const PostDetailScreen({super.key, required this.postId, this.postSummary});

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '${ApiConfig.baseUrl}$url';
    }
    return url;
  }

  // --- NEW: Helper method to format the date ---
  String _getFormattedDate(Post post) {
    // If lastUpdatedAt exists, use it. Otherwise, use createdAt.
    final dateToShow = post.lastUpdatedAt ?? post.createdAt;
    final prefix = post.lastUpdatedAt != null ? 'Updated' : 'Published';
    
    // Format the date to a readable string like "Sep 29, 2025"
    return '$prefix: ${DateFormat.yMMMd().format(dateToShow)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postDetailsAsync = ref.watch(postDetailsProvider(postId));

    // If we have a summary, build the scaffold immediately.
    // Otherwise, wait for the data to load.
    if (postSummary != null) {
      return _buildPostView(context, ref, postSummary!, postDetailsAsync);
    }

    return postDetailsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Could not load post: $err')),
      ),
      data: (post) {
        return _buildPostView(context, ref, post, postDetailsAsync);
      },
    );
  }

  Widget _buildPostView(BuildContext context, WidgetRef ref, Post post, AsyncValue<Post> asyncPost) {
    final isOffline = ref.watch(offlinePostsProvider).any((p) => p.id == post.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Post',
            onPressed: () {
              final String postUrl = "${ApiConfig.baseUrl}/#/posts/${post.id}";
              final String shareMessage = "Check out this article from ibtwil:\n\n${post.title}\n$postUrl";
              Share.share(shareMessage);
            },
          ),
          IconButton(
            icon: Icon(
              isOffline ? Icons.download_done_rounded : Icons.download_for_offline_outlined,
              color: isOffline ? Colors.green : null,
            ),
            tooltip: isOffline ? 'Remove from Offline' : 'Save for Offline',
            onPressed: () => ref.read(offlinePostsProvider.notifier).toggleOfflineStatus(post),
          ),
        ],
      ),
      body: asyncPost.when(
        data: (fullPost) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          // --- MODIFIED: Wrap content in a Column to add the date ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NEW: Date display ---
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _getFormattedDate(fullPost),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const Divider(height: 24),
              // --- END NEW ---

              MarkdownBody(
                data: fullPost.content ?? "Content could not be loaded.",
                selectable: true,
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final uri = Uri.parse(_resolveUrl(href));
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                imageBuilder: (uri, title, alt) {
                  final resolvedUrl = _resolveUrl(uri.toString());
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: resolvedUrl,
                        cacheManager: PostsCacheManager.instance, // USE CUSTOM CACHE
                        fit: BoxFit.contain,
                        placeholder: (context, url) => AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                        errorWidget: (context, url, error) => AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red, size: 48),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  h1: Theme.of(context).textTheme.headlineMedium,
                  h2: Theme.of(context).textTheme.headlineSmall,
                  p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  a: TextStyle(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline),
                  codeblockDecoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockSpacing: 16.0,
                ),
              ),
            ],
          ),
        ),
        // Show a loader in the body while content is fetching
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Could not load content: $err')),
      ),
    );
  }
}