import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_result.dart';
import '../models/user_profile.dart';

/// 本地存储:用户资料、API Key、饮食历史记录
class StorageService {
  static const _kProfile = 'user_profile';
  static const _kApiKey = 'api_key';
  static const _kHistory = 'meal_history';

  /// 保存用户资料
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  }

  /// 读取用户资料(无则返回默认)
  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null) return UserProfile.defaultProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile.defaultProfile();
    }
  }

  /// 保存 API Key
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiKey, key);
  }

  static Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kApiKey) ?? '';
  }

  /// 追加一条饮食记录
  static Future<void> addMeal(MealResult meal) async {
    final list = await loadHistory();
    list.insert(0, meal); // 最新的放最前
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_kHistory, encoded);
  }

  /// 读取全部历史记录
  static Future<List<MealResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => MealResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 清空历史记录
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistory);
  }
}