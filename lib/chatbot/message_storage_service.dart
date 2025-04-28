import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MessageStorageService {
  static const _messagesKey = 'messages';
  static const _nameKey = 'userName';

  static Future<void> saveMessages(List<Map<String, String>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_messagesKey, jsonEncode(messages));
  }

  static Future<List<Map<String, String>>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_messagesKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_nameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }
}
