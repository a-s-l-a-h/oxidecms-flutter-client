// lib/features/post/presentation/screens/home_screen.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:new_version_plus/new_version_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appbase_client/features/post/presentation/widgets/app_drawer.dart';
import 'package:appbase_client/features/post/presentation/widgets/latest_posts_slider.dart';
import 'package:appbase_client/features/post/presentation/widgets/post_list_item.dart';
import 'package:appbase_client/features/post/providers/posts_provider.dart';
import 'package:appbase_client/features/post/providers/server_status_provider.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final FocusNode _searchFocusNode;
  late final ScrollController _mainScrollController;
  late final ScrollController _searchScrollController;
  final TextEditingController _searchController = TextEditingController(); // Controller for search field


  @override
  void initState() {
    super.initState();
    _checkVersion();
    _searchFocusNode = FocusNode();
    _mainScrollController = ScrollController();
    _searchScrollController = ScrollController();

    _mainScrollController.addListener(_onMainScroll);
    _searchScrollController.addListener(_onSearchScroll);

    // Trigger the server status check when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverStatusProvider);
    });
  }

  void _checkVersion() async {
    // This check ensures the force update logic only runs on iOS and Android.
    if (kIsWeb) {
      return;
    }

    // Initialize the plugin
    final newVersion = NewVersionPlus(
      // IMPORTANT: Replace with your actual IDs
        androidId: 'com.ibtwil.blogs',
        iOSId: 'com.ibtwil.blogs',
    );

    // Check the store for a new version
    final status = await newVersion.getVersionStatus();

    // Show the update dialog if a new version is available
    if (mounted && status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText:
            'A new version of ibtwil is available. Please update to continue enjoying the latest features and improvements.',
        updateButtonText: 'Update Now',
        allowDismissal: false, // This is the key part for a FORCE update
      );
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _mainScrollController.removeListener(_onMainScroll);
    _mainScrollController.dispose();
    _searchScrollController.removeListener(_onSearchScroll);
    _searchScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onMainScroll() {
    if (_mainScrollController.position.pixels >= _mainScrollController.position.maxScrollExtent - 400) {
      final submittedQuery = ref.read(submittedSearchQueryProvider);
      if(submittedQuery.isEmpty) {
        ref.read(postSummariesProvider.notifier).fetchNextPage();
      }
    }
  }

  void _onSearchScroll() {
    if (_searchScrollController.position.pixels >= _searchScrollController.position.maxScrollExtent - 100) {
      ref.read(serverSearchProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = ref.watch(filteredPostsProvider);
    final postsState = ref.watch(postSummariesProvider);
    final themeMode = ref.watch(themeProvider);
    final searchState = ref.watch(serverSearchProvider);
    final showSearchResults = ref.watch(submittedSearchQueryProvider).isNotEmpty;
    
    final selectedTags = ref.watch(selectedTagsProvider);
    final isAllActive = selectedTags.contains('All') || selectedTags.isEmpty;
    final isFilterActive = !isAllActive;

    // --- FIX 1: Listen to the text field state to sync our controller ---
    ref.listen<String>(searchQueryProvider, (_, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
      }
    });

    final serverStatus = ref.watch(serverStatusProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: TextField(
          controller: _searchController, // Use the text controller
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            // --- FIX 2: Make the search icon dynamic and intelligent ---
            suffixIcon: IconButton(
              // Change icon based on whether results are shown
              icon: Icon(showSearchResults ? Icons.close : Icons.search),
              tooltip: showSearchResults ? 'Clear Search' : 'Search',
              onPressed: () {
                final isCurrentlyShowingResults = ref.read(submittedSearchQueryProvider).isNotEmpty;

                if (isCurrentlyShowingResults) {
                  // If results are showing, this button now acts as a "clear" button.
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(submittedSearchQueryProvider.notifier).state = '';
                  _searchFocusNode.unfocus();
                } else {
                  // Otherwise, it acts as a "search" button.
                  final currentQuery = ref.read(searchQueryProvider);
                  if (currentQuery.isNotEmpty) {
                    ref.read(submittedSearchQueryProvider.notifier).state = currentQuery;
                    _searchFocusNode.unfocus();
                  }
                }
              },
            ),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
            if (value.isEmpty) {
              ref.read(submittedSearchQueryProvider.notifier).state = '';
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
                ref.read(submittedSearchQueryProvider.notifier).state = value;
                _searchFocusNode.unfocus();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      // --- FIX 3: Improve the tap detection to hide results ---
      body: GestureDetector(
        onTap: () {
          // When tapping anywhere on the body:
          _searchFocusNode.unfocus();
          // And explicitly hide the search results.
          ref.read(submittedSearchQueryProvider.notifier).state = '';
        },
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(submittedSearchQueryProvider.notifier).state = '';
                await ref.read(postSummariesProvider.notifier).refresh();
              },
              child: CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  const SliverToBoxAdapter(child: LatestPostsSlider()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          isFilterActive 
                            ? FilledButton.tonalIcon(
                                icon: const Icon(Icons.filter_list),
                                label: const Text('Filter by Tags'),
                                onPressed: () => _showFilterDialog(context),
                              )
                            : OutlinedButton.icon(
                                icon: const Icon(Icons.filter_list),
                                label: const Text('Filter by Tags'),
                                onPressed: () => _showFilterDialog(context),
                              ),
                          const SizedBox(width: 8),

                          isAllActive
                            ? FilledButton.tonalIcon(
                                icon: const Icon(Icons.clear_all),
                                label: const Text('All'),
                                onPressed: () {
                                  ref.read(selectedTagsProvider.notifier).clearFilters();
                                },
                              )
                            : TextButton.icon(
                                icon: const Icon(Icons.clear_all),
                                label: const Text('All'),
                                onPressed: () {
                                  ref.read(selectedTagsProvider.notifier).clearFilters();
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Divider(height: 1),
                    ),
                  ),
                  if (postsState.posts.isEmpty && postsState.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (postsState.posts.isEmpty && postsState.error != null)
                     SliverFillRemaining(
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Server not responding now. You may be seeing cached or offlined datas...'),
                      )),
                    )
                  else if (filteredPosts.isEmpty)
                     const SliverFillRemaining(
                        child: Center(child: Text('No posts found for this filter.')),
                     )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == filteredPosts.length) {
                             return postsState.hasMore && postsState.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }
                          return PostListItem(
                            post: filteredPosts[index], showDownloadIcon: false,
                          );
                        },
                        childCount: filteredPosts.length + 1,
                      ),
                    ),
                ],
              ),
            ),
            if (showSearchResults)
              Positioned(
                top: 5, left: 16, right: 16,
                child: Card(
                  elevation: 8, clipBehavior: Clip.antiAlias,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _buildSearchResults(searchState),
                  ),
                ),
              ),
            serverStatus.when(
              data: (isOnline) {
                if (isOnline) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Server Offline'),
                          content: const Text(
                              'We are facing some issues this moment. You may be seeing the cached or offlined datas...'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            )
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                );
              },
              error: (e, st) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchResults(PaginatedPostsState searchState) {
    if (searchState.isLoading && searchState.posts.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    }
    
    if (searchState.error != null) {
        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${searchState.error}')));
    }

    if (searchState.posts.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.search_off), title: Text('No results found.'),
      );
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        controller: _searchScrollController,
        padding: EdgeInsets.zero, shrinkWrap: true,
        itemCount: searchState.posts.length + (searchState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == searchState.posts.length) {
            return searchState.isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
                : const SizedBox.shrink();
          }

          final post = searchState.posts[index];
          return ListTile(
            title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              ref.read(searchQueryProvider.notifier).state = '';
              ref.read(submittedSearchQueryProvider.notifier).state = '';
              _searchFocusNode.unfocus();
              context.goNamed('postDetails', pathParameters: {'id': post.id}, extra: post);
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Tags'),
          content: const _FilterDialogContent(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

// The _FilterDialogContent widget remains unchanged.
class _FilterDialogContent extends ConsumerStatefulWidget {
  const _FilterDialogContent();

  @override
  ConsumerState<_FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends ConsumerState<_FilterDialogContent> {
  late bool _shouldRemember;

  @override
  void initState() {
    super.initState();
    _shouldRemember = ref.read(rememberFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final availableTagsAsync = ref.watch(availableTagsProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    return availableTagsAsync.when(
      data: (allTags) => SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                children: allTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: selectedTags.contains(tag),
                    onSelected: (isSelected) {
                      final currentSelection = Set<String>.from(selectedTags);
                      if (isSelected) {
                        currentSelection.add(tag);
                        currentSelection.remove('All');
                      } else {
                        currentSelection.remove(tag);
                      }
                      Set<String> newSelection = currentSelection;
                      if (currentSelection.isEmpty) {
                        newSelection = {'All'};
                      }
                      ref.read(selectedTagsProvider.notifier).updateFilters(newSelection);
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text("Remember", style: TextStyle(fontSize: 14)),
                    value: _shouldRemember,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _shouldRemember = value;
                      });
                      ref.read(selectedTagsProvider.notifier).setRememberPreference(value);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                TextButton(
                  child: const Text('Clear All'),
                  onPressed: () {
                    ref.read(selectedTagsProvider.notifier).clearFilters();
                  },
                ),
              ],
            )
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Could not load tags: $err'),
    );
  }
}