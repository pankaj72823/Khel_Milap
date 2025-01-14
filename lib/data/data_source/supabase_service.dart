import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUsers(String query) async {
    final response = await _supabase
        .from('Users')
        .select()
        .ilike('username', '%$query%');
    return response;
  }

  final CacheManager _cacheManager = CacheManager(Config(
    'chat_images_cache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 100,
  ),
  );

  Future<List<Map<String, dynamic>>> fetchMessages(String receiverId) async {
    final senderId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('chats')
        .select()
        .or('and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)')
        .order('created_at', ascending: true);

    return response;
  }

  Future<String> fetchUserProfileImage(String userId) async {
    final response = await _supabase
        .from('Profile')
        .select('profile_pic')
        .eq('id', userId)
        .single();


    final imagePath = response['profile_pic'];
    final imageUrl = _supabase.storage
        .from('Photos')
        .getPublicUrl('User/$userId/$imagePath');

    final cachedImage = await _cacheManager.getSingleFile(imageUrl);
    return cachedImage.path;
  }

  Future<void> sendMessage(String receiverId, String senderId, String message) async {
    await _supabase.from('chats').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchChatMessages(String chatId) async {
    final response = await _supabase
        .from('chats')
        .select()
        .eq('chat_id', chatId)
        .order('timestamp', ascending: true);
    return response;
  }

}

