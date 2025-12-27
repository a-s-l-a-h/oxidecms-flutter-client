// lib/core/data/repositories/post_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appbase_client/core/config/api_config.dart';
import 'package:appbase_client/core/data/models/post_model.dart';

class PostRepository {
  final http.Client _client;
  final String _baseUrl = '${ApiConfig.baseUrl}/api';

  PostRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> isServerActive() async {
    final uri = Uri.parse('$_baseUrl/is_server_active');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 && response.body == 'active';
    } catch (e) {
      return false;
    }
  }

  Future<List<Post>> getLatestPosts({int limit = 20, int offset = 0}) async {
    final uri = Uri.parse('$_baseUrl/posts/latest?limit=$limit&offset=$offset');
    
    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Server not responding now');
    }
  }

  Future<Post> getPostById(String postId) async {
    final uri = Uri.parse('$_baseUrl/posts/$postId');
    
    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Post.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (e) {
      throw Exception('Server not responding now');
    }
  }

  Future<List<String>> getAvailableTags() async {
    final uri = Uri.parse('$_baseUrl/tags/available');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((tag) => tag.toString()).toList();
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      throw Exception('Server not responding now');
    }
  }

  Future<List<Post>> searchPosts(String query, {int limit = 10, int offset = 0}) async {
    if (query.isEmpty) {
      return [];
    }
    final uri = Uri.parse('$_baseUrl/posts/search?q=$query&limit=$limit&offset=$offset');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search posts');
      }
    } catch (e) {
      throw Exception('Server not responding now');
    }
  }
}