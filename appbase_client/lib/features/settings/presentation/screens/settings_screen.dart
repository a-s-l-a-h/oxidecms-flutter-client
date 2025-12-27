// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appbase_client/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear cached files, posts, and images.'),
            onTap: () => _showClearCacheDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return const ClearCacheDialog();
      },
    );
  }
}

class ClearCacheDialog extends ConsumerStatefulWidget {
  const ClearCacheDialog({super.key});

  @override
  ConsumerState<ClearCacheDialog> createState() => _ClearCacheDialogState();
}

class _ClearCacheDialogState extends ConsumerState<ClearCacheDialog> {
  @override
  Widget build(BuildContext context) {
    final clearOptions = ref.watch(clearSettingsProvider);
    final notifier = ref.read(clearSettingsProvider.notifier);
    final isClearing = ref.watch(isClearingProvider);

    return AlertDialog(
      title: const Text('Clear Cache'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Clear Cached Posts'),
            value: clearOptions[ClearOption.cachedPosts],
            onChanged: (bool? value) {
              if (value != null) {
                notifier.toggleOption(ClearOption.cachedPosts, value);
              }
            },
          ),
          CheckboxListTile(
            title: const Text('Clear Offline Saved Pages'),
            value: clearOptions[ClearOption.offlinePosts],
            onChanged: (bool? value) {
              if (value != null) {
                notifier.toggleOption(ClearOption.offlinePosts, value);
              }
            },
          ),
          CheckboxListTile(
            title: const Text('Clear Cached Images'),
            value: clearOptions[ClearOption.images],
            onChanged: (bool? value) {
              if (value != null) {
                notifier.toggleOption(ClearOption.images, value);
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          onPressed: (clearOptions.values.any((isSelected) => isSelected)) && !isClearing
              ? () async {
                  final result = await ref.read(clearSettingsProvider.notifier).clearSelectedCaches();
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                }
              : null,
          child: isClearing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Clear'),
        ),
      ],
    );
  }
}