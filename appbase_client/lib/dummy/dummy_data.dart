import 'package:appbase_client/core/data/models/post_model.dart';

// SOURCE 1: A lightweight list of post summaries (without markdown)
final List<Post> dummyPostSummaries = [
  Post(
    id: 'dev-01',
    title: 'Flutter For Cross-Platform Success',
    imageUrl: 'https://images.unsplash.com/photo-1607706189992-eae578626c86?w=800',
    primaryCategory: 'Projects',
    tags: ['projects', 'tech', 'diy', 'development'],
    publishedAt: DateTime(2025, 9, 20),
    author: 'Admin',
  ),
  Post(
    id: 'diy-01',
    title: 'Life Hack: The Ultimate Cable Organizer',
    imageUrl: 'https://images.unsplash.com/photo-1543443376-355113391152?w=800',
    primaryCategory: 'DIY Tricks',
    tags: ['diy-tricks', 'common', 'life-hack'],
    publishedAt: DateTime(2025, 9, 19),
    author: 'DIYMaster',
  ),
  // ... add your other post summaries here, making sure markdownContent is omitted ...
];

// SOURCE 2: A map simulating a database lookup for the full content of each post
final Map<String, String> dummyPostContents = {
  'dev-01': '## Flutter For Cross-Platform Success\n\nThis is the full markdown content for the Flutter post...',
  'diy-01': '## DIY Project: Build a Smart Mirror\n\nHere are the step-by-step instructions...',
  // ... add the full markdown content for your other posts here ...
};