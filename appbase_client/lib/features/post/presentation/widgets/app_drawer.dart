// lib/features/post/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:appbase_client/features/about/presentation/screens/about_screen.dart';
import 'package:appbase_client/features/post/presentation/screens/offline_posts_screen.dart';
import 'package:appbase_client/features/settings/presentation/screens/settings_screen.dart'; // <-- IMPORT THE NEW SCREEN

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showUnavailablePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Service Unavailable'),
        content: const Text('Sorry, this service isn’t available in your area yet. We’re expanding to new places.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ibtwil.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                // The Column is no longer needed since we only have one item.
                // We directly center the Text widget.
                child: Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          // This Expanded widget takes up all available space.
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.extension_outlined),
                  title: const Text('Activities'),
                  onTap: () => _showUnavailablePopup(context),
                ),
                ListTile(
                  leading: const Icon(Icons.store_outlined),
                  title: const Text('Store Locator'),
                  onTap: () => _showUnavailablePopup(context),
                ),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download_done),
                  title: const Text('Offline Posts'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OfflinePostsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Widgets placed here will be at the bottom of the drawer.
          const Divider(),
          // --- NEW: SETTINGS TILE ---
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          // --- END NEW ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ibtwil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}