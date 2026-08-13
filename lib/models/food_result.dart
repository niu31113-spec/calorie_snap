/// 单个食物的识别结果
class FoodItem {
  final String name; // 食物名称
  final double calories; // 估算热量(千卡)
  final double protein; // 蛋白质(克)
  final double carbs; // 碳水化合物(克)
  final double fat; // 脂肪(克)

  FoodItem({
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
    return FoodItem(
      name: (json['name'] ?? '未知食物').toString(),
      calories: toDouble(json['calories']),
      protein: toDouble(json['protein']),
      carbs: toDouble(json['carbs']),
      fat: toDouble(json['fat']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

/// 一次拍照识别的完整结果(可能包含多个食物)
class MealResult {
  final DateTime time;
  final List<FoodItem> items;
  final String? imagePath;

  MealResult({required this.time, required this.items, this.imagePath});

  double get totalCalories =>
      items.fold(0.0, (sum, item) => sum + item.calories);

  factory MealResult.fromJson(Map<String, dynamic> json) => MealResult(
        time: DateTime.parse(json['time'] as String),
        imagePath: json['imagePath'] as String?,
        items: (json['items'] as List)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'imagePath': imagePath,
        'items': items.map((e) => e.toJson()).toList(),
      };
}