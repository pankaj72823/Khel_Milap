import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthManager {
  static const _loginTimeKey = 'login_timestamp';


  static Future<void> setLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Checks if the session is still valid
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime == null) return false;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const tenMinutes = 10 * 60 * 1000; // 10 mins in ms
    return (currentTime - loginTime) < tenMinutes;
  }

  // Clear session info (optional on manual logout)
  static Future<void> clearLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTimeKey);
  }

  // Call this on app start to check if user should stay logged in
  static Future<bool> shouldStayLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    final isValid = await isSessionValid();
    return session != null && isValid;
  }
}
