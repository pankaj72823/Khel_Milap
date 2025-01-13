import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUsers(String query) async {
    final response = await _supabase
        .from('Users')
        .select()
        .ilike('username', '%$query%');
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchChatMessages(String chatId) async {
    final response = await _supabase
        .from('chats')
        .select()
        .eq('chat_id', chatId)
        .order('timestamp', ascending: true);
    return response;
  }

  Future<void> sendMessage(String chatId, String senderId, String message) async {
    await _supabase.from('chats').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
