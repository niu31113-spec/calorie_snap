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

  /// 图片的 base64 编码(不含 data: 前缀)。
  /// 用 base64 而非文件路径,是为了在 Web / 手机 上通用,
  /// 并能持久化后在历史页用 Image.memory 显示缩略图。
  final String? imageBase64;

  MealResult({required this.time, required this.items, this.imageBase64});

  double get totalCalories =>
      items.fold(0.0, (sum, item) => sum + item.calories);

  factory MealResult.fromJson(Map<String, dynamic> json) => MealResult(
        time: DateTime.parse(json['time'] as String),
        // 兼容旧字段名 imagePath(旧数据无 base64,读为 null)
        imageBase64: json['imageBase64'] as String?,
        items: (json['items'] as List)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'imageBase64': imageBase64,
        'items': items.map((e) => e.toJson()).toList(),
      };
}