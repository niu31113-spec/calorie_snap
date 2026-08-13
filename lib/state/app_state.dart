import 'package:flutter/foundation.dart';
import '../models/food_result.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// 全局状态:用户资料、API Key、饮食历史
class AppState extends ChangeNotifier {
  UserProfile _profile = UserProfile.defaultProfile();
  String _apiKey = '';
  List<MealResult> _history = [];
  bool _loaded = false;

  UserProfile get profile => _profile;
  String get apiKey => _apiKey;
  List<MealResult> get history => _history;
  bool get loaded => _loaded;

  /// App 启动时加载本地数据
  Future<void> init() async {
    _profile = await StorageService.loadProfile();
    _apiKey = await StorageService.loadApiKey();
    _history = await StorageService.loadHistory();
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await StorageService.saveProfile(profile);
    notifyListeners();
  }

  Future<void> updateApiKey(String key) async {
    _apiKey = key;
    await StorageService.saveApiKey(key);
    notifyListeners();
  }

  Future<void> addMeal(MealResult meal) async {
    await StorageService.addMeal(meal);
    _history = await StorageService.loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await StorageService.clearHistory();
    _history = [];
    notifyListeners();
  }

  /// 今日累计摄入热量
  double get todayCalories {
    final now = DateTime.now();
    return _history
        .where((m) =>
            m.time.year == now.year &&
            m.time.month == now.month &&
            m.time.day == now.day)
        .fold(0.0, (sum, m) => sum + m.totalCalories);
  }
}