// CORRECTED: The import now uses a colon ':' which is correct.
import 'package:flutter/material.dart'; 
import 'package:appbase_client/core/data/models/post_model.dart';
import 'package:appbase_client/dummy/dummy_data.dart';
import 'package:appbase_client/features/post/presentation/screens/home_screen.dart';
import 'package:appbase_client/features/post/presentation/screens/post_detail_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');

    // Handle path: /posts/some-post-id
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'posts') {
      final postId = uri.pathSegments[1];
      
      // --- THIS IS THE DEFINITIVE FIX for the null safety error ---
      // We search the list. If we find a post, we use it. If not, the result is null.
      final post = dummyPosts.where((p) => p.id == postId).firstOrNull;
      
      if (post != null) {
        // If the post was found, show the detail screen
        return MaterialPageRoute(builder: (_) => PostDetailScreen(post: post));
      } else {
        // If the post ID was not found, show our error page
        return _errorRoute();
      }
    }

    // Handle default path: /
    if (uri.path == '/') {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    }

    // If the route is none of the above, it's a 404 error
    return _errorRoute();
  }

  // A private helper function to show a generic "Not Found" page.
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      );
    });
  }
}