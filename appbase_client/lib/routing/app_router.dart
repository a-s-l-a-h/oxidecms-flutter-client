// lib/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appbase_client/core/data/models/post_model.dart';
// We no longer need to import AboutScreen here
import 'package:appbase_client/features/post/presentation/screens/home_screen.dart';
import 'package:appbase_client/features/post/presentation/screens/post_detail_screen.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'posts/:id',
          name: 'postDetails',
          builder: (context, state) {
            final String postId = state.pathParameters['id']!;
            final Post? post = state.extra as Post?;
            return PostDetailScreen(postId: postId, postSummary: post);
          },
        ),
        // --- THIS IS THE FIX ---
        // The 'about' route has been completely removed from go_router.
        // It is now handled internally by Flutter's Navigator.
      ]
    ),
  ],
);

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sorry, this service isn’t available in your area yet. We’re expanding to new places.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goNamed('home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}