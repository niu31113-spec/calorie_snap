import '../models/user_profile.dart';

/// 健康指标计算:BMI、BMR(基础代谢)、TDEE(每日消耗)、每日推荐热量
class HealthCalculator {
  /// BMI = 体重(kg) / 身高(m)^2
  static double bmi(UserProfile p) {
    final h = p.heightCm / 100.0;
    if (h <= 0) return 0;
    return p.weightKg / (h * h);
  }

  /// BMI 分类(中国标准)
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏胖';
    return '肥胖';
  }

  /// BMR 基础代谢率(Mifflin-St Jeor 公式)
  static double bmr(UserProfile p) {
    final base = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age;
    return p.gender == Gender.male ? base + 5 : base - 161;
  }

  /// 活动系数
  static double _activityFactor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  /// TDEE 每日总消耗热量 = BMR × 活动系数
  static double tdee(UserProfile p) {
    return bmr(p) * _activityFactor(p.activityLevel);
  }

  /// 根据目标调整后的每日推荐摄入热量
  static double dailyTarget(UserProfile p) {
    final t = tdee(p);
    switch (p.goal) {
      case Goal.lose:
        return t - 500; // 减脂:每日减 500 千卡
      case Goal.gain:
        return t + 300; // 增肌:每日加 300 千卡
      case Goal.maintain:
        return t;
    }
  }

  /// 根据这一餐热量与每日目标,生成一句健康建议
  static String mealAdvice(UserProfile p, double mealCalories) {
    final target = dailyTarget(p);
    final ratio = mealCalories / target;
    if (ratio <= 0) return '暂无热量数据。';
    if (ratio < 0.25) {
      return '这一餐约占你每日目标的 ${(ratio * 100).toStringAsFixed(0)}%,比较清淡,注意营养均衡。';
    } else if (ratio < 0.5) {
      return '这一餐约占你每日目标的 ${(ratio * 100).toStringAsFixed(0)}%,分量适中,继续保持。';
    } else if (ratio < 0.75) {
      return '这一餐约占你每日目标的 ${(ratio * 100).toStringAsFixed(0)}%,偏多了,其余两餐建议清淡些。';
    } else {
      return '这一餐约占你每日目标的 ${(ratio * 100).toStringAsFixed(0)}%,热量偏高,建议适当运动消耗。';
    }
  }

  static String goalText(Goal goal) {
    switch (goal) {
      case Goal.lose:
        return '减脂';
      case Goal.maintain:
        return '维持';
      case Goal.gain:
        return '增肌';
    }
  }

  static String activityText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return '久坐(几乎不运动)';
      case ActivityLevel.light:
        return '轻度(每周1-3次)';
      case ActivityLevel.moderate:
        return '中度(每周3-5次)';
      case ActivityLevel.active:
        return '高强度(每周6-7次)';
      case ActivityLevel.veryActive:
        return '极高(体力劳动/运动员)';
    }
  }
}