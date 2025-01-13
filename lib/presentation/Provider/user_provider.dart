import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_source/supabase_service.dart';


final userProvider = FutureProvider.family((ref, String query) {
  return SupabaseService().fetchUsers(query);
});
