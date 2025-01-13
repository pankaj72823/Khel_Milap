import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_source/supabase_service.dart';

final chatProvider = FutureProvider.family((ref, String chatId) {
  return SupabaseService().fetchChatMessages(chatId);
});
